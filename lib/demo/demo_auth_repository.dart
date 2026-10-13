import '../features/auth/domain/entities/user.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import 'demo_mode.dart';

/// Auth local para preview UI (sin Roble).
class DemoAuthRepository implements AuthRepository {
  User? _current = const User(
    id: kDemoCreatorId,
    name: kDemoCreatorName,
    email: kDemoCreatorEmail,
  );

  @override
  Future<User?> restoreOrGuest() async => _current;

  @override
  Future<User?> currentUser() async => _current;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    _current = User(
      id: kDemoCreatorId,
      name: email.split('@').first,
      email: email,
    );
    return _current!;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _current = User(
      id: kDemoCreatorId,
      name: name,
      email: email,
    );
    return _current!;
  }

  @override
  Future<void> logout() async {
    _current = const User(
      id: 'guest-demo',
      name: 'Invitado',
      email: 'guest@nodo.demo',
      isGuest: true,
    );
  }

  @override
  Future<void> signInAsGuest() async {
    _current = const User(
      id: 'guest-demo',
      name: 'Invitado',
      email: 'guest@nodo.demo',
      isGuest: true,
    );
  }
}
