import 'package:roble/roble.dart';

import '../../../../env/env.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.roble);

  final RobleApiDataBase roble;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
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
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await logout();
    try {
      await roble.register(email: email, password: password, name: name);
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
    if (Env.hasGuestCredentials) {
      try {
        await roble.login(
          email: Env.guestEmail,
          password: Env.guestPassword,
        );
        return;
      } catch (_) {
        // Si falla el guest configurado, intenta sesión anónima de Roble.
      }
    }
    try {
      await roble.signInAnonymously();
    } catch (_) {
      // Sin sesión pública si Roble no permite anónimos.
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

  @override
  Future<User?> restoreOrGuest() async {
    try {
      final restored = await roble.restoreSession();
      if (restored) {
        return currentUser();
      }
    } catch (_) {
      // Continúa con sesión pública.
    }

    await signInAsGuest();
    return currentUser();
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
      isGuest: profile.email == Env.guestEmail ||
          profile.role == 'readonly' ||
          profile.role == 'anonymous' ||
          profile.email.isEmpty,
    );
  }

  String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
