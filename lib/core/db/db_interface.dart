abstract class IDatabase {
  Future<List<Map<String, dynamic>>> read(String tableName);
  Future<Map<String, dynamic>> insert(String tableName, Map<String, dynamic> data);
  Future<void> update(String tableName, String id, Map<String, dynamic> data);

  // Keep these to allow compilation of old datasources during migration
  Future<List<Map<String, dynamic>>> queryTable(String table);
  Future<int> insertData(String table, Map<String, dynamic> data);
}