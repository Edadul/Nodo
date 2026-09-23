import '../../features/auth/domain/entities/user.dart';
import '../db/db_interface.dart';
import '../utils/uuid.dart';

/// Garantiza que la cuenta autenticada tenga su fila en `users`, requisito de
/// las FKs `projects.creator_id` y `applications.applicant_id`.
class UserProfileService {
  UserProfileService(this._database);

  final IDatabase _database;

  /// Ids ya confirmados en `users` durante esta sesión. Crear un proyecto o
  /// postular repite esta comprobación cada vez; sin caché, cada una es una
  /// petición de red de sobra porque la fila, una vez creada, no vuelve a
  /// desaparecer.
  final Set<String> _confirmedIds = {};

  Future<void> ensureProfile(User user) async {
    if (_confirmedIds.contains(user.id)) return;

    final rows = await _database.read('users', filters: {'id': user.id});
    if (rows.isNotEmpty) {
      _confirmedIds.add(user.id);
      return;
    }

    await _database.insert('users', {
      'id': user.id,
      'username': await _availableUsername(user.email),
      'name': user.name.trim().isEmpty ? 'Usuario' : user.name.trim(),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    _confirmedIds.add(user.id);
  }

  Future<String> _availableUsername(String email) async {
    final base = email
        .split('@')
        .first
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._]'), '');
    final candidate = base.isEmpty ? 'usuario' : base;
    final taken =
        await _database.read('users', filters: {'username': candidate});
    if (taken.isEmpty) return candidate;
    return '${candidate}_${generateUuidV4().substring(0, 6)}';
  }
}
