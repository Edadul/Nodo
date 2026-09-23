import '../db/db_interface.dart';

class ProjectService {
  final IDatabase _database;

  ProjectService(this._database);

  Future<List<Map<String, dynamic>>> fetchProjects() async {
    return await _database.read('projects');
  }
}
