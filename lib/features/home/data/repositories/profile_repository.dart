import '../../../../core/db/db_interface.dart';
import '../../domain/entities/profile.dart';

class ProfileRepository {
  final IDatabase _database;

  ProfileRepository(this._database);

  Future<Profile?> fetchByUserId(String userId) async {
    for (final column in ['_id', 'id']) {
      try {
        final rows =
            await _database.read('users', filters: {column: userId});
        if (rows.isNotEmpty) {
          return _toProfile(rows.first);
        }
      } catch (_) {
        // Si la columna no existe o no hay permisos, se prueba con la otra.
      }
    }
    return null;
  }

  Profile _toProfile(Map<String, dynamic> row) {
    final username = _text(row['username']) ?? 'usuario';
    return Profile(
      name: _text(row['name']) ?? 'Usuario',
      username: username.startsWith('@') ? username : '@$username',
      bio: _text(row['bio']) ?? 'Creador de Proyectos',
      avatar: _text(row['avatar_url']) ?? '',
      posts: _number(row['posts_count']),
      followers: _number(row['followers_count']),
      favorites: _number(row['favorites_count']),
    );
  }

  String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  int _number(Object? value) {
    return value is int ? value : int.tryParse('$value') ?? 0;
  }
}