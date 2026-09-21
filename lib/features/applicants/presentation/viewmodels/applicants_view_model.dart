import 'package:flutter/foundation.dart';

import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import '../../domain/usecases/get_applicants.dart';
import '../../domain/usecases/update_applicant_status.dart';

enum ApplicantsStatus { initial, loading, ready, error }

/// Filtro de la lista de postulantes (pestañas de [Screen11_ApplicantsList]).
enum ApplicantsFilter { all, pending, accepted, rejected }

class ApplicantsViewModel extends ChangeNotifier {
  ApplicantsViewModel({
    required GetApplicants getApplicants,
    required UpdateApplicantStatus updateApplicantStatus,
    required this.projectId,
  }) : _getApplicants = getApplicants, // ignore: prefer_initializing_formals
       _updateApplicantStatus = updateApplicantStatus; // ignore: prefer_initializing_formals

  final GetApplicants _getApplicants;
  final UpdateApplicantStatus _updateApplicantStatus;
  final int projectId;

  ApplicantsStatus status = ApplicantsStatus.initial;
  ApplicantsFilter filter = ApplicantsFilter.all;
  String? errorMessage;

  List<Applicant> _applicants = const [];

  List<Applicant> get applicants =>
      _applicants.where(_matchesFilter).toList(growable: false);

  int get totalCount => _applicants.length;
  int countFor(ApplicantsFilter value) =>
      _applicants.where((applicant) => _matches(applicant, value)).length;

  Applicant? findById(int applicantId) {
    for (final applicant in _applicants) {
      if (applicant.id == applicantId) return applicant;
    }
    return null;
  }

  Future<void> load() async {
    status = ApplicantsStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      _applicants = await _getApplicants(projectId: projectId);
      status = ApplicantsStatus.ready;
    } catch (error) {
      status = ApplicantsStatus.error;
      errorMessage = error.toString();
    }

    notifyListeners();
  }

  void selectFilter(ApplicantsFilter value) {
    if (value == filter) return;
    filter = value;
    notifyListeners();
  }

  Future<Applicant?> updateStatus(
    int applicantId,
    ApplicantStatus newStatus,
  ) async {
    try {
      final updated = await _updateApplicantStatus(
        applicantId: applicantId,
        status: newStatus,
      );
      final index = _applicants.indexWhere(
        (applicant) => applicant.id == applicantId,
      );
      if (index != -1) {
        _applicants = List<Applicant>.from(_applicants)
          ..[index] = updated;
      }
      notifyListeners();
      return updated;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  bool _matchesFilter(Applicant applicant) => _matches(applicant, filter);

  bool _matches(Applicant applicant, ApplicantsFilter value) {
    switch (value) {
      case ApplicantsFilter.all:
        return true;
      case ApplicantsFilter.pending:
        return applicant.status == ApplicantStatus.pending;
      case ApplicantsFilter.accepted:
        return applicant.status == ApplicantStatus.accepted;
      case ApplicantsFilter.rejected:
        return applicant.status == ApplicantStatus.rejected;
    }
  }
}
