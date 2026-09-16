import '../../../../core/db/db_interface.dart';
import '../../domain/entities/application.dart';
import 'application_datasource.dart';

class SQLiteApplicationDataSource implements ApplicationDataSource {
  SQLiteApplicationDataSource(this._database);

  final IDatabase _database;

  @override
  Future<Application> insertApplication(Application application) async {
    final id = await _database.insertData('applications', {
      'project_id': application.projectId,
      'motivation': application.motivation,
      'skills': application.skills.join(', '),
      'experience': application.experience,
      'submitted_at': application.submittedAt.toIso8601String(),
    });
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