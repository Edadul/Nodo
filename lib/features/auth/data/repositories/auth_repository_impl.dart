import 'package:roble/roble.dart';

import '../../../../env/env.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RobleApiDataBase roble;

  AuthRepositoryImpl(this.roble);

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // La sesión pública (guest) se cierra antes de abrir la del usuario
    // específico, tal y como se exige. Si el login falla, se restaura la
    // sesión pública para que la app siga funcionando como invitado.
    await logout();

    try {
      final userMap = await roble.login(email: email, password: password);
      return _mapUser(userMap);
    } catch (e) {
      await signInAsGuest();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await roble.logout();
    } catch (_) {
      // No hay sesión activa para cerrar.
    }
  }

  @override
  Future<void> signInAsGuest() async {
    try {
      await roble.login(
        email: Env.guestEmail,
        password: Env.guestPassword,
      );
    } catch (_) {
      // Si no se puede restaurar la sesión pública, se queda sin sesión.
    }
  }

  @override
  Future<User?> currentUser() async {
    try {
      final userMap = await roble.currentUser();
      return _mapUser(userMap);
    } catch (_) {
      return null;
    }
  }

  User _mapUser(Map<String, dynamic> userMap) {
    final profile = RobleUser.fromJson(userMap);
    final extra = profile.extra ?? const <String, dynamic>{};
    return User(
      id: profile.userId.isNotEmpty ? profile.userId : (profile.id ?? ''),
      name: profile.name.isNotEmpty
          ? profile.name
          : (profile.email.isNotEmpty ? profile.email : 'Usuario'),
      email: profile.email,
      avatarUrl: _text(extra['avatar']) ?? _text(userMap['avatar']) ?? '',
      isGuest: profile.email == Env.guestEmail || profile.role == 'readonly',
    );
  }

  String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}