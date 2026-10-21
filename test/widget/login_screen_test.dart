import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/presentation/screens/login_screen.dart';
import 'package:nodo/features/auth/presentation/screens/register_screen.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

import 'support/harness.dart';

void main() {
  const emailField = Key('login-email');
  const passwordField = Key('login-password');
  const submitButton = Key('login-submit');

  late MockAuthRepository repository;
  late AuthViewModel auth;

  setUp(() {
    repository = MockAuthRepository();
    auth = AuthViewModel(repository: repository);
  });

  /// Abre el login sobre una pantalla base para poder comprobar el `pop`.
  Future<void> pumpLogin(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: auth,
        child: launcher(screen: () => const LoginScreen()),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Future<void> fillCredentials(WidgetTester tester) async {
    await tester.enterText(find.byKey(emailField), 'ana@nodo.test');
    await tester.enterText(find.byKey(passwordField), 'secreta123');
  }

  testWidgets('muestra el formulario de inicio de sesión',
      (WidgetTester tester) async {
    await pumpLogin(tester);

    // Título y texto del botón.
    expect(find.text('Iniciar sesión'), findsNWidgets(2));
    expect(find.text('Entra para postularte o crear proyectos'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byKey(emailField), findsOneWidget);
    expect(find.byKey(passwordField), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
  });

  testWidgets('el título es grande y la contraseña se oculta',
      (WidgetTester tester) async {
    await pumpLogin(tester);

    final title = find.text('Iniciar sesión').evaluate().first.widget as Text;
    expect(title.style!.fontSize, greaterThan(24));
    expect(title.style!.fontWeight, equals(FontWeight.w900));

    final password = find.byKey(passwordField).evaluate().first.widget
        as TextField;
    expect(password.obscureText, isTrue);
  });

  testWidgets('enviar vacío muestra el error en rojo sin llamar a la API',
      (WidgetTester tester) async {
    await pumpLogin(tester);

    await tester.tap(find.byKey(submitButton));
    await tester.pump();

    final error = find.text('Ingresa tu correo y contraseña');
    expect(error, findsOneWidget);
    final errorText = error.evaluate().first.widget as Text;
    expect(errorText.style!.color, equals(Colors.redAccent));
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('escribir de nuevo borra el error', (WidgetTester tester) async {
    await pumpLogin(tester);
    await tester.tap(find.byKey(submitButton));
    await tester.pump();
    expect(find.text('Ingresa tu correo y contraseña'), findsOneWidget);

    await tester.enterText(find.byKey(emailField), 'a');
    await tester.pump();

    expect(find.text('Ingresa tu correo y contraseña'), findsNothing);
  });

  testWidgets('mientras inicia sesión muestra un indicador y bloquea el botón',
      (WidgetTester tester) async {
    final pending = Completer<User>();
    when(() => repository.login(email: 'ana@nodo.test', password: 'secreta123'))
        .thenAnswer((_) => pending.future);
    await pumpLogin(tester);
    await fillCredentials(tester);

    await tester.tap(find.byKey(submitButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = find.byKey(submitButton).evaluate().first.widget
        as ElevatedButton;
    expect(button.onPressed, isNull);

    pending.complete(buildUser());
    await tester.pumpAndSettle();
  });

  testWidgets('credenciales válidas inician sesión y cierran la pantalla',
      (WidgetTester tester) async {
    final user = buildUser();
    when(() => repository.login(email: 'ana@nodo.test', password: 'secreta123'))
        .thenAnswer((_) async => user);
    await pumpLogin(tester);
    await fillCredentials(tester);

    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
    expect(auth.currentUser, same(user));
  });

  testWidgets('credenciales inválidas muestran un mensaje amigable',
      (WidgetTester tester) async {
    when(() => repository.login(email: 'ana@nodo.test', password: 'secreta123'))
        .thenThrow(Exception('401 Unauthorized'));
    await pumpLogin(tester);
    await fillCredentials(tester);

    await tester.tap(find.byKey(submitButton));
    await tester.pumpAndSettle();

    expect(
      find.text('Credenciales incorrectas. Verifica tu correo y contraseña.'),
      findsOneWidget,
    );
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('el enlace de registro reemplaza el login por el registro',
      (WidgetTester tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
