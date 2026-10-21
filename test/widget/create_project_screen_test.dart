import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';
import 'package:nodo/features/project_creation/domain/entities/project_draft.dart';
import 'package:nodo/features/project_creation/domain/repositories/project_creation_repository.dart';
import 'package:nodo/features/project_creation/domain/usecases/create_project.dart';
import 'package:nodo/features/project_creation/domain/usecases/get_catalog_suggestions.dart';
import 'package:nodo/features/project_creation/presentation/screens/create_project_screen.dart';
import 'package:nodo/features/project_creation/presentation/viewmodels/create_project_view_model.dart';
import 'package:provider/provider.dart';

import 'support/harness.dart';

void main() {
  const titleField = Key('project-title');
  const descriptionField = Key('project-description');
  const submitButton = Key('project-submit');

  final creator = buildUser(id: 'creator-1');

  late MockProjectCreationRepository repository;
  Object? popped;

  setUpAll(() {
    registerFallbackValue(buildDraft());
    registerFallbackValue(buildUser());
  });

  setUp(() {
    repository = MockProjectCreationRepository();
    popped = null;
    when(() => repository.getSuggestions()).thenAnswer(
      (_) async => const CatalogSuggestions(
        categories: ['DISEÑO', 'SOCIAL', 'TECNOLOGÍA'],
        skills: ['BACKEND', 'FLUTTER'],
      ),
    );
    when(() => repository.creatorHasTitle(any(), any()))
        .thenAnswer((_) async => false);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    useTallScreen(tester);
    final viewModel = CreateProjectViewModel(
      createProject: CreateProject(repository),
      getSuggestions: GetCatalogSuggestions(repository),
    );
    final AuthViewModel auth = await authWith(creator);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: auth,
        child: launcher(
          screen: () => CreateProjectScreen(viewModel: viewModel),
          onResult: (result) => popped = result,
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(find.byKey(titleField), '  Huerta urbana  ');
    await tester.enterText(
      find.byKey(descriptionField),
      'Diseñar y construir una huerta comunitaria en el campus.',
    );
    await tester.tap(find.widgetWithText(FilterChip, 'SOCIAL'));
    await tester.tap(find.widgetWithText(FilterChip, 'FLUTTER'));
    await tester.pump();
  }

  Future<void> publish(WidgetTester tester) async {
    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el formulario con las sugerencias del catálogo',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Nuevo proyecto'), findsOneWidget);
    expect(find.byKey(titleField), findsOneWidget);
    expect(find.byKey(descriptionField), findsOneWidget);
    // Título, descripción y los campos para categorías y habilidades propias.
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.byType(FilterChip), findsNWidgets(5));
    expect(find.text('3 cupos'), findsOneWidget);
    expect(find.text('Publicar proyecto'), findsOneWidget);
  });

  testWidgets('los botones + y − cambian los cupos',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const Key('spots-increment')));
    await tester.pump();
    expect(find.text('4 cupos'), findsOneWidget);

    await tester.tap(find.byKey(const Key('spots-decrement')));
    await tester.tap(find.byKey(const Key('spots-decrement')));
    await tester.tap(find.byKey(const Key('spots-decrement')));
    await tester.pump();
    expect(find.text('1 cupo'), findsOneWidget);

    final decrement = tester.widget<IconButton>(
      find.byKey(const Key('spots-decrement')),
    );
    expect(decrement.onPressed, isNull);
  });

  testWidgets('tocar un chip lo selecciona y pinta su texto en blanco',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'SOCIAL'));
    await tester.pump();

    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'SOCIAL'),
    );
    expect(chip.selected, isTrue);
    final label = find.text('SOCIAL').evaluate().first.widget as Text;
    expect(label.style!.color, equals(Colors.white));
  });

  testWidgets('agregar una habilidad propia crea un chip normalizado',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(3), 'riego  por goteo');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final chip = find.widgetWithText(FilterChip, 'RIEGO POR GOTEO');
    expect(chip, findsOneWidget);
    expect(tester.widget<FilterChip>(chip).selected, isTrue);
  });

  testWidgets('publicar vacío marca los errores en el color del tema',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await publish(tester);

    expect(
      find.text('El título debe tener al menos 5 caracteres'),
      findsOneWidget,
    );
    expect(find.text('Elige al menos una categoría'), findsOneWidget);
    expect(find.text('Agrega al menos una habilidad requerida'), findsOneWidget);
    expect(find.text('Revisa los campos marcados'), findsOneWidget);
    verifyNever(() => repository.create(any(), any()));

    final error = find.text('Elige al menos una categoría').evaluate().first
        .widget as Text;
    final errorColor = Theme.of(
      tester.element(find.byType(CreateProjectScreen)),
    ).colorScheme.error;
    expect(error.style!.color, equals(errorColor));
    expect(error.style!.fontSize, equals(12));
  });

  testWidgets('escribir en el título borra su error',
      (WidgetTester tester) async {
    await pumpScreen(tester);
    await publish(tester);

    await tester.enterText(find.byKey(titleField), 'Hue');
    await tester.pump();

    expect(
      find.text('El título debe tener al menos 5 caracteres'),
      findsNothing,
    );
  });

  testWidgets('un formulario válido publica y devuelve el proyecto creado',
      (WidgetTester tester) async {
    final created = buildIdea(id: 'p-new', title: 'Huerta urbana');
    when(() => repository.create(any(), any()))
        .thenAnswer((_) async => created);
    await pumpScreen(tester);
    await fillValidForm(tester);

    await publish(tester);

    final captured =
        verify(() => repository.create(captureAny(), captureAny())).captured;
    final draft = captured[0] as ProjectDraft;
    expect(draft.title, equals('Huerta urbana'));
    expect(draft.categories, equals(['SOCIAL']));
    expect(draft.skills, equals(['FLUTTER']));
    expect(draft.totalSpots, equals(3));
    expect((captured[1] as User).id, equals('creator-1'));

    expect(find.byType(CreateProjectScreen), findsNothing);
    expect(popped, isA<Idea>());
    expect((popped! as Idea).id, equals('p-new'));
  });

  testWidgets('un título repetido muestra el aviso y no cierra la pantalla',
      (WidgetTester tester) async {
    when(() => repository.creatorHasTitle('creator-1', 'Huerta urbana'))
        .thenAnswer((_) async => true);
    await pumpScreen(tester);
    await fillValidForm(tester);

    await publish(tester);

    expect(
      find.text('Ya tienes un proyecto con ese título. Elige otro.'),
      findsOneWidget,
    );
    expect(find.byType(CreateProjectScreen), findsOneWidget);
    verifyNever(() => repository.create(any(), any()));
  });
}
