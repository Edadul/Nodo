abstract class IDatabase {
  Future<List<Map<String, dynamic>>> queryTable(String table);
  Future<int> insertData(String table, Map<String, dynamic> data);
  Future<void> updateData(String table, int id, Map<String, dynamic> data);
}