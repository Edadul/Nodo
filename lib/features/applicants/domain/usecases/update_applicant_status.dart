import '../entities/applicant.dart';
import '../entities/applicant_status.dart';
import '../repositories/applicant_repository.dart';

class UpdateApplicantStatus {
  const UpdateApplicantStatus(this._repository);

  final ApplicantRepository _repository;

  Future<Applicant> call({
    required int applicantId,
    required ApplicantStatus status,
  }) {
    return _repository.updateStatus(applicantId, status);
  }
}
