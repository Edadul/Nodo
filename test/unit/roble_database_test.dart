import 'package:mocktail/mocktail.dart';
import 'package:nodo/core/db/roble_database.dart';
import 'package:test/test.dart';

import 'support/mocks.dart';

void main() {
  late MockRobleApiDataBase client;
  late Roble database;

  setUp(() {
    client = MockRobleApiDataBase();
    Roble.robleDatabaseForTesting = client;
    database = Roble();
  });

  tearDown(() {
    Roble.robleDatabaseForTesting = null;
  });

  group('Roble.robleDatabase', () {
    test('lanza StateError si no se configuró el cliente', () {
      Roble.robleDatabaseForTesting = null;

      expect(() => Roble.robleDatabase, throwsStateError);
    });
  });

  group('Roble.read', () {
    const filters = {'project_id': 'project-1'};
    final rows = [
      {'_id': 'rec-1', 'id': 'update-1'},
    ];

    test('sin sesión usa la lectura pública', () async {
      when(() => client.isLoggedIn).thenReturn(false);
      when(() => client.publicRead('projects', filters: filters))
          .thenAnswer((_) async => rows);

      final result = await database.read('projects', filters: filters);

      expect(result, equals(rows));
      verifyNever(
        () => client.read(any(), filters: any(named: 'filters')),
      );
    });

    test('con sesión usa la lectura autenticada', () async {
      when(() => client.isLoggedIn).thenReturn(true);
      when(() => client.read('projects', filters: filters))
          .thenAnswer((_) async => rows);

      final result = await database.read('projects', filters: filters);

      expect(result, equals(rows));
      verifyNever(
        () => client.publicRead(any(), filters: any(named: 'filters')),
      );
    });

    test('propaga los errores del cliente', () {
      when(() => client.isLoggedIn).thenReturn(true);
      when(() => client.read('projects', filters: null))
          .thenThrow(Exception('401'));

      expect(() => database.read('projects'), throwsException);
    });
  });

  group('Roble escritura', () {
    test('insert delega en create y devuelve la fila creada', () async {
      final data = {'id': 'project-1', 'title': 'App'};
      final created = {'_id': 'rec-1', ...data};
      when(() => client.create('projects', data))
          .thenAnswer((_) async => created);

      final result = await database.insert('projects', data);

      expect(result, equals(created));
    });

    test('update delega con el _id del registro', () async {
      final data = {'status': 'closed'};
      when(() => client.update('projects', 'rec-1', data))
          .thenAnswer((_) async => {});

      await database.update('projects', 'rec-1', data);

      verify(() => client.update('projects', 'rec-1', data)).called(1);
    });

    test('delete delega con el _id del registro', () async {
      when(() => client.delete('projects', 'rec-1'))
          .thenAnswer((_) async => {});

      await database.delete('projects', 'rec-1');

      verify(() => client.delete('projects', 'rec-1')).called(1);
    });
  });
}
