abstract class IDatabase {
  Future<List<Map<String, dynamic>>> queryTable(String table);
  Future<int> insertData(String table, Map<String, dynamic> data);
}