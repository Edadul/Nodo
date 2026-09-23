import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nodo/core/services/catalog_service.dart';
import 'package:nodo/core/services/user_profile_service.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/application/data/datasources/api_application_datasource.dart';
import 'package:nodo/features/application/data/repositories/application_repository_impl.dart';
import 'package:nodo/features/application/domain/usecases/get_my_application.dart';
import 'package:nodo/features/application/presentation/screens/project_detail_screen.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/domain/entities/idea.dart';

import 'support/fake_auth.dart';
import 'support/fake_database.dart';
import 'support/seed.dart';

Idea _idea({int filled = 0, int total = 2}) => Idea(
      id: projectId,
      title: 'Plataforma Nodo',
      description: 'Conectar estudiantes con proyectos colaborativos.',
      categories: const ['TECNOLOGÍA'],
      skills: const ['FLUTTER'],
      filledSpots: filled,
      totalSpots: total,
      creatorId: creator.id,
      gradientColors: const [0xFF7B6CF0, 0xFFB8A9FF],
    );

void main() {
  Future<void> pump(WidgetTester tester, User? user, {Idea? idea}) async {
    final FakeDatabase db = seededDatabase();
    final repository = ApplicationRepositoryImpl(
      ApiApplicationDataSource(db, CatalogService(db), UserProfileService(db)),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthViewModel>.value(value: await authFor(user)),
          Provider<GetMyApplication>.value(value: GetMyApplication(repository)),
        ],
        child: MaterialApp(
          theme: buildNodoTheme(),
          home: ProjectDetailScreen(idea: idea ?? _idea()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const newUser = User(id: 'u-new', name: 'Nueva', email: 'nueva@uni.edu');

  testWidgets('invitado debe iniciar sesión', (tester) async {
    await pump(tester, guest);
    expect(find.text('Inicia sesión para postularte'), findsOneWidget);
  });

  testWidgets('el creador administra en vez de postularse', (tester) async {
    await pump(tester, creator);
    expect(find.text('Administrar proyecto'), findsOneWidget);
    expect(find.text('Postularme'), findsNothing);
  });

  testWidgets('quien ya se postuló ve su estado', (tester) async {
    await pump(tester, applicantUser);
    expect(find.text('Postulación enviada · Pendiente'), findsOneWidget);
  });

  testWidgets('usuario nuevo puede postularse si hay cupos', (tester) async {
    await pump(tester, newUser);
    expect(find.text('Postularme'), findsOneWidget);

    await pump(tester, newUser, idea: _idea(filled: 2, total: 2));
    expect(find.text('Sin cupos disponibles'), findsOneWidget);
  });
}
