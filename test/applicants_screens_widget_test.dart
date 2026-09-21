import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/applicants/data/datasources/mock_applicant_datasource.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/usecases/get_applicants.dart';
import 'package:nodo/features/applicants/domain/usecases/update_applicant_status.dart';
import 'package:nodo/features/applicants/presentation/screens/applicants_list_screen.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: buildNodoTheme(), home: child);
}

ApplicantsViewModel _buildViewModel() {
  final repository = ApplicantRepositoryImpl(MockApplicantDataSource());
  return ApplicantsViewModel(
    getApplicants: GetApplicants(repository),
    updateApplicantStatus: UpdateApplicantStatus(repository),
    projectId: 1,
  );
}

void main() {
  testWidgets('ApplicantsListScreen muestra el listado y los filtros', (
    tester,
  ) async {
    final viewModel = _buildViewModel();
    await tester.pumpWidget(
      _wrap(
        ApplicantsListScreen(projectId: 1, viewModel: viewModel),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Postulaciones'), findsOneWidget);
    expect(find.text('8 postulaciones recibidas'), findsOneWidget);
    expect(find.text('María García'), findsOneWidget);
    expect(find.text('Pendientes (5)'), findsOneWidget);
    expect(find.text('Aceptadas (2)'), findsOneWidget);
    expect(find.text('Rechazadas (1)'), findsOneWidget);
  });

  testWidgets('Aceptar en la tarjeta actualiza el estado', (tester) async {
    final viewModel = _buildViewModel();
    await tester.pumpWidget(
      _wrap(ApplicantsListScreen(projectId: 1, viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aceptar').first);
    await tester.pumpAndSettle();

    expect(viewModel.countFor(ApplicantsFilter.accepted), 3);
  });

  testWidgets('Ver más detalle navega al perfil del postulante', (
    tester,
  ) async {
    final viewModel = _buildViewModel();
    await tester.pumpWidget(
      _wrap(ApplicantsListScreen(projectId: 1, viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver más detalle').first);
    await tester.pumpAndSettle();

    expect(find.text('Perfil del postulante'), findsOneWidget);
    expect(find.text('María García'), findsOneWidget);
    expect(find.text('Universidad de Chile'), findsOneWidget);
    expect(find.text('MENSAJE DE MOTIVACIÓN'), findsOneWidget);
  });
}
