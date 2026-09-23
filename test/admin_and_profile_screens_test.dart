import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';
import 'package:nodo/features/application/presentation/screens/project_detail_admin_screen.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/data/datasources/mock_idea_datasource.dart';
import 'package:nodo/features/home/data/repositories/idea_repository_impl.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';
import 'package:nodo/features/home/presentation/screens/profile_screen.dart';

import 'support/applicants.dart';
import 'support/fake_auth.dart';
import 'support/seed.dart';

Widget _wrap(Widget child, AuthViewModel auth) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthViewModel>.value(value: auth),
      Provider<GetIdeas>.value(
        value: GetIdeas(IdeaRepositoryImpl(MockIdeaDataSource())),
      ),
      Provider<ApplicantsViewModel Function(String, User?)>.value(
        value: applicantsViewModelFactory(seededDatabase()),
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

    await tester.tap(find.text('Ver Postulaciones'));
    await tester.pumpAndSettle();

    expect(find.text('2 postulaciones recibidas'), findsOneWidget);
  });

  testWidgets('ProfileView lista solo los proyectos del usuario', (
    tester,
  ) async {
    const owner = User(
      id: MockIdeaDataSource.demoCreatorId,
      name: 'Carlos Eduardo',
      email: 'carlos@uni.edu',
    );
    final auth = await authFor(owner);
    await tester.pumpWidget(_wrap(const ProfileView(), auth));
    await tester.pumpAndSettle();

    expect(find.text('Mi Perfil'), findsOneWidget);
    expect(find.text('Carlos Eduardo'), findsWidgets);
    expect(find.text('Huerta urbana colaborativa'), findsOneWidget);
    // Idea de otro creador: no aparece.
    expect(find.text('Marketplace de freelancers universitarios'), findsNothing);
    expect(find.text('Admin'), findsWidgets);
    expect(find.text('3 de 6 cupos'), findsOneWidget);
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
