import '../../../../core/db/db_interface.dart';
import '../../../../core/db/row_parsing.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../../core/services/user_profile_service.dart';
import '../../../../core/utils/uuid.dart';
import '../../../applicants/domain/entities/applicant_status.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/data/datasources/project_row_mapper.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/application.dart';
import 'application_datasource.dart';

class ApiApplicationDataSource implements ApplicationDataSource {
  ApiApplicationDataSource(this._database, this._catalog, this._profiles);

  final IDatabase _database;
  final CatalogService _catalog;
  final UserProfileService _profiles;

  @override
  Future<Idea?> fetchProject(String projectId) async {
    final rows = await _database.read('projects', filters: {'id': projectId});
    return rows.isEmpty ? null : ProjectRowMapper.fromRow(rows.first);
  }

  @override
  Future<List<Application>> fetchApplications({
    required String projectId,
    required String applicantId,
  }) async {
    final rows = await _database.read('applications', filters: {
      'project_id': projectId,
      'applicant_id': applicantId,
    });
    return rows.map(_toApplication).toList(growable: false);
  }

  @override
  Future<Application> insertApplication(
    Application application,
    User applicant,
  ) async {
    await _profiles.ensureProfile(applicant);

    final data = <String, dynamic>{
      'id': generateUuidV4(),
      'project_id': application.projectId,
      'applicant_id': application.applicantId,
      'motivation': application.motivation,
      'experience': application.experience,
      'status': ApplicantStatus.pending.storageValue,
      'submitted_at': application.submittedAt.toUtc().toIso8601String(),
    };
    final inserted = await _database.insert('applications', data);

    // `applications` no tiene columna de habilidades: las que aporta el
    // postulante quedan en su perfil (`user_skills`), que es lo que ve el
    // creador al revisarlo.
    await _linkUserSkills(application.applicantId, application.skills);

    return _toApplication({...data, ...inserted})
        .withSkills(application.skills);
  }

  Future<void> _linkUserSkills(String userId, List<String> skills) async {
    final existing = await _database.read(
      'user_skills',
      filters: {'user_id': userId},
    );
    final linked = existing
        .map((row) => RowParsing.text(row['skill_id']))
        .whereType<String>()
        .toSet();

    for (final skill in skills) {
      final skillId = await _catalog.ensure(CatalogTable.skills, skill);
      if (linked.add(skillId)) {
        await _database.insert('user_skills', {
          'user_id': userId,
          'skill_id': skillId,
        });
      }
    }
  }

  Application _toApplication(Map<String, dynamic> row) {
    return Application(
      id: RowParsing.schemaId(row),
      recordId: RowParsing.recordId(row),
      projectId: RowParsing.text(row['project_id']) ?? '',
      applicantId: RowParsing.text(row['applicant_id']) ?? '',
      motivation: RowParsing.text(row['motivation']) ?? '',
      experience: RowParsing.text(row['experience']) ?? '',
      skills: const [],
      status: ApplicantStatus.fromStorage(RowParsing.text(row['status'])),
      submittedAt: RowParsing.dateTime(row['submitted_at']) ?? DateTime.now(),
    );
  }
}

extension on Application {
  Application withSkills(List<String> skills) => Application(
        id: id,
        recordId: recordId,
        projectId: projectId,
        applicantId: applicantId,
        motivation: motivation,
        skills: skills,
        experience: experience,
        submittedAt: submittedAt,
        status: status,
      );
}
