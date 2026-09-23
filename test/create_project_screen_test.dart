import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nodo/core/services/catalog_service.dart';
import 'package:nodo/core/services/user_profile_service.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';
import 'package:nodo/features/project_creation/data/datasources/api_project_creation_datasource.dart';
import 'package:nodo/features/project_creation/data/repositories/project_creation_repository_impl.dart';
import 'package:nodo/features/project_creation/domain/usecases/create_project.dart';
import 'package:nodo/features/project_creation/domain/usecases/get_catalog_suggestions.dart';
import 'package:nodo/features/project_creation/presentation/screens/create_project_screen.dart';
import 'package:nodo/features/project_creation/presentation/viewmodels/create_project_view_model.dart';

import 'support/fake_auth.dart';
import 'support/fake_database.dart';
import 'support/seed.dart';

void main() {
  late FakeDatabase db;
  Idea? created;

  Future<void> pump(WidgetTester tester) async {
    // Pantalla alta para que el ListView construya todo el formulario.
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    db = seededDatabase();
    created = null;
    final repository = ProjectCreationRepositoryImpl(
      ApiProjectCreationDataSource(
        db,
        CatalogService(db),
        UserProfileService(db),
      ),
    );
    final viewModel = CreateProjectViewModel(
      createProject: CreateProject(repository),
      getSuggestions: GetCatalogSuggestions(repository),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: await authFor(creator),
        child: MaterialApp(
          theme: buildNodoTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  created = await Navigator.push<Idea>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateProjectScreen(viewModel: viewModel),
                    ),
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> publish(WidgetTester tester) async {
    await tester.tap(find.text('Publicar proyecto'));
    await tester.pumpAndSettle();
  }

  testWidgets('enviar vacío muestra los errores y no guarda', (tester) async {
    await pump(tester);
    await publish(tester);

    expect(find.textContaining('al menos 5 caracteres'), findsOneWidget);
    expect(find.text('Elige al menos una categoría'), findsOneWidget);
    expect(find.text('Agrega al menos una habilidad requerida'), findsOneWidget);
    expect(db.rows('projects'), hasLength(1));
  });

  testWidgets('formulario válido publica y devuelve la idea', (tester) async {
    await pump(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Huerta urbana colaborativa');
    await tester.enterText(
      fields.at(1),
      'Diseñar y construir una huerta comunitaria en el campus.',
    );
    await tester.tap(find.byKey(const Key('spots-increment')));
    await tester.tap(find.widgetWithText(FilterChip, 'SOCIAL'));
    await tester.enterText(fields.at(3), 'riego');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await publish(tester);

    expect(created, isNotNull);
    expect(created!.totalSpots, 4);
    expect(created!.categories, ['SOCIAL']);
    expect(created!.skills, ['RIEGO']);
    expect(db.rows('projects'), hasLength(2));
  });
}
