import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nodo/core/services/catalog_service.dart';
import 'package:nodo/core/services/user_profile_service.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/applicants/data/datasources/api_applicant_datasource.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/usecases/get_project_team.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';
import 'package:nodo/features/application/data/datasources/api_application_datasource.dart';
import 'package:nodo/features/application/data/repositories/application_repository_impl.dart';
import 'package:nodo/features/application/domain/usecases/get_my_participations.dart';
import 'package:nodo/features/application/presentation/screens/project_detail_admin_screen.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'support/fake_idea_datasource.dart';
import 'package:nodo/features/home/data/repositories/idea_repository_impl.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';
import 'package:nodo/features/home/presentation/screens/profile_screen.dart';

import 'support/applicants.dart';
import 'support/fake_auth.dart';
import 'support/fake_database.dart';
import 'support/seed.dart';

Widget _wrap(Widget child, AuthViewModel auth, {FakeDatabase? db}) {
  final database = db ?? seededDatabase();
  final getIdeas = GetIdeas(IdeaRepositoryImpl(FakeIdeaDataSource()));
  final applications = ApplicationRepositoryImpl(
    ApiApplicationDataSource(
      database,
      CatalogService(database),
      UserProfileService(database),
    ),
  );
  final applicants = ApplicantRepositoryImpl(
    ApiApplicantDataSource(database, CatalogService(database)),
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: auth),
      Provider<GetIdeas>.value(value: getIdeas),
      Provider<GetMyParticipations>.value(
        value: GetMyParticipations(applications, getIdeas),
      ),
      Provider<GetProjectTeam>.value(value: GetProjectTeam(applicants)),
      Provider<ApplicantsViewModel Function(String, User?)>.value(
        value: applicantsViewModelFactory(database),
      ),
    ],
    child: MaterialApp(theme: buildNodoTheme(), home: child),
  );
}

void main() {
  const seededIdea = Idea(
    id: projectId,
    title: 'Plataforma Nodo',
    description: 'Conectar estudiantes con proyectos colaborativos.',
    categories: ['TECNOLOGÍA'],
    skills: ['FLUTTER'],
    filledSpots: 0,
    totalSpots: 2,
    creatorId: 'u-creator',
    gradientColors: [0xFF7B6CF0, 0xFFB8A9FF],
  );

  testWidgets('ProjectDetailAdminScreen navega a las postulaciones reales', (
    tester,
  ) async {
    final auth = await authFor(creator);
    await tester.pumpWidget(
      _wrap(const ProjectDetailAdminScreen(idea: seededIdea), auth),
    );
    await tester.pumpAndSettle();

    expect(find.text('Modo Creador'), findsOneWidget);
    expect(find.text('TECNOLOGÍA'), findsOneWidget);
    expect(find.text('Plataforma Nodo'), findsOneWidget);
    expect(find.text('0 de 2 cupos'), findsOneWidget);
    expect(find.text('Equipo'), findsOneWidget);
    expect(find.text('Avances del proyecto'), findsOneWidget);

    await tester.tap(find.text('Postulaciones').last);
    await tester.pumpAndSettle();

    expect(find.text('2 postulaciones recibidas'), findsOneWidget);
  });

  testWidgets('ProfileView lista solo los proyectos del usuario', (
    tester,
  ) async {
    const owner = User(
      id: FakeIdeaDataSource.demoCreatorId,
      name: 'Carlos Eduardo',
      email: 'carlos@uni.edu',
    );
    final auth = await authFor(owner);
    await tester.pumpWidget(_wrap(const ProfileView(), auth));
    await tester.pumpAndSettle();

    expect(find.text('Mi perfil'), findsOneWidget);
    expect(find.text('Carlos Eduardo'), findsWidgets);
    expect(find.text('Huerta urbana colaborativa'), findsOneWidget);
    // Idea de otro creador: no aparece.
    expect(find.text('Marketplace de freelancers universitarios'), findsNothing);
    expect(find.text('Postulaciones'), findsWidgets);
    expect(find.text('3 de 6 cupos'), findsOneWidget);
    expect(find.text('Creados'), findsOneWidget);
    expect(find.text('Unidos'), findsOneWidget);
  });

  testWidgets('ProfileView en sesión pública no muestra proyectos ajenos', (
    tester,
  ) async {
    final auth = await authFor(guest);
    await tester.pumpWidget(_wrap(const ProfileView(), auth));
    await tester.pumpAndSettle();

    expect(find.text('Huerta urbana colaborativa'), findsNothing);
    expect(
      find.text('Inicia sesión para crear y administrar proyectos'),
      findsOneWidget,
    );
  });
}
