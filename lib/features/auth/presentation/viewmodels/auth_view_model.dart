import 'package:flutter/material.dart';

import '../../../../env/env.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required this.repository});

  final AuthRepository repository;

  String email = '';
  String password = '';
  String name = '';

  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  bool _bootstrapped = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  bool get isBootstrapped => _bootstrapped;

  /// `true` cuando la sesión activa es la pública (invitado) o no hay sesión.
  bool get isPublicSession =>
      _currentUser == null ||
      _currentUser!.isGuest ||
      _currentUser!.email == Env.guestEmail;

  /// Usuario con cuenta propia, o `null` en sesión pública.
  User? get signedInUser => isPublicSession ? null : _currentUser;

  void setEmail(String v) {
    email = v.trim();
    _clearError();
  }

  void setPassword(String v) {
    password = v;
    _clearError();
  }

  void setName(String v) {
    name = v.trim();
    _clearError();
  }

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _setLoading(true);
    try {
      _currentUser = await repository.restoreOrGuest();
      _bootstrapped = true;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    _currentUser = await repository.currentUser();
    notifyListeners();
  }

  Future<User?> login() async {
    if (email.isEmpty || password.isEmpty) {
      _error = 'Ingresa tu correo y contraseña';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      final user = await repository.login(email: email, password: password);
      _currentUser = user;
      email = '';
      password = '';
      return user;
    } catch (e) {
      _error = _friendlyError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<User?> register() async {
    if (name.isEmpty) {
      _error = 'Ingresa tu nombre';
      notifyListeners();
      return null;
    }
    if (email.isEmpty || password.isEmpty) {
      _error = 'Ingresa tu correo y contraseña';
      notifyListeners();
      return null;
    }
    if (password.length < 6) {
      _error = 'La contraseña debe tener al menos 6 caracteres';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    try {
      final user = await repository.register(
        email: email,
        password: password,
        name: name,
      );
      _currentUser = user;
      email = '';
      password = '';
      name = '';
      return user;
    } catch (e) {
      _error = _friendlyError(e, registering: true);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await repository.logout();
      await repository.signInAsGuest();
      _currentUser = await repository.currentUser();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  String _friendlyError(Object error, {bool registering = false}) {
    final message = error.toString().toLowerCase();
    if (message.contains('already') ||
        message.contains('exists') ||
        message.contains('duplicate') ||
        message.contains('taken')) {
      return 'Ese correo ya está registrado. Prueba iniciar sesión.';
    }
    if (message.contains('unauthorized') ||
        message.contains('invalid') ||
        message.contains('401')) {
      return registering
          ? 'No se pudo crear la cuenta. Revisa los datos.'
          : 'Credenciales incorrectas. Verifica tu correo y contraseña.';
    }
    if (message.contains('connection') ||
        message.contains('internet') ||
        message.contains('timeout')) {
      return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
    }
    return registering
        ? 'No se pudo registrar. Intenta de nuevo.'
        : 'No se pudo iniciar sesión. Intenta de nuevo.';
  }
}
