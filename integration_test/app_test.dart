import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nodo/features/applicants/presentation/screens/applicants_list_screen.dart';
import 'package:nodo/features/application/presentation/screens/application_form_screen.dart';
import 'package:nodo/features/application/presentation/screens/project_detail_screen.dart';
import 'package:nodo/features/auth/presentation/screens/login_screen.dart';
import 'package:nodo/features/home/presentation/screens/home_screen.dart';
import 'package:nodo/features/home/presentation/screens/profile_screen.dart';
import 'package:nodo/features/project_creation/presentation/screens/create_project_screen.dart';

import 'support/nodo_test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder ideaCard(String projectId) =>
      find.byKey(ValueKey('idea-card-$projectId'));

  group('Nodo de punta a punta', () {
    testWidgets('un invitado abre la app y explora el feed',
        (WidgetTester tester) async {
      await startNodo(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Nodo'), findsOneWidget);
      expect(ideaCard(gardenId), findsOneWidget);
      expect(ideaCard(aiId), findsOneWidget);

      // Filtro por categoría: viaja por HomeViewModel → GetIdeas →
      // IdeaRepositoryImpl → ApiIdeaDataSource → CatalogService → BD.
      await tester.tap(find.widgetWithText(FilterChip, 'TECNOLOGÍA'));
      await tester.pumpAndSettle();
      expect(ideaCard(aiId), findsOneWidget);
      expect(ideaCard(gardenId), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'TODAS'));
      await tester.pumpAndSettle();
      expect(ideaCard(gardenId), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'huerta');
      await tester.pumpAndSettle();
      expect(ideaCard(gardenId), findsOneWidget);
      expect(ideaCard(aiId), findsNothing);
    });

    testWidgets('un invitado inicia sesión y publica un proyecto',
        (WidgetTester tester) async {
      final db = await startNodo(tester);
      const title = 'Biblioteca digital del campus';

      // Crear sin sesión lleva al login.
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      await logIn(tester, creator.email, creatorPassword);

      // Tras iniciar sesión la app continúa al formulario.
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(CreateProjectScreen), findsOneWidget);

      await tester.enterText(find.byKey(const Key('project-title')), title);
      await tester.enterText(
        find.byKey(const Key('project-description')),
        'Digitalizar el archivo histórico y abrirlo a todos los estudiantes.',
      );
      await hideKeyboard(tester);

      final form = find.byType(CreateProjectScreen);
      for (final tag in ['SOCIAL', 'FLUTTER']) {
        final chip = find.widgetWithText(FilterChip, tag);
        await scrollTo(tester, chip, scrollable: form);
        await tester.tap(chip);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.byKey(const Key('project-submit')));
      await tester.pumpAndSettle();

      // De vuelta en el feed, con aviso y el proyecto nuevo arriba.
      expect(find.byType(CreateProjectScreen), findsNothing);
      expect(find.text('Proyecto "$title" publicado'), findsOneWidget);
      expect(find.text(title), findsOneWidget);

      final saved = db.rows('projects').singleWhere((p) => p['title'] == title);
      expect(saved['creator_id'], equals(creator.id));
      expect(saved['total_spots'], equals(3));
      final links = db
          .rows('project_categories')
          .where((link) => link['project_id'] == saved['id']);
      expect(links, hasLength(1));
    });

    testWidgets('un estudiante inicia sesión y se postula a un proyecto',
        (WidgetTester tester) async {
      final db = await startNodo(tester);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      await logIn(tester, student.email, studentPassword);
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(ideaCard(gardenId));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectDetailScreen), findsOneWidget);

      await tester.tap(find.text('Postularme'));
      await tester.pumpAndSettle();
      expect(find.byType(ApplicationFormScreen), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('application-motivation')),
        'Tengo experiencia cultivando y quiero sumar al proyecto.',
      );
      await hideKeyboard(tester);

      final form = find.byType(ApplicationFormScreen);
      final skill = find.widgetWithText(FilterChip, 'JARDINERÍA');
      await scrollTo(tester, skill, scrollable: form);
      await tester.tap(skill);
      await tester.pumpAndSettle();

      final experience = find.byKey(const Key('application-experience'));
      await scrollTo(tester, experience, scrollable: form);
      await tester.tap(experience);
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 a 2 años').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('application-submit')));
      await tester.pumpAndSettle();

      expect(find.text('¡Postulación enviada!'), findsOneWidget);
      final saved = db
          .rows('applications')
          .singleWhere((a) => a['applicant_id'] == student.id);
      expect(saved['project_id'], equals(gardenId));
      expect(saved['status'], equals('pending'));
      expect(saved['experience'], equals('1 a 2 años'));

      // Volver al inicio y reabrir el proyecto muestra la postulación.
      await tester.tap(find.text('Volver al inicio'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(ideaCard(gardenId));
      await tester.pumpAndSettle();
      expect(
        find.text('Pendiente · Síguela en Perfil → Unidos'),
        findsOneWidget,
      );
    });

    testWidgets('el creador revisa las postulaciones y acepta una',
        (WidgetTester tester) async {
      final db = await startNodo(tester);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      await logIn(tester, creator.email, creatorPassword);

      // Con sesión iniciada, Perfil abre la vista del usuario.
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileView), findsOneWidget);
      expect(find.text(creator.name), findsOneWidget);

      final card = find.byKey(const ValueKey('my-project-$gardenId'));
      await scrollTo(tester, card, scrollable: find.byType(ProfileView));
      final openApplicants = find.descendant(
        of: card,
        matching: find.text('Postulaciones'),
      );
      await scrollTo(
        tester,
        openApplicants,
        scrollable: find.byType(ProfileView),
      );
      await tester.tap(openApplicants);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicantsListScreen), findsOneWidget);
      expect(find.text('1 postulaciones recibidas'), findsOneWidget);
      final saraCard = find.byKey(const ValueKey('applicant-card-a-sara'));
      expect(saraCard, findsOneWidget);
      expect(
        find.descendant(of: saraCard, matching: find.text('Sara Gómez')),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(of: saraCard, matching: find.text('Aceptar')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sara Gómez fue aceptado/a'), findsOneWidget);
      expect(find.text('Aceptadas (1)'), findsOneWidget);

      final application =
          db.rows('applications').singleWhere((a) => a['id'] == 'a-sara');
      expect(application['status'], equals('accepted'));
      final project =
          db.rows('projects').singleWhere((p) => p['id'] == gardenId);
      expect(project['filled_spots'], equals(1));
    });
  });
}
