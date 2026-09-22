import '../../../../core/db/db_interface.dart';
import '../../domain/entities/application.dart';
import 'application_datasource.dart';

class ApiApplicationDataSource implements ApplicationDataSource {
  ApiApplicationDataSource(this._database);

  final IDatabase _database;

  @override
  Future<Application> insertApplication(Application application) async {
    final response = await _database.insert('applications', {
      'project_id': application.projectId,
      'motivation': application.motivation,
      'skills': application.skills.join(', '),
      'experience': application.experience,
      'submitted_at': application.submittedAt.toIso8601String(),
    });
    
    final idRaw = response['_id'] ?? response['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
    
    return Application(
      id: id,
      projectId: application.projectId,
      motivation: application.motivation,
      skills: application.skills,
      experience: application.experience,
      submittedAt: application.submittedAt,
    );
  }
}
