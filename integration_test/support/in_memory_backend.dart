import 'package:nodo/core/db/db_interface.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/domain/repositories/auth_repository.dart';

/// [IDatabase] en memoria con la semántica de Roble que usa la app: cada fila
/// recibe un `_id`, `read` filtra por igualdad y `update`/`delete` van por
/// `_id`. Sustituye a la Remote API para que los flujos no toquen datos reales.
class InMemoryDatabase implements IDatabase {
  InMemoryDatabase([Map<String, List<Map<String, dynamic>>>? seed]) {
    seed?.forEach((table, rows) {
      for (final row in rows) {
        _insertSync(table, row);
      }
    });
  }

  final Map<String, List<Map<String, dynamic>>> tables = {};
  int _nextId = 1;

  List<Map<String, dynamic>> rows(String table) => tables[table] ?? [];

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    return rows(tableName)
        .where((row) => (filters ?? {}).entries.every(
              (filter) => '${row[filter.key]}' == '${filter.value}',
            ))
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> insert(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    return Map.of(_insertSync(tableName, data));
  }

  @override
  Future<void> update(
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    final row = rows(tableName).firstWhere(
      (row) => row['_id'] == recordId,
      orElse: () => throw StateError('404 $tableName/$recordId'),
    );
    row.addAll(data);
  }

  @override
  Future<void> delete(String tableName, String recordId) async {
    rows(tableName).removeWhere((row) => row['_id'] == recordId);
  }

  Map<String, dynamic> _insertSync(String table, Map<String, dynamic> data) {
    final row = {'_id': 'rec-${_nextId++}', ...data};
    tables.putIfAbsent(table, () => []).add(row);
    return row;
  }
}

/// Cuenta registrada en [InMemoryAuthRepository].
class TestAccount {
  const TestAccount(this.user, this.password);

  final User user;
  final String password;
}

/// Sesión sin red: valida contra [accounts] y arranca como invitado.
class InMemoryAuthRepository implements AuthRepository {
  InMemoryAuthRepository(List<TestAccount> accounts)
      : _accounts = {for (final a in accounts) a.user.email: a};

  final Map<String, TestAccount> _accounts;
  User? _current;

  @override
  Future<User> login({required String email, required String password}) async {
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw Exception('401 Unauthorized');
    }
    return _current = account.user;
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_accounts.containsKey(email)) throw Exception('already exists');
    final user = User(id: 'u-${_accounts.length + 1}', name: name, email: email);
    _accounts[email] = TestAccount(user, password);
    return _current = user;
  }

  @override
  Future<void> logout() async => _current = null;

  @override
  Future<void> signInAsGuest() async => _current = null;

  @override
  Future<User?> currentUser() async => _current;

  @override
  Future<User?> restoreOrGuest() async => _current;
}
