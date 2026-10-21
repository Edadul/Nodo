import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nodo/features/applicants/domain/repositories/applicant_repository.dart';
import 'package:nodo/features/application/domain/repositories/application_repository.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/auth/domain/repositories/auth_repository.dart';
import 'package:nodo/features/auth/presentation/viewmodels/auth_view_model.dart';
import 'package:nodo/features/home/data/repositories/profile_repository.dart';
import 'package:nodo/features/home/domain/repositories/idea_repository.dart';
import 'package:nodo/features/project_creation/domain/repositories/project_creation_repository.dart';

export '../../unit/support/builders.dart';
export '../../unit/support/mocks.dart' show MockDatabase;

/// Repositorios de dominio simulados: las pantallas reciben ViewModels y casos
/// de uso reales, pero ningún dato sale de la red.
class MockAuthRepository extends Mock implements AuthRepository {}

class MockIdeaRepository extends Mock implements IdeaRepository {}

class MockProjectCreationRepository extends Mock
    implements ProjectCreationRepository {}

class MockApplicationRepository extends Mock implements ApplicationRepository {}

class MockApplicantRepository extends Mock implements ApplicantRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

/// [AuthViewModel] con [user] como sesión activa (null = sesión pública).
Future<AuthViewModel> authWith(User? user, {MockAuthRepository? repository}) {
  final repo = repository ?? MockAuthRepository();
  when(() => repo.currentUser()).thenAnswer((_) async => user);
  final vm = AuthViewModel(repository: repo);
  return vm.loadCurrentUser().then((_) => vm);
}

/// Pantalla alta para que los ListView construyan todo su contenido y los
/// finders encuentren widgets que normalmente quedarían fuera de la vista.
void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Abre [screen] encima de una pantalla base, para poder comprobar los `pop`
/// y el valor que devuelve la ruta.
Widget launcher({
  required Widget Function() screen,
  void Function(Object? result)? onResult,
}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async {
              final result = await Navigator.push<Object?>(
                context,
                MaterialPageRoute(builder: (_) => screen()),
              );
              onResult?.call(result);
            },
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}
