import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nodo/main.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/data/datasources/mock_idea_datasource.dart';
import 'package:nodo/features/home/data/repositories/idea_repository_impl.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';
import 'package:nodo/features/home/domain/usecases/get_categories.dart';
import 'package:nodo/features/home/presentation/viewmodels/home_view_model.dart';

import 'support/fake_auth.dart';
import 'support/seed.dart';

void main() {
  Future<Widget> createTestApp() async {
    final ideaRepository = IdeaRepositoryImpl(MockIdeaDataSource());
    final getIdeas = GetIdeas(ideaRepository);
    final getCategories = GetCategories(ideaRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: await authFor(guest)),
        Provider<HomeViewModel Function()>(
          create: (_) => () => HomeViewModel(
                getIdeas: getIdeas,
                getCategories: getCategories,
              ),
        ),
      ],
      child: const NodoApp(),
    );
  }

  testWidgets('Home muestra título Únete y feed', (tester) async {
    await tester.pumpWidget(await createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Únete'), findsOneWidget);
    expect(
      find.text('Explora ideas en crecimiento o siembra la tuya'),
      findsOneWidget,
    );
    expect(find.text('TODAS'), findsOneWidget);
    expect(find.text('Huerta urbana colaborativa'), findsOneWidget);
    expect(find.text('Asistente de estudio con IA'), findsOneWidget);
  });

  testWidgets('Filtrar por categoría actualiza el feed', (tester) async {
    await tester.pumpWidget(await createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilterChip, 'TECNOLOGÍA'));
    await tester.pumpAndSettle();

    expect(find.text('Asistente de estudio con IA'), findsOneWidget);
    expect(find.text('Huerta urbana colaborativa'), findsNothing);
  });

  testWidgets('Crear proyecto como invitado lleva al login', (tester) async {
    await tester.pumpWidget(await createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Accede con tu cuenta específica'), findsOneWidget);
  });
}
