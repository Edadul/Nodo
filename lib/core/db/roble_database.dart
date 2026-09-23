import 'package:roble/roble.dart';

import '../../env/env.dart';
import 'db_interface.dart';

class Roble implements IDatabase {
  static final robleDatabase = RobleApiDataBase(
    config: RobleApiConfig.fromContract(
      baseUrl: Env.baseUrl,
      contractId: Env.contractId,
    ),
  );

  Future<void> init() async {
    await robleDatabase.login(
      email: Env.guestEmail,
      password: Env.guestPassword,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) {
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
