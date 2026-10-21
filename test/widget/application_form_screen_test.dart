import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/application/domain/entities/application.dart';
import 'package:nodo/features/application/domain/usecases/submit_application.dart';
import 'package:nodo/features/application/presentation/screens/application_confirmation_screen.dart';
import 'package:nodo/features/application/presentation/screens/application_form_screen.dart';
import 'package:nodo/features/application/presentation/viewmodels/application_view_model.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

import 'support/harness.dart';

void main() {
  const motivationField = Key('application-motivation');
  const customSkillField = Key('application-custom-skill');
  const addSkillButton = Key('application-add-skill');
  const experienceField = Key('application-experience');
  const submitButton = Key('application-submit');

  const motivation = 'Tengo experiencia en Flutter y quiero aportar al equipo.';

  final project = buildIdea(id: 'project-1', title: 'App de reciclaje');
  final applicant = buildUser(id: 'user-1');

  late MockApplicationRepository repository;

  setUpAll(() {
    registerFallbackValue(buildApplication());
    registerFallbackValue(buildUser());
  });

  setUp(() {
    repository = MockApplicationRepository();
    when(() => repository.getProject('project-1'))
        .thenAnswer((_) async => project);
    when(() => repository.findApplication('project-1', 'user-1'))
        .thenAnswer((_) async => null);
  });

  Future<void> pumpForm(WidgetTester tester) async {
    useTallScreen(tester);
    final viewModel = ApplicationViewModel(
      submitApplication: SubmitApplication(repository),
    );
    final AuthViewModel auth = await authWith(applicant);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: auth,
        child: MaterialApp(
          home: ApplicationFormScreen(idea: project, viewModel: viewModel),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseExperience(WidgetTester tester, String level) async {
    await tester.tap(find.byKey(experienceField));
    await tester.pumpAndSettle();
    await tester.tap(find.text(level).last);
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester) async {
    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el proyecto y las secciones del formulario',
      (WidgetTester tester) async {
    await pumpForm(tester);

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Postulación'), findsOneWidget);
    expect(find.text('App de reciclaje'), findsOneWidget);
    expect(find.text('Motivación'), findsOneWidget);
    expect(find.text('Habilidades que aportas'), findsOneWidget);
    expect(find.text('Experiencia'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byKey(experienceField), findsOneWidget);
    // Una chip por habilidad requerida del proyecto.
    expect(find.widgetWithText(FilterChip, 'FLUTTER'), findsOneWidget);
    expect(find.text('Enviar postulación'), findsOneWidget);
  });

  testWidgets('el encabezado del proyecto resalta el título en blanco',
      (WidgetTester tester) async {
    await pumpForm(tester);

    final title = find.text('App de reciclaje').evaluate().first.widget as Text;
    expect(title.style!.color, equals(Colors.white));
    expect(title.style!.fontSize, greaterThan(18));
  });

  testWidgets('enviar vacío valida motivación y experiencia',
      (WidgetTester tester) async {
    await pumpForm(tester);

    await send(tester);

    expect(find.text('Escribe al menos 20 caracteres'), findsOneWidget);
    expect(find.text('Selecciona tu experiencia'), findsOneWidget);
    verifyNever(() => repository.submit(any(), any()));
  });

  testWidgets('sin habilidades seleccionadas avisa con un SnackBar',
      (WidgetTester tester) async {
    await pumpForm(tester);
    await tester.enterText(find.byKey(motivationField), motivation);
    await chooseExperience(tester, '1 a 2 años');

    await send(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Selecciona al menos una habilidad'), findsOneWidget);
    verifyNever(() => repository.submit(any(), any()));
  });

  testWidgets('tocar una habilidad la selecciona',
      (WidgetTester tester) async {
    await pumpForm(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'FLUTTER'));
    await tester.pump();

    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'FLUTTER'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('agregar una habilidad propia la normaliza y la selecciona',
      (WidgetTester tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byKey(customSkillField), 'comunidad');
    await tester.tap(find.byKey(addSkillButton));
    await tester.pump();

    final chip = find.widgetWithText(FilterChip, 'COMUNIDAD');
    expect(chip, findsOneWidget);
    expect(tester.widget<FilterChip>(chip).selected, isTrue);
  });

  testWidgets('rechaza habilidades propias inválidas o repetidas',
      (WidgetTester tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byKey(customSkillField), 'a');
    await tester.tap(find.byKey(addSkillButton));
    await tester.pump();
    expect(find.text('Mínimo 2 caracteres'), findsOneWidget);

    await tester.enterText(find.byKey(customSkillField), 'comunidad');
    await tester.tap(find.byKey(addSkillButton));
    await tester.pump();
    await tester.enterText(find.byKey(customSkillField), 'Comunidad');
    await tester.tap(find.byKey(addSkillButton));
    await tester.pump();
    expect(find.text('Ya está agregada'), findsOneWidget);
  });

  testWidgets('un formulario válido envía la postulación y confirma',
      (WidgetTester tester) async {
    when(() => repository.submit(any(), any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as Application,
    );
    await pumpForm(tester);

    await tester.enterText(find.byKey(motivationField), motivation);
    await tester.tap(find.widgetWithText(FilterChip, 'FLUTTER'));
    await chooseExperience(tester, '1 a 2 años');
    await send(tester);

    final sent = verify(() => repository.submit(captureAny(), any()))
        .captured
        .single as Application;
    expect(sent.projectId, equals('project-1'));
    expect(sent.applicantId, equals('user-1'));
    expect(sent.motivation, equals(motivation));
    expect(sent.skills, equals(['FLUTTER']));
    expect(sent.experience, equals('1 a 2 años'));

    expect(find.byType(ApplicationConfirmationScreen), findsOneWidget);
    expect(find.text('¡Postulación enviada!'), findsOneWidget);
  });

  testWidgets('si ya se postuló muestra el motivo y no navega',
      (WidgetTester tester) async {
    when(() => repository.findApplication('project-1', 'user-1')).thenAnswer(
      (_) async => buildApplication(id: 'a-old'),
    );
    await pumpForm(tester);

    await tester.enterText(find.byKey(motivationField), motivation);
    await tester.tap(find.widgetWithText(FilterChip, 'FLUTTER'));
    await chooseExperience(tester, 'Menos de 1 año');
    await send(tester);

    expect(
      find.text('Ya tienes una postulación pendiente en este proyecto.'),
      findsOneWidget,
    );
    expect(find.byType(ApplicationConfirmationScreen), findsNothing);
    verifyNever(() => repository.submit(any(), any()));
  });
}
