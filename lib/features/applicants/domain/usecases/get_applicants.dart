import '../entities/applicant.dart';
import '../repositories/applicant_repository.dart';

class GetApplicants {
  const GetApplicants(this._repository);

  final ApplicantRepository _repository;

  Future<List<Applicant>> call({required int projectId}) {
    return _repository.getApplicantsByProject(projectId);
  }
}
