import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});

  Future<User> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> logout();

  Future<void> signInAsGuest();

  Future<User?> currentUser();

  /// Restaura sesión persistida; si no hay, entra como invitado.
  Future<User?> restoreOrGuest();
}
