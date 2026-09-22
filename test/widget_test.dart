import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nodo/main.dart';
import 'package:nodo/core/services/project_service.dart';
import 'package:nodo/features/home/data/datasources/mock_idea_datasource.dart';
import 'package:nodo/features/home/data/repositories/idea_repository_impl.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';
import 'package:nodo/features/home/domain/usecases/get_categories.dart';
import 'package:nodo/features/home/presentation/viewmodels/home_view_model.dart';

import 'package:nodo/features/application/data/datasources/mock_application_datasource.dart';
import 'package:nodo/features/application/data/repositories/application_repository_impl.dart';
import 'package:nodo/features/application/domain/usecases/submit_application.dart';
import 'package:nodo/features/application/presentation/viewmodels/application_view_model.dart';
import 'package:nodo/core/db/roble_database.dart';

void main() {
  Widget createTestApp() {
    final mockIdeaDataSource = MockIdeaDataSource();
    final ideaRepository = IdeaRepositoryImpl(mockIdeaDataSource);
    final getIdeas = GetIdeas(ideaRepository);
    final getCategories = GetCategories(ideaRepository);

    final mockAppDataSource = MockApplicationDataSource();
    final appRepository = ApplicationRepositoryImpl(mockAppDataSource);
    final submitApplication = SubmitApplication(appRepository);

    // Provide a stub database and project service for the test
    final stubDb = Roble();
    final projectService = ProjectService(stubDb);

    return MultiProvider(
      providers: [
        Provider<ProjectService>(create: (_) => projectService),
        Provider<HomeViewModel Function()>(
          create: (_) => () => HomeViewModel(
            getIdeas: getIdeas,
            getCategories: getCategories,
          ),
        ),
        Provider<ApplicationViewModel Function()>(
          create: (_) => () => ApplicationViewModel(
            submitApplication: submitApplication,
          ),
        ),
      ],
      child: const NodoApp(),
    );
  }

  testWidgets('Home muestra título Únete y feed', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Únete'), findsOneWidget);
    expect(
      find.text('Explora ideas en crecimiento o siembra la tuya'),
      findsOneWidget,
    );
    expect(find.text('TODAS'), findsOneWidget);
    expect(find.text('Huerta urbana colaborativa'), findsOneWidget);
    expect(find.text('Asistente de estudio con IA'), findsOneWidget);
  });

  testWidgets('Filtrar por categoría actualiza el feed', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'TECNOLOGÍA'));
    await tester.pumpAndSettle();

    expect(find.text('Asistente de estudio con IA'), findsOneWidget);
    expect(find.text('Huerta urbana colaborativa'), findsNothing);
  });
}
