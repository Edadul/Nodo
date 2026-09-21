import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/features/applicants/data/datasources/mock_applicant_datasource.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/applicants/domain/usecases/get_applicants.dart';
import 'package:nodo/features/applicants/domain/usecases/update_applicant_status.dart';

void main() {
  late GetApplicants getApplicants;
  late UpdateApplicantStatus updateApplicantStatus;

  setUp(() {
    final repository = ApplicantRepositoryImpl(MockApplicantDataSource());
    getApplicants = GetApplicants(repository);
    updateApplicantStatus = UpdateApplicantStatus(repository);
  });

  test('GetApplicants devuelve los postulantes de un proyecto', () async {
    final applicants = await getApplicants(projectId: 1);
    expect(applicants, hasLength(8));
    expect(applicants.first.name, 'María García');
  });

  test('GetApplicants no devuelve postulantes de otro proyecto', () async {
    final applicants = await getApplicants(projectId: 99);
    expect(applicants, isEmpty);
  });

  test('UpdateApplicantStatus cambia el estado del postulante', () async {
    final updated = await updateApplicantStatus(
      applicantId: 1,
      status: ApplicantStatus.accepted,
    );
    expect(updated.status, ApplicantStatus.accepted);

    final applicants = await getApplicants(projectId: 1);
    final maria = applicants.firstWhere((applicant) => applicant.id == 1);
    expect(maria.status, ApplicantStatus.accepted);
  });
}
