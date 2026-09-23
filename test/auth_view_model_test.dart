import 'package:flutter_test/flutter_test.dart';

import 'package:nodo/env/env.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/domain/repositories/auth_repository.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';

class FakeAuthRepository implements AuthRepository {
  bool failLogin = false;
  int loginCalls = 0;
  int logoutCalls = 0;
  User? current;

  User get fakeUser => User(
        id: 'u1',
        name: 'Ana García',
        email: 'ana@correo.com',
        avatarUrl: '',
      );

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    if (failLogin) throw Exception('Invalid credentials');
    current = User(
      id: 'u1',
      name: 'Ana García',
      email: email,
      avatarUrl: '',
    );
    return current!;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    current = null;
  }

  @override
  Future<void> signInAsGuest() async {
    current = null;
  }

  @override
  Future<User?> currentUser() async => current;
}

void main() {
  group('AuthViewModel', () {
    test('login exitoso actualiza el usuario y limpia los campos', () async {
      final repository = FakeAuthRepository();
      final vm = AuthViewModel(repository: repository);

      vm.setEmail('ana@correo.com');
      vm.setPassword('MiClave!1');

      final user = await vm.login();

      expect(user, isNotNull);
      expect(user!.email, 'ana@correo.com');
      expect(user.name, 'Ana García');
      expect(vm.currentUser?.id, 'u1');
      expect(vm.email, '');
      expect(vm.password, '');
      expect(vm.error, isNull);
      expect(vm.isLoading, isFalse);
      expect(vm.isPublicSession, isFalse);
    });

    test('credenciales vacías devuelven null y marcan error', () async {
      final vm = AuthViewModel(repository: FakeAuthRepository());

      final user = await vm.login();

      expect(user, isNull);
      expect(vm.error, isNotNull);
      expect(vm.isLoading, isFalse);
    });

    test('login fallido devuelve null con mensaje amigable', () async {
      final repository = FakeAuthRepository()..failLogin = true;
      final vm = AuthViewModel(repository: repository);

      vm.setEmail('ana@correo.com');
      vm.setPassword('incorrecta');

      final user = await vm.login();

      expect(user, isNull);
      expect(vm.currentUser, isNull);
      expect(vm.error, contains('Credenciales incorrectas'));
      expect(vm.isLoading, isFalse);
    });

    test('isPublicSession es true para la sesión invitado', () async {
      final repository = FakeAuthRepository();
      final vm = AuthViewModel(repository: repository);

      vm.setEmail(Env.guestEmail);
      vm.setPassword('x');
      await vm.login();

      expect(vm.isPublicSession, isTrue);
    });

    test('logout limpia el usuario actual', () async {
      final repository = FakeAuthRepository();
      final vm = AuthViewModel(repository: repository);

      vm.setEmail('ana@correo.com');
      vm.setPassword('MiClave!1');
      await vm.login();
      expect(vm.currentUser, isNotNull);

      await vm.logout();

      expect(vm.currentUser, isNull);
      expect(repository.logoutCalls, 1);
    });
  });
}