import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/applicants/domain/usecases/decide_application.dart';
import 'package:nodo/features/applicants/domain/usecases/get_applicants.dart';
import 'package:nodo/features/applicants/presentation/screens/applicants_list_screen.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';
import 'package:nodo/features/applicants/presentation/widgets/applicant_card.dart';

import 'support/harness.dart';

void main() {
  const projectId = 'project-1';
  final creator = buildUser(id: 'creator-1', name: 'Luis');

  final ana = buildApplicant(id: 'a-1', recordId: 'rec-a-1', name: 'Ana Torres');
  final pedro =
      buildApplicant(id: 'a-2', recordId: 'rec-a-2', name: 'Pedro Gómez');
  final sara = buildApplicant(
    id: 'a-3',
    recordId: 'rec-a-3',
    name: 'Sara Ruiz',
    status: ApplicantStatus.accepted,
  );

  late MockApplicantRepository repository;

  setUpAll(() {
    registerFallbackValue(buildIdea());
    registerFallbackValue(buildApplicant());
    registerFallbackValue(ApplicantStatus.pending);
  });

  setUp(() {
    repository = MockApplicantRepository();
    when(() => repository.getProject(projectId))
        .thenAnswer((_) async => buildIdea(filledSpots: 1, totalSpots: 3));
    when(() => repository.getApplicantsByProject(projectId))
        .thenAnswer((_) async => [ana, pedro, sara]);
  });

  Finder cardOf(String applicationId) =>
      find.byKey(ValueKey('applicant-card-$applicationId'));

  Finder inCard(String applicationId, Finder matching) =>
      find.descendant(of: cardOf(applicationId), matching: matching);

  Future<void> pumpList(WidgetTester tester) async {
    useTallScreen(tester);
    final viewModel = ApplicantsViewModel(
      getApplicants: GetApplicants(repository),
      decideApplication: DecideApplication(repository),
      projectId: projectId,
      actor: creator,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ApplicantsListScreen(projectId: projectId, viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el resumen, los filtros y una tarjeta por postulante',
      (WidgetTester tester) async {
    await pumpList(tester);

    expect(find.text('Postulaciones'), findsOneWidget);
    expect(find.text('3 postulaciones recibidas'), findsOneWidget);
    expect(find.text('2 cupos disponibles (1 de 3 cupos)'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Pendientes (2)'), findsOneWidget);
    expect(find.text('Aceptadas (1)'), findsOneWidget);
    expect(find.text('Rechazadas (0)'), findsOneWidget);

    expect(find.byType(ApplicantCard), findsNWidgets(3));
    expect(cardOf('a-1'), findsOneWidget);
    expect(cardOf('a-2'), findsOneWidget);
    expect(cardOf('a-3'), findsOneWidget);
    expect(inCard('a-1', find.text('Ana Torres')), findsOneWidget);
  });

  testWidgets('solo las postulaciones pendientes tienen Aceptar y Rechazar',
      (WidgetTester tester) async {
    await pumpList(tester);

    expect(inCard('a-1', find.text('Aceptar')), findsOneWidget);
    expect(inCard('a-2', find.text('Rechazar')), findsOneWidget);
    expect(inCard('a-3', find.text('Aceptar')), findsNothing);
    expect(inCard('a-3', find.text('Aceptado')), findsOneWidget);
  });

  testWidgets('los cupos disponibles se resaltan con el color primario',
      (WidgetTester tester) async {
    await pumpList(tester);

    final spots = find
        .text('2 cupos disponibles (1 de 3 cupos)')
        .evaluate()
        .first
        .widget as Text;
    expect(spots.style!.color, equals(NodoColors.primary));
    expect(spots.style!.fontWeight, equals(FontWeight.w700));
  });

  testWidgets('los filtros cambian las tarjetas visibles',
      (WidgetTester tester) async {
    await pumpList(tester);

    await tester.tap(find.text('Aceptadas (1)'));
    await tester.pump();
    expect(find.byType(ApplicantCard), findsOneWidget);
    expect(cardOf('a-3'), findsOneWidget);

    await tester.tap(find.text('Rechazadas (0)'));
    await tester.pump();
    expect(find.byType(ApplicantCard), findsNothing);
    expect(find.text('No hay postulaciones en este filtro'), findsOneWidget);

    await tester.tap(find.text('Todas'));
    await tester.pump();
    expect(find.byType(ApplicantCard), findsNWidgets(3));
  });

  testWidgets('Aceptar ocupa un cupo, guarda la decisión y avisa',
      (WidgetTester tester) async {
    when(() => repository.getApplicant('a-1')).thenAnswer((_) async => ana);
    when(() => repository.setFilledSpots(any(), any()))
        .thenAnswer((_) async {});
    when(() => repository.setStatus(any(), any())).thenAnswer((_) async {});
    await pumpList(tester);

    await tester.tap(inCard('a-1', find.text('Aceptar')));
    await tester.pumpAndSettle();

    verify(() => repository.setFilledSpots(any(), 2)).called(1);
    verify(() => repository.setStatus(ana, ApplicantStatus.accepted))
        .called(1);
    expect(find.text('Ana Torres fue aceptado/a'), findsOneWidget);
    expect(inCard('a-1', find.text('Aceptado')), findsOneWidget);
    expect(find.text('Aceptadas (2)'), findsOneWidget);
    expect(find.text('1 cupos disponibles (2 de 3 cupos)'), findsOneWidget);
  });

  testWidgets('Rechazar guarda la decisión sin ocupar cupo',
      (WidgetTester tester) async {
    when(() => repository.getApplicant('a-2')).thenAnswer((_) async => pedro);
    when(() => repository.setStatus(any(), any())).thenAnswer((_) async {});
    await pumpList(tester);

    await tester.tap(inCard('a-2', find.text('Rechazar')));
    await tester.pumpAndSettle();

    verify(() => repository.setStatus(pedro, ApplicantStatus.rejected))
        .called(1);
    verifyNever(() => repository.setFilledSpots(any(), any()));
    expect(find.text('Pedro Gómez fue rechazado/a'), findsOneWidget);
    expect(find.text('Rechazadas (1)'), findsOneWidget);
  });

  testWidgets('sin cupos se indica en otro color y Aceptar queda inactivo',
      (WidgetTester tester) async {
    when(() => repository.getProject(projectId))
        .thenAnswer((_) async => buildIdea(filledSpots: 3, totalSpots: 3));
    await pumpList(tester);

    final full =
        find.text('Cupos completos (3 de 3 cupos)').evaluate().first.widget
            as Text;
    expect(full.style!.color, equals(NodoColors.primaryDark));

    await tester.tap(inCard('a-1', find.text('Aceptar')));
    await tester.pump();

    verifyNever(() => repository.getApplicant(any()));
    verifyNever(() => repository.setStatus(any(), any()));
  });

  testWidgets('si la carga falla muestra el error y permite reintentar',
      (WidgetTester tester) async {
    when(() => repository.getApplicantsByProject(projectId))
        .thenThrow(Exception('sin red'));
    await pumpList(tester);

    expect(
      find.text('Ocurrió un error inesperado. Intenta de nuevo.'),
      findsOneWidget,
    );
    expect(find.byType(ApplicantCard), findsNothing);

    when(() => repository.getApplicantsByProject(projectId))
        .thenAnswer((_) async => [ana]);
    await tester.tap(find.widgetWithText(FilledButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(ApplicantCard), findsOneWidget);
  });
}
