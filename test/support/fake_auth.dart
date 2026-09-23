import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/domain/repositories/auth_repository.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';

class SessionAuthRepository implements AuthRepository {
  SessionAuthRepository(this.current);

  User? current;

  @override
  Future<User?> currentUser() async => current;

  @override
  Future<User> login({required String email, required String password}) async {
    return current!;
  }

  @override
  Future<void> logout() async => current = null;

  @override
  Future<void> signInAsGuest() async => current = null;
}

/// [AuthViewModel] con la sesión de [user] ya cargada.
Future<AuthViewModel> authFor(User? user) async {
  final vm = AuthViewModel(repository: SessionAuthRepository(user));
  await vm.loadCurrentUser();
  return vm;
}
