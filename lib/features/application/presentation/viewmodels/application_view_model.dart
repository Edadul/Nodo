import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/application.dart';
import '../../domain/usecases/submit_application.dart';

enum ApplicationStatus { idle, submitting, success, error }

class ApplicationViewModel extends ChangeNotifier {
  ApplicationViewModel({required SubmitApplication submitApplication})
      : _submitApplication = submitApplication; // ignore: prefer_initializing_formals

  final SubmitApplication _submitApplication;

  ApplicationStatus status = ApplicationStatus.idle;
  String? errorMessage;

  bool _disposed = false;

  Future<Application?> submit({
    required String projectId,
    required String motivation,
    required List<String> skills,
    required String experience,
    required User? applicant,
  }) async {
    status = ApplicationStatus.submitting;
    errorMessage = null;
    _notify();

    try {
      final application = await _submitApplication(
        projectId: projectId,
        motivation: motivation,
        skills: skills,
        experience: experience,
        applicant: applicant,
      );
      status = ApplicationStatus.success;
      _notify();
      return application;
    } catch (error) {
      status = ApplicationStatus.error;
      errorMessage = friendlyErrorMessage(error);
      _notify();
      return null;
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
