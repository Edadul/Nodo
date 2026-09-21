import '../../../../core/db/db_interface.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import 'applicant_datasource.dart';

class SQLiteApplicantDataSource implements ApplicantDataSource {
  SQLiteApplicantDataSource(this._database);

  final IDatabase _database;

  static const _table = 'applications';

  @override
  Future<List<Applicant>> fetchApplicantsByProject(int projectId) async {
    final rows = await _database.queryTable(_table);
    return rows
        .where((row) => _number(row['project_id']) == projectId)
        .map(_toApplicant)
        .toList(growable: false);
  }

  @override
  Future<Applicant> updateApplicantStatus(
    int applicantId,
    ApplicantStatus status,
  ) async {
    await _database.updateData(_table, applicantId, {
      'status': status.storageValue,
    });

    final rows = await _database.queryTable(_table);
    final row = rows.firstWhere((row) => _number(row['id']) == applicantId);
    return _toApplicant(row);
  }

  Applicant _toApplicant(Map<String, dynamic> row) {
    return Applicant(
      id: _number(row['id']),
      projectId: _number(row['project_id']),
      name: _text(row['applicant_name'], fallback: 'Postulante'),
      program: _text(row['applicant_program']),
      university: _text(row['applicant_university']),
      motivation: _text(row['motivation']),
      skills: _text(row['skills'])
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList(growable: false),
      status: ApplicantStatus.fromStorage(row['status'] as String?),
      submittedAt:
          DateTime.tryParse(_text(row['submitted_at'])) ?? DateTime.now(),
      avatarUrl: _nullableText(row['avatar_url']),
      attachmentName: _nullableText(row['attachment_name']),
      attachmentSizeLabel: _nullableText(row['attachment_size_label']),
    );
  }

  String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String? _nullableText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  int _number(Object? value, {int fallback = 0}) {
    return value is int ? value : int.tryParse('$value') ?? fallback;
  }
}
