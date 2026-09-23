import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import '../../domain/usecases/decide_application.dart';
import '../../domain/usecases/get_applicants.dart';

enum ApplicantsStatus { initial, loading, ready, error }

/// Filtro de la lista de postulantes (pestañas de [Screen11_ApplicantsList]).
enum ApplicantsFilter { all, pending, accepted, rejected }

class ApplicantsViewModel extends ChangeNotifier {
  ApplicantsViewModel({
    required GetApplicants getApplicants,
    required DecideApplication decideApplication,
    required this.projectId,
    required this.actor,
  })  : _getApplicants = getApplicants, // ignore: prefer_initializing_formals
        _decideApplication = decideApplication; // ignore: prefer_initializing_formals

  final GetApplicants _getApplicants;
  final DecideApplication _decideApplication;
  final String projectId;

  /// Usuario que gestiona (debe ser el creador del proyecto).
  final User? actor;

  ApplicantsStatus status = ApplicantsStatus.initial;
  ApplicantsFilter filter = ApplicantsFilter.all;
  String? errorMessage;

  /// Estado del proyecto (cupos) según la BD.
  Idea? project;

  List<Applicant> _applicants = const [];
  final Set<String> _updating = {};
  bool _disposed = false;

  List<Applicant> get applicants =>
      _applicants.where(_matchesFilter).toList(growable: false);

  int get totalCount => _applicants.length;
  int countFor(ApplicantsFilter value) =>
      _applicants.where((applicant) => _matches(applicant, value)).length;

  bool get isFull => project?.isFull ?? false;

  /// `true` mientras se guarda la decisión sobre esa postulación.
  bool isUpdating(String applicantId) => _updating.contains(applicantId);

  Applicant? findById(String applicantId) {
    for (final applicant in _applicants) {
      if (applicant.id == applicantId) return applicant;
    }
    return null;
  }

  Future<void> load() async {
    status = ApplicantsStatus.loading;
    errorMessage = null;
    _notify();

    try {
      final result = await _getApplicants(projectId: projectId, actor: actor);
      project = result.project;
      _applicants = result.applicants;
      status = ApplicantsStatus.ready;
    } catch (error) {
      status = ApplicantsStatus.error;
      errorMessage = friendlyErrorMessage(error);
    }

    _notify();
  }

  void selectFilter(ApplicantsFilter value) {
    if (value == filter) return;
    filter = value;
    _notify();
  }

  Future<Applicant?> updateStatus(
    String applicantId,
    ApplicantStatus newStatus,
  ) async {
    if (!_updating.add(applicantId)) return null;
    errorMessage = null;
    _notify();

    try {
      final decision = await _decideApplication(
        projectId: projectId,
        applicationId: applicantId,
        decision: newStatus,
        actor: actor,
      );
      project = decision.project;
      _replace(decision.applicant);
      return decision.applicant;
    } catch (error) {
      errorMessage = friendlyErrorMessage(error);
      // Si la BD cambió (resuelta en otro dispositivo, sin cupos), se recarga
      // para mostrar el estado real.
      if (error is ValidationFailure) await _refreshQuietly();
      return null;
    } finally {
      _updating.remove(applicantId);
      _notify();
    }
  }

  Future<void> _refreshQuietly() async {
    try {
      final result = await _getApplicants(projectId: projectId, actor: actor);
      project = result.project;
      _applicants = result.applicants;
    } catch (_) {
      // Se conserva la lista actual.
    }
  }

  void _replace(Applicant updated) {
    final index = _applicants.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _applicants = List<Applicant>.from(_applicants)..[index] = updated;
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

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
