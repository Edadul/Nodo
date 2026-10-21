import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nodo/core/db/db_interface.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/application/domain/entities/application.dart';
import 'package:nodo/features/application/domain/usecases/get_my_participations.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/data/repositories/profile_repository.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';
import 'package:nodo/features/home/presentation/screens/profile_screen.dart';
import 'package:provider/provider.dart';

import 'support/harness.dart';

void main() {
  final owner = buildUser(id: 'creator-1', name: 'Luis Creador');

  // Dos proyectos del usuario y uno ajeno al que se postuló.
  final ownA = buildIdea(id: 'p-1', title: 'App de reciclaje');
  final ownB = buildIdea(id: 'p-2', title: 'Huerta urbana');
  final foreign = Idea(
    id: 'p-3',
    title: 'Biblioteca digital',
    description: 'Digitalizar el archivo del campus.',
    categories: const ['SOCIAL'],
    skills: const ['DATOS'],
    filledSpots: 0,
    totalSpots: 2,
    gradientColors: const [0xFF7B6CF0, 0xFFB8A9FF],
    creatorId: 'other-user',
  );

  late MockIdeaRepository ideas;
  late MockApplicationRepository applications;
  late MockProfileRepository profiles;
  late MockDatabase database;

  setUp(() {
    ideas = MockIdeaRepository();
    applications = MockApplicationRepository();
    profiles = MockProfileRepository();
    database = MockDatabase();

    when(() => ideas.getIdeas(category: any(named: 'category')))
        .thenAnswer((_) async => [ownA, ownB, foreign]);
    when(() => applications.listByApplicant(any())).thenAnswer(
      (_) async => [
        buildApplication(projectId: 'p-3', applicantId: 'creator-1'),
      ],
    );
    when(() => profiles.fetchByUserId(any())).thenAnswer((_) async => null);
    when(() => database.read(any(), filters: any(named: 'filters')))
        .thenAnswer((_) async => []);
  });

  Future<void> pumpProfile(WidgetTester tester, User? user) async {
    useTallScreen(tester);
    final AuthViewModel auth = await authWith(user);
    final getIdeas = GetIdeas(ideas);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(value: auth),
          Provider<GetIdeas>.value(value: getIdeas),
          Provider<GetMyParticipations>.value(
            value: GetMyParticipations(applications, getIdeas),
          ),
          Provider<ProfileRepository>.value(value: profiles),
          Provider<IDatabase>.value(value: database),
        ],
        child: const MaterialApp(home: ProfileView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ProfileView en sesión pública', () {
    testWidgets('muestra el perfil de invitado y el botón de login',
        (WidgetTester tester) async {
      await pumpProfile(tester, null);

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Mi perfil'), findsOneWidget);
      expect(find.text('Invitado'), findsOneWidget);
      // FilledButton.icon crea una subclase privada: se busca por su texto.
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
      expect(
        find.text('Inicia sesión para crear y administrar proyectos'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('my-project-p-1')), findsNothing);
    });
  });

  group('ProfileView con sesión iniciada', () {
    testWidgets('muestra los datos del usuario y solo sus proyectos',
        (WidgetTester tester) async {
      await pumpProfile(tester, owner);

      expect(find.text('Luis Creador'), findsOneWidget);
      expect(find.text('creator-1@nodo.test'), findsOneWidget);
      expect(find.text('2 creados · 0 en equipo · 1 en revisión'),
          findsOneWidget);
      expect(find.byKey(const ValueKey('my-project-p-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('my-project-p-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('my-project-p-3')), findsNothing);
      expect(find.text('Biblioteca digital'), findsNothing);
      expect(find.text('Crear otro proyecto'), findsOneWidget);
    });

    testWidgets('el nombre se muestra grande y en negrita',
        (WidgetTester tester) async {
      await pumpProfile(tester, owner);

      final name = find.text('Luis Creador').evaluate().first.widget as Text;
      expect(name.style!.fontSize, greaterThan(20));
      expect(name.style!.fontWeight, equals(FontWeight.w800));
    });

    testWidgets('la pestaña activa se resalta en el color primario',
        (WidgetTester tester) async {
      await pumpProfile(tester, owner);

      Text tabLabel(String label) =>
          find.text(label).evaluate().first.widget as Text;
      expect(tabLabel('Creados').style!.color, equals(NodoColors.primary));
      expect(tabLabel('Unidos').style!.color, equals(NodoColors.textSecondary));

      await tester.tap(find.byKey(const ValueKey('profile-tab-1')));
      await tester.pumpAndSettle();

      expect(tabLabel('Unidos').style!.color, equals(NodoColors.primary));
      expect(tabLabel('Creados').style!.color, equals(NodoColors.textSecondary));
    });

    testWidgets('la pestaña Unidos lista las postulaciones del usuario',
        (WidgetTester tester) async {
      await pumpProfile(tester, owner);

      await tester.tap(find.byKey(const ValueKey('profile-tab-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('joined-project-p-3')), findsOneWidget);
      expect(find.text('Biblioteca digital'), findsOneWidget);
      expect(find.text('Esperando respuesta del creador'), findsOneWidget);
      expect(find.byKey(const ValueKey('my-project-p-1')), findsNothing);
    });

    testWidgets('un integrante aceptado puede publicar avances desde Unidos',
        (WidgetTester tester) async {
      when(() => applications.listByApplicant(any())).thenAnswer(
        (_) async => [
          Application(
            projectId: 'p-3',
            applicantId: 'creator-1',
            motivation: 'Quiero aportar',
            skills: const ['DATOS'],
            experience: '1 a 2 años',
            submittedAt: DateTime(2026, 1, 1),
            status: ApplicantStatus.accepted,
          ),
        ],
      );
      await pumpProfile(tester, owner);

      await tester.tap(find.byKey(const ValueKey('profile-tab-1')));
      await tester.pumpAndSettle();

      expect(find.text('Formas parte del equipo'), findsOneWidget);
      expect(find.text('Publicar avance'), findsOneWidget);
    });

    testWidgets('en Cuenta el interruptor pausa los avisos',
        (WidgetTester tester) async {
      await pumpProfile(tester, owner);
      await tester.tap(find.byKey(const ValueKey('profile-tab-2')));
      await tester.pumpAndSettle();

      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Activos en este dispositivo'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('Pausados en este dispositivo'), findsOneWidget);
      expect(find.text('Notificaciones desactivadas'), findsOneWidget);
    });

    testWidgets('Cómo usar Nodo abre una hoja informativa',
        (WidgetTester tester) async {
      await pumpProfile(tester, owner);
      await tester.tap(find.byKey(const ValueKey('profile-tab-2')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cómo usar Nodo'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);

      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('Editar perfil abre un diálogo y actualiza el nombre',
        (WidgetTester tester) async {
      await pumpProfile(tester, owner);

      await tester.tap(find.text('Editar perfil'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      final nameField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(nameField.first, 'Luis Fernando');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Luis Fernando'), findsOneWidget);
      expect(find.text('Perfil actualizado'), findsOneWidget);
    });
  });
}
