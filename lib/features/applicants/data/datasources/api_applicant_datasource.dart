import '../../../../core/db/db_interface.dart';
import '../../../../core/db/row_parsing.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../home/data/datasources/project_row_mapper.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import 'applicant_datasource.dart';

class ApiApplicantDataSource implements ApplicantDataSource {
  ApiApplicantDataSource(this._database, this._catalog);

  final IDatabase _database;
  final CatalogService _catalog;

  @override
  Future<Idea?> fetchProject(String projectId) async {
    final rows = await _database.read('projects', filters: {'id': projectId});
    return rows.isEmpty ? null : ProjectRowMapper.fromRow(rows.first);
  }

  @override
  Future<List<Applicant>> fetchApplicantsByProject(String projectId) async {
    final rows = await _database.read(
      'applications',
      filters: {'project_id': projectId},
    );
    final applicants = await _toApplicants(rows);
    applicants.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return applicants;
  }

  @override
  Future<Applicant?> fetchApplicant(String applicationId) async {
    final rows = await _database.read(
      'applications',
      filters: {'id': applicationId},
    );
    if (rows.isEmpty) return null;
    return (await _toApplicants(rows)).first;
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationRecordId,
    ApplicantStatus status,
  ) {
    return _database.update('applications', applicationRecordId, {
      'status': status.storageValue,
    });
  }

  @override
  Future<void> updateFilledSpots(String projectRecordId, int filledSpots) {
    return _database.update('projects', projectRecordId, {
      'filled_spots': filledSpots,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Une cada postulación con el perfil (`users`) y las habilidades
  /// (`user_skills` → `skills`) del postulante.
  Future<List<Applicant>> _toApplicants(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return [];

    final results = await Future.wait([
      _database.read('users'),
      _database.read('user_skills'),
      _catalog.readAll(CatalogTable.skills),
    ]);
    final users = {
      for (final user in results[0] as List<Map<String, dynamic>>)
        RowParsing.schemaId(user): user,
    };
    final skillNames = results[2] as Map<String, String>;
    final skillsByUser = <String, List<String>>{};
    for (final link in results[1] as List<Map<String, dynamic>>) {
      final userId = RowParsing.text(link['user_id']);
      final name = skillNames[RowParsing.text(link['skill_id'])];
      if (userId == null || name == null) continue;
      skillsByUser.putIfAbsent(userId, () => []).add(name);
    }

    return rows.map((row) {
      final applicantId = RowParsing.text(row['applicant_id']) ?? '';
      final user = users[applicantId] ?? const <String, dynamic>{};
      return Applicant(
        id: RowParsing.schemaId(row),
        recordId: RowParsing.recordId(row),
        projectId: RowParsing.text(row['project_id']) ?? '',
        applicantId: applicantId,
        name: RowParsing.text(user['name']) ?? 'Usuario',
        program: RowParsing.text(user['program']) ?? 'Estudiante',
        university: RowParsing.text(user['university']) ?? '',
        motivation: RowParsing.text(row['motivation']) ?? '',
        experience: RowParsing.text(row['experience']) ?? '',
        skills: (skillsByUser[applicantId] ?? [])..sort(),
        status: ApplicantStatus.fromStorage(RowParsing.text(row['status'])),
        submittedAt:
            RowParsing.dateTime(row['submitted_at']) ?? DateTime.now(),
        avatarUrl: RowParsing.text(user['avatar_url']),
        attachmentName: RowParsing.text(row['attachment_name']),
        attachmentSizeLabel: RowParsing.text(row['attachment_size_label']),
        attachmentUrl: RowParsing.text(row['attachment_url']),
      );
    }).toList();
  }
}
