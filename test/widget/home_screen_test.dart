import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/auth/presentation/screens/login_screen.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/domain/usecases/get_categories.dart';
import 'package:nodo/features/home/domain/usecases/get_ideas.dart';
import 'package:nodo/features/home/presentation/screens/home_screen.dart';
import 'package:nodo/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:nodo/features/home/presentation/widgets/category_filter.dart';
import 'package:nodo/features/home/presentation/widgets/idea_card.dart';
import 'package:provider/provider.dart';

import 'support/harness.dart';

void main() {
  final recycling = buildIdea(id: 'p-1', title: 'App de reciclaje');
  final garden = buildIdea(id: 'p-2', title: 'Huerta urbana');
  const categories = ['TODAS', 'TECNOLOGÍA', 'DISEÑO'];

  late MockIdeaRepository repository;
  late HomeViewModel viewModel;

  setUp(() {
    repository = MockIdeaRepository();
    viewModel = HomeViewModel(
      getIdeas: GetIdeas(repository),
      getCategories: GetCategories(repository),
    );
    when(() => repository.getCategories()).thenAnswer((_) async => categories);
    when(() => repository.getIdeas(category: 'TODAS'))
        .thenAnswer((_) async => [recycling, garden]);
  });

  /// Home en sesión pública (invitado), con el ViewModel inyectado.
  Future<void> pumpHome(WidgetTester tester, {bool settle = true}) async {
    useTallScreen(tester);
    final AuthViewModel auth = await authWith(null);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: auth,
        child: MaterialApp(home: HomeScreen(viewModel: viewModel)),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  testWidgets('muestra un indicador mientras carga el feed',
      (WidgetTester tester) async {
    final pending = Completer<List<String>>();
    when(() => repository.getCategories()).thenAnswer((_) => pending.future);

    await pumpHome(tester, settle: false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(IdeaCard), findsNothing);

    pending.complete(categories);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('muestra encabezado, buscador, filtros y una tarjeta por idea',
      (WidgetTester tester) async {
    await pumpHome(tester);

    expect(find.text('Nodo'), findsOneWidget);
    expect(
      find.text('Proyectos del campus para unirte o crear el tuyo'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(CategoryFilter), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(categories.length));
    expect(find.byType(IdeaCard), findsNWidgets(2));
    expect(find.byKey(const ValueKey('idea-card-p-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('idea-card-p-2')), findsOneWidget);
    expect(find.text('App de reciclaje'), findsOneWidget);
  });

  testWidgets('el título de la app usa tipografía grande y gruesa',
      (WidgetTester tester) async {
    await pumpHome(tester);

    final title = find.text('Nodo').evaluate().first.widget as Text;
    expect(title.style!.fontSize, greaterThan(30));
    expect(title.style!.fontWeight, equals(FontWeight.w800));
    expect(title.style!.color, equals(NodoColors.textPrimary));
  });

  testWidgets('la categoría seleccionada se pinta con texto blanco',
      (WidgetTester tester) async {
    await pumpHome(tester);

    final selected = find.text('TODAS').evaluate().first.widget as Text;
    final unselected = find
        .descendant(
          of: find.byType(CategoryFilter),
          matching: find.text('DISEÑO'),
        )
        .evaluate()
        .first
        .widget as Text;

    expect(selected.style!.color, equals(Colors.white));
    expect(unselected.style!.color, equals(NodoColors.textPrimary));
  });

  testWidgets('buscar filtra las tarjetas y la X limpia la búsqueda',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'reciclaje');
    await tester.pump();

    expect(find.byKey(const ValueKey('idea-card-p-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('idea-card-p-2')), findsNothing);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.byType(IdeaCard), findsNWidgets(2));
  });

  testWidgets('una búsqueda sin coincidencias muestra el estado vacío',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'astronomía');
    await tester.pump();

    expect(find.byType(IdeaCard), findsNothing);
    expect(find.text('Sin resultados para “astronomía”'), findsOneWidget);
  });

  testWidgets('tocar una categoría pide las ideas de esa categoría',
      (WidgetTester tester) async {
    when(() => repository.getIdeas(category: 'DISEÑO'))
        .thenAnswer((_) async => [garden]);
    await pumpHome(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'DISEÑO'));
    await tester.pumpAndSettle();

    verify(() => repository.getIdeas(category: 'DISEÑO')).called(1);
    expect(find.byType(IdeaCard), findsOneWidget);
    expect(find.text('Huerta urbana'), findsOneWidget);
    final chip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'DISEÑO'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('si falla la carga muestra el error y Reintentar recupera',
      (WidgetTester tester) async {
    when(() => repository.getCategories()).thenThrow(Exception('sin red'));
    await pumpHome(tester);

    expect(
      find.text('No se pudo cargar el feed. Revisa tu conexión.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Reintentar'), findsOneWidget);

    when(() => repository.getCategories()).thenAnswer((_) async => categories);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(IdeaCard), findsNWidgets(2));
  });

  testWidgets('el botón de notificaciones abre y cierra la bandeja',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Notificaciones'));
    await tester.pumpAndSettle();
    expect(find.text('Bandeja de notificaciones'), findsOneWidget);

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.text('Bandeja de notificaciones'), findsNothing);
  });

  testWidgets('un invitado que toca + recibe aviso y va al login',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('Inicia sesión para crear un proyecto'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('un invitado que toca Perfil va al login',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
