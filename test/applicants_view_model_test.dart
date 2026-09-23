import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/features/applicants/domain/entities/applicant_status.dart';
import 'package:nodo/features/applicants/presentation/viewmodels/applicants_view_model.dart';

import 'support/applicants.dart';
import 'support/fake_database.dart';
import 'support/seed.dart';

void main() {
  late FakeDatabase db;
  late ApplicantsViewModel viewModel;

  setUp(() {
    db = seededDatabase();
    viewModel = applicantsViewModelFactory(db)(projectId, creator);
  });

  test('load() puebla la lista, el proyecto y queda en ready', () async {
    await viewModel.load();
    expect(viewModel.status, ApplicantsStatus.ready);
    expect(viewModel.totalCount, 2);
    expect(viewModel.countFor(ApplicantsFilter.pending), 2);
    expect(viewModel.project?.availableSpots, 2);
  });

  test('load() de alguien que no es el creador queda en error', () async {
    final vm = applicantsViewModelFactory(db)(projectId, otherUser);
    await vm.load();
    expect(vm.status, ApplicantsStatus.error);
    expect(vm.errorMessage, contains('Solo el creador'));
  });

  test('selectFilter() filtra la lista visible', () async {
    await viewModel.load();
    await viewModel.updateStatus('a-luis', ApplicantStatus.accepted);
    viewModel.selectFilter(ApplicantsFilter.accepted);
    expect(viewModel.applicants.map((a) => a.id), ['a-luis']);
  });

  test('updateStatus() actualiza la lista y los cupos', () async {
    await viewModel.load();
    final updated =
        await viewModel.updateStatus('a-luis', ApplicantStatus.accepted);

    expect(updated, isNotNull);
    expect(viewModel.findById('a-luis')!.status, ApplicantStatus.accepted);
    expect(viewModel.project?.filledSpots, 1);
    expect(viewModel.isUpdating('a-luis'), isFalse);
  });

  test('updateStatus() fallido deja mensaje y estado real', () async {
    await viewModel.load();
    // Otro dispositivo resolvió la postulación.
    db.rows('applications').first['status'] = 'rejected';

    final updated =
        await viewModel.updateStatus('a-luis', ApplicantStatus.accepted);

    expect(updated, isNull);
    expect(viewModel.errorMessage, contains('ya fue resuelta'));
    expect(viewModel.findById('a-luis')!.status, ApplicantStatus.rejected);
  });
}
