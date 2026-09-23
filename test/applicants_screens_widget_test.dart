import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/applicants/presentation/screens/applicants_list_screen.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';

import 'support/applicants.dart';
import 'support/fake_database.dart';
import 'support/seed.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: buildNodoTheme(), home: child);
}

void main() {
  late FakeDatabase db;
  late ApplicantsViewModel viewModel;

  setUp(() {
    db = seededDatabase();
    viewModel = applicantsViewModelFactory(db)(projectId, creator);
  });

  Future<void> pumpList(WidgetTester tester) async {
    await tester.pumpWidget(
      _wrap(ApplicantsListScreen(projectId: projectId, viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra listado, filtros y cupos', (tester) async {
    await pumpList(tester);

    expect(find.text('Postulaciones'), findsOneWidget);
    expect(find.text('2 postulaciones recibidas'), findsOneWidget);
    expect(find.text('2 cupos disponibles (0 de 2 cupos)'), findsOneWidget);
    expect(find.text(applicantUser.name), findsOneWidget);
    expect(find.text('Pendientes (2)'), findsOneWidget);
    expect(find.text('Aceptadas (0)'), findsOneWidget);
  });

  testWidgets('Aceptar en la tarjeta persiste y ocupa cupo', (tester) async {
    await pumpList(tester);

    await tester.tap(find.text('Aceptar').first);
    await tester.pumpAndSettle();

    expect(viewModel.countFor(ApplicantsFilter.accepted), 1);
    expect(db.rows('projects').single['filled_spots'], 1);
    expect(find.text('1 cupos disponibles (1 de 2 cupos)'), findsOneWidget);
  });

  testWidgets('sin cupos el botón Aceptar no hace nada', (tester) async {
    db = seededDatabase(filledSpots: 2, totalSpots: 2);
    viewModel = applicantsViewModelFactory(db)(projectId, creator);
    await pumpList(tester);

    expect(find.text('Cupos completos (2 de 2 cupos)'), findsOneWidget);
    await tester.tap(find.text('Aceptar').first);
    await tester.pumpAndSettle();
    expect(
      db.rows('applications').every((a) => a['status'] == 'pending'),
      isTrue,
    );
  });

  testWidgets('Ver más detalle navega al perfil y permite decidir', (
    tester,
  ) async {
    await pumpList(tester);

    await tester.tap(find.text('Ver más detalle').last);
    await tester.pumpAndSettle();

    expect(find.text('Perfil del postulante'), findsOneWidget);
    expect(find.text(applicantUser.name), findsOneWidget);
    expect(find.text('Uninorte'), findsOneWidget);
    expect(find.text('1 a 2 años'), findsOneWidget);

    await tester.tap(find.text('Rechazar'));
    await tester.pumpAndSettle();

    expect(viewModel.findById('a-luis')!.status, ApplicantStatus.rejected);
    expect(find.text('Perfil del postulante'), findsNothing);
  });
}
