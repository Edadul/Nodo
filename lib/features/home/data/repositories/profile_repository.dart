import '../../../../core/db/db_interface.dart';
import '../../domain/entities/profile.dart';

class ProfileRepository {
  final IDatabase _database;

  ProfileRepository(this._database);

  Future<Profile?> fetchByUserId(String userId) async {
    final rows = await _database.read('users', filters: {'id': userId});
    return rows.isEmpty ? null : _toProfile(rows.first);
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