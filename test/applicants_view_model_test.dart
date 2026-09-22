import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/features/applicants/data/datasources/mock_applicant_datasource.dart';
import 'package:nodo/features/applicants/data/repositories/applicant_repository_impl.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/applicants/domain/usecases/get_applicants.dart';
import 'package:nodo/features/applicants/domain/usecases/update_applicant_status.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';

void main() {
  late ApplicantsViewModel viewModel;

  setUp(() {
    final repository = ApplicantRepositoryImpl(MockApplicantDataSource());
    viewModel = ApplicantsViewModel(
      getApplicants: GetApplicants(repository),
      updateApplicantStatus: UpdateApplicantStatus(repository),
      projectId: 1,
    );
  });

  test('load() puebla la lista y queda en estado ready', () async {
    await viewModel.load();
    expect(viewModel.status, ApplicantsStatus.ready);
    expect(viewModel.totalCount, 8);
    expect(viewModel.countFor(ApplicantsFilter.pending), 5);
    expect(viewModel.countFor(ApplicantsFilter.accepted), 2);
    expect(viewModel.countFor(ApplicantsFilter.rejected), 1);
  });

  test('selectFilter() filtra la lista visible', () async {
    await viewModel.load();
    viewModel.selectFilter(ApplicantsFilter.accepted);
    expect(viewModel.applicants, hasLength(2));
    expect(
      viewModel.applicants.every(
        (applicant) => applicant.status == ApplicantStatus.accepted,
      ),
      isTrue,
    );
  });

  test('updateStatus() actualiza al postulante en la lista cargada', () async {
    await viewModel.load();
    final updated = await viewModel.updateStatus(3, ApplicantStatus.accepted);

    expect(updated, isNotNull);
    expect(viewModel.findById(3)!.status, ApplicantStatus.accepted);
    expect(viewModel.countFor(ApplicantsFilter.accepted), 3);
  });
}
