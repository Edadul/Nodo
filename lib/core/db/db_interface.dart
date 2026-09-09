abstract class IDatabase {
  Future<List<Map<String, dynamic>>> queryTable(String table);
  Future<void> insertData(String table, Map<String, dynamic> data);
}