import 'package:mocktail/mocktail.dart';
import 'package:nodo/core/services/catalog_service.dart';
import 'package:test/test.dart';

import 'support/mocks.dart';

void main() {
  late MockDatabase database;
  late CatalogService catalog;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    database = MockDatabase();
    catalog = CatalogService(database);
  });

  group('CatalogService.normalize', () {
    test('pasa a mayúsculas', () {
      expect(CatalogService.normalize('flutter'), equals('FLUTTER'));
    });

    test('recorta los extremos y colapsa espacios intermedios', () {
      expect(CatalogService.normalize('  ux   design \t'), equals('UX DESIGN'));
    });

    test('variantes del mismo nombre producen el mismo valor', () {
      expect(
        CatalogService.normalize('ux  design'),
        equals(CatalogService.normalize('UX Design')),
      );
    });
  });

  group('CatalogService.validateName', () {
    test('acepta un nombre dentro de los límites', () {
      expect(CatalogService.validateName('Flutter'), isNull);
    });

    test('rechaza nombres más cortos que el mínimo', () {
      expect(CatalogService.validateName('a'), equals('Mínimo 2 caracteres'));
    });

    test('mide la longitud después de normalizar', () {
      expect(CatalogService.validateName('   a   '), equals('Mínimo 2 caracteres'));
    });

    test('acepta exactamente el máximo y rechaza uno más', () {
      expect(CatalogService.validateName('a' * 40), isNull);
      expect(
        CatalogService.validateName('a' * 41),
        equals('Máximo 40 caracteres'),
      );
    });
  });

  group('CatalogService.readAll', () {
    test('mapea id → name y usa _id cuando falta id', () async {
      when(() => database.read('skills')).thenAnswer((_) async => [
            {'_id': 'rec-1', 'id': 'skill-1', 'name': 'FLUTTER'},
            {'_id': 'rec-2', 'name': 'BACKEND'},
          ]);

      final result = await catalog.readAll(CatalogTable.skills);

      expect(result, equals({'skill-1': 'FLUTTER', 'rec-2': 'BACKEND'}));
    });

    test('descarta filas sin nombre', () async {
      when(() => database.read('skills')).thenAnswer((_) async => [
            {'id': 'skill-1', 'name': 'FLUTTER'},
            {'id': 'skill-2', 'name': '   '},
            {'id': 'skill-3', 'name': null},
            {'id': 'skill-4'},
          ]);

      final result = await catalog.readAll(CatalogTable.skills);

      expect(result.keys, equals(['skill-1']));
    });

    test('sirve lecturas posteriores desde la caché', () async {
      when(() => database.read('categories')).thenAnswer((_) async => [
            {'id': 'cat-1', 'name': 'DISEÑO'},
          ]);

      final first = await catalog.readAll(CatalogTable.categories);
      final second = await catalog.readAll(CatalogTable.categories);

      expect(second, equals(first));
      verify(() => database.read('categories')).called(1);
    });

    test('forceRefresh vuelve a leer de la base de datos', () async {
      var call = 0;
      when(() => database.read('categories')).thenAnswer((_) async {
        call++;
        return [
          {'id': 'cat-$call', 'name': 'CATEGORÍA $call'},
        ];
      });

      await catalog.readAll(CatalogTable.categories);
      final refreshed =
          await catalog.readAll(CatalogTable.categories, forceRefresh: true);

      expect(refreshed, equals({'cat-2': 'CATEGORÍA 2'}));
      verify(() => database.read('categories')).called(2);
    });

    test('mantiene una caché independiente por tabla', () async {
      when(() => database.read('categories')).thenAnswer((_) async => [
            {'id': 'cat-1', 'name': 'DISEÑO'},
          ]);
      when(() => database.read('skills')).thenAnswer((_) async => [
            {'id': 'skill-1', 'name': 'FLUTTER'},
          ]);

      final categories = await catalog.readAll(CatalogTable.categories);
      final skills = await catalog.readAll(CatalogTable.skills);

      expect(categories, equals({'cat-1': 'DISEÑO'}));
      expect(skills, equals({'skill-1': 'FLUTTER'}));
    });

    test('propaga el error si la base de datos falla', () async {
      when(() => database.read('skills')).thenThrow(Exception('sin red'));

      expect(catalog.readAll(CatalogTable.skills), throwsException);
    });
  });

  group('CatalogService.ensure', () {
    test('devuelve el id existente sin insertar, comparando normalizado',
        () async {
      when(() => database.read('skills')).thenAnswer((_) async => [
            {'id': 'skill-1', 'name': 'UX DESIGN'},
          ]);

      final id = await catalog.ensure(CatalogTable.skills, '  ux   design ');

      expect(id, equals('skill-1'));
      verifyNever(() => database.insert(any(), any()));
    });

    test('inserta el nombre normalizado con un UUID v4 cuando no existe',
        () async {
      when(() => database.read('skills')).thenAnswer((_) async => []);
      when(() => database.insert(any(), any())).thenAnswer((_) async => {});

      final id = await catalog.ensure(CatalogTable.skills, 'data  science');

      final captured =
          verify(() => database.insert('skills', captureAny())).captured.single
              as Map<String, dynamic>;
      expect(captured['name'], equals('DATA SCIENCE'));
      expect(captured['id'], equals(id));
      expect(
        id,
        matches(RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        )),
      );
    });

    test('agrega el registro nuevo a la caché sin volver a leer', () async {
      when(() => database.read('skills')).thenAnswer((_) async => []);
      when(() => database.insert(any(), any())).thenAnswer((_) async => {});

      final id = await catalog.ensure(CatalogTable.skills, 'Flutter');
      final all = await catalog.readAll(CatalogTable.skills);

      expect(all, equals({id: 'FLUTTER'}));
      verify(() => database.read('skills')).called(1);
    });

    test('si el insert choca con otro usuario, recupera el id desde la red',
        () async {
      var call = 0;
      when(() => database.read('skills')).thenAnswer((_) async {
        call++;
        return call == 1
            ? []
            : [
                {'id': 'skill-remote', 'name': 'FLUTTER'},
              ];
      });
      when(() => database.insert(any(), any()))
          .thenThrow(Exception('UNIQUE violation'));

      final id = await catalog.ensure(CatalogTable.skills, 'flutter');

      expect(id, equals('skill-remote'));
      verify(() => database.read('skills')).called(2);
    });

    test('si el insert falla y el registro no aparece, relanza el error',
        () async {
      when(() => database.read('skills')).thenAnswer((_) async => []);
      when(() => database.insert(any(), any()))
          .thenThrow(StateError('insert falló'));

      expect(
        catalog.ensure(CatalogTable.skills, 'flutter'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
