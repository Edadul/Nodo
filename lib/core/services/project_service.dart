import '../db/db_interface.dart';

class ProjectService {
  final IDatabase _database;

  ProjectService(this._database);

  Future<List<Map<String, dynamic>>> fetchAllProjects() async {
    try {
      // TODO: validations, logic, etc. should be added here
      return await _database.queryTable('projects');
    } catch (e) {
      throw Exception('query failed: $e');
    }
  }

  Future<void> postNewProject(Map<String, dynamic> projectData) async {
    await _database.insertData('projects', projectData);
  }
}