import 'package:flutter/material.dart';

import '../../../../env/env.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository repository;

  AuthViewModel({required this.repository});

  String email = '';
  String password = '';

  bool _isLoading = false;
  String? _error;

  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  /// `true` cuando la sesión activa es la pública (invitado) o no hay sesión.
  bool get isPublicSession =>
      _currentUser == null || _currentUser!.email == Env.guestEmail;

  void setEmail(String v) {
    email = v.trim();
    _clearError();
    notifyListeners();
  }

  void setPassword(String v) {
    password = v;
    _clearError();
    notifyListeners();
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

  Future<void> logout() async {
    _setLoading(true);
    try {
      await repository.logout();
      await repository.signInAsGuest();
      _currentUser = null;
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

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.toLowerCase().contains('unauthorized') ||
        message.toLowerCase().contains('invalid') ||
        message.toLowerCase().contains('401')) {
      return 'Credenciales incorrectas. Verifica tu correo y contraseña.';
    }
    if (message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('internet') ||
        message.toLowerCase().contains('timeout')) {
      return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
    }
    return 'No se pudo iniciar sesión. Intenta de nuevo.';
  }
}