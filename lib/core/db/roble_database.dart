import 'package:roble/roble.dart';

import '../../env/env.dart';
import 'db_interface.dart';

class Roble implements IDatabase {
  static RobleApiDataBase? _robleDatabase;

  static RobleApiDataBase get robleDatabase {
    final db = _robleDatabase;
    if (db == null) {
      throw StateError('Llama Roble.configure() después de Env.load().');
    }
    return db;
  }

  /// Debe llamarse una vez en [main] tras [Env.load].
  static void configure() {
    _robleDatabase = RobleApiDataBase(
      config: RobleApiConfig.fromContract(
        baseUrl: Env.baseUrl,
        contractId: Env.contractId,
      ),
    );
  }

  Future<void> init() async {
    // no-op: bootstrap de auth ocurre en AuthViewModel.bootstrap()
  }

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) {
    if (!robleDatabase.isLoggedIn) {
      return robleDatabase.publicRead(tableName, filters: filters);
    }
    return robleDatabase.read(tableName, filters: filters);
  }

  @override
  Future<Map<String, dynamic>> insert(
    String tableName,
    Map<String, dynamic> data,
  ) {
    return robleDatabase.create(tableName, data);
  }

  @override
  Future<void> update(
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    await robleDatabase.update(tableName, recordId, data);
  }

  @override
  Future<void> delete(String tableName, String recordId) async {
    await robleDatabase.delete(tableName, recordId);
  }
}
