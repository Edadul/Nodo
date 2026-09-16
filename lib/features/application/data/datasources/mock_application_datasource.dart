import '../../domain/entities/application.dart';
import 'application_datasource.dart';

/// Implementación temporal en memoria para tests.
class MockApplicationDataSource implements ApplicationDataSource {
  MockApplicationDataSource({List<Application>? seed})
      : _applications = List<Application>.from(seed ?? const []);

  final List<Application> _applications;

  List<Application> get applications => List.unmodifiable(_applications);

  @override
  Future<Application> insertApplication(Application application) async {
    final stored = Application(
      id: _applications.length + 1,
      projectId: application.projectId,
      motivation: application.motivation,
      skills: application.skills,
      experience: application.experience,
      submittedAt: application.submittedAt,
    );
    _applications.add(stored);
    return stored;
  }
}