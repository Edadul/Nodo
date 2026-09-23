import 'package:roble/roble.dart';
import 'db_interface.dart';
import '../../env/env.dart';

class Roble implements IDatabase {
  static final robleDatabase = RobleApiDataBase(
    config: RobleApiConfig.fromContract(
      baseUrl: Env.baseUrl,
      contractId: Env.contractId,
    ),
  );
  
  Future<void> init() async {
    try {
      await robleDatabase.login(
        email: Env.guestEmail,
        password: Env.guestPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await robleDatabase.read(tableName, filters: filters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> insert(String tableName, Map<String, dynamic> data) async {
    try {
      final response = await robleDatabase.create(tableName, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> update(String tableName, String id, Map<String, dynamic> data) async {
    try {
      await robleDatabase.update(tableName, id, data);
    } catch (e) {
      rethrow;
    }
  }

  // === Stub methods to maintain compilation during migration ===
  @override
  Future<List<Map<String, dynamic>>> queryTable(String table) async {
    // Stub to maintain compilation during migration
    return [];
  }

  @override
  Future<int> insertData(String table, Map<String, dynamic> data) async {
    // Stub to maintain compilation during migration
    return 0;
  }
}
