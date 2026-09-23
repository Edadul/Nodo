import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/applicants/data/datasources/mock_applicant_datasource.dart';
import 'package:nodo/features/application/presentation/screens/project_detail_admin_screen.dart';
import 'package:nodo/features/home/data/datasources/mock_idea_datasource.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';
import 'package:nodo/features/home/presentation/screens/profile_screen.dart';

import 'package:nodo/features/home/data/repositories/idea_repository_impl.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/usecases/get_applicants.dart';
import 'package:nodo/features/applicants/domain/usecases/update_applicant_status.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';

Widget _wrap(Widget child) {
  // Home deps
  final mockIdeaDataSource = MockIdeaDataSource();
  final ideaRepository = IdeaRepositoryImpl(mockIdeaDataSource);
  final getIdeas = GetIdeas(ideaRepository);

  // Applicants deps
  final mockApplicantDataSource = MockApplicantDataSource();
  final applicantRepository = ApplicantRepositoryImpl(mockApplicantDataSource);
  final getApplicants = GetApplicants(applicantRepository);
  final updateApplicantStatus = UpdateApplicantStatus(applicantRepository);

  return MultiProvider(
    providers: [
      Provider<GetIdeas>.value(value: getIdeas),
      Provider<ApplicantsViewModel Function(int)>.value(
        value: (int projectId) => ApplicantsViewModel(
          projectId: projectId,
          getApplicants: getApplicants,
          updateApplicantStatus: updateApplicantStatus,
        ),
      ),
    ],
    child: MaterialApp(
      theme: buildNodoTheme(),
      home: child,
    ),
  );
}

void main() {


  const testIdea = Idea(
    id: '1',
    title: 'Plataforma Estudiantil',
    description: 'Conectando perfiles técnicos, creativos y de negocios.',
    category: 'TECNOLOGÍA',
    skills: ['Flutter', 'Diseño UI/UX'],
    filledSpots: 2,
    totalSpots: 6,
    gradientColors: [0xFF7B6CF0, 0xFFB8A9FF],
  );

  testWidgets('ProjectDetailAdminScreen renders stages, admin cards and navigates to applicants', (tester) async {
    await tester.pumpWidget(_wrap(const ProjectDetailAdminScreen(idea: testIdea)));
    await tester.pumpAndSettle();

    // Verify header and mode chip
    expect(find.text('Modo Creador'), findsOneWidget);
    expect(find.text('TECNOLOGÍA'), findsOneWidget);

    // Verify stage chips
    expect(find.text('Idea'), findsOneWidget);
    expect(find.text('Desarrollo'), findsOneWidget);
    expect(find.text('Cierre'), findsOneWidget);

    // Verify title and description
    expect(find.text('Plataforma Estudiantil'), findsOneWidget);
    expect(find.text('Conectando perfiles técnicos, creativos y de negocios.'), findsOneWidget);

    // Verify admin cards
    expect(find.text('Postulaciones'), findsWidgets);
    expect(find.text('Equipo del Proyecto'), findsOneWidget);
    expect(find.text('2 de 6 cupos'), findsOneWidget);

    // Tap "Ver Postulaciones" and verify navigation to ApplicantsListScreen
    await tester.tap(find.text('Ver Postulaciones'));
    await tester.pumpAndSettle();

    expect(find.text('8 postulaciones recibidas'), findsOneWidget);
  });

  testWidgets('ProfileView renders profile info, projects tab and admin entry points', (tester) async {
    await tester.pumpWidget(_wrap(const ProfileView()));
    await tester.pumpAndSettle();

    // Verify profile header info
    expect(find.text('Mi Perfil'), findsOneWidget);
    expect(find.text('Carlos Eduardo'), findsOneWidget);
    expect(find.text('Mis Proyectos'), findsOneWidget);
    expect(find.text('Preferencias'), findsOneWidget);

    // Verify project list loaded from mock
    expect(find.text('Huerta urbana colaborativa'), findsOneWidget);
    expect(find.text('Admin'), findsWidgets);
  });
}
