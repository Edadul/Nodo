import 'package:flutter/foundation.dart';

import '../../domain/entities/application.dart';
import '../../domain/usecases/submit_application.dart';

enum ApplicationStatus { idle, submitting, success, error }

class ApplicationViewModel extends ChangeNotifier {
  ApplicationViewModel({required SubmitApplication submitApplication})
      : _submitApplication = submitApplication; // ignore: prefer_initializing_formals

  final SubmitApplication _submitApplication;

  ApplicationStatus status = ApplicationStatus.idle;
  String? errorMessage;

  Future<Application?> submit({
    required int projectId,
    required String motivation,
    required List<String> skills,
    required String experience,
  }) async {
    status = ApplicationStatus.submitting;
    errorMessage = null;
    notifyListeners();

    try {
      final application = await _submitApplication(
        Application(
          projectId: projectId,
          motivation: motivation.trim(),
          skills: skills.map((skill) => skill.trim()).toList(growable: false),
          experience: experience.trim(),
          submittedAt: DateTime.now(),
        ),
      );
      status = ApplicationStatus.success;
      notifyListeners();
      return application;
    } catch (error) {
      status = ApplicationStatus.error;
      errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }
}