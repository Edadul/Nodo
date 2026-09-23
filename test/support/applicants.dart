import 'package:nodo/core/services/catalog_service.dart';
import 'package:nodo/features/applicants/data/datasources/api_applicant_datasource.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/usecases/decide_application.dart';
import 'package:nodo/features/applicants/domain/usecases/get_applicants.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';

import 'fake_database.dart';

ApplicantsViewModel Function(String, User?) applicantsViewModelFactory(
  FakeDatabase db,
) {
  final repository =
      ApplicantRepositoryImpl(ApiApplicantDataSource(db, CatalogService(db)));
  return (String projectId, User? actor) => ApplicantsViewModel(
        projectId: projectId,
        actor: actor,
        getApplicants: GetApplicants(repository),
        decideApplication: DecideApplication(repository),
      );
}
