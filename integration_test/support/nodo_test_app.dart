import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/core/di/app_module.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/main.dart';

import 'in_memory_backend.dart';

const creator = User(
  id: 'u-ana',
  name: 'Ana Creadora',
  email: 'ana@nodo.test',
);
const creatorPassword = 'ana12345';

const student = User(
  id: 'u-luis',
  name: 'Luis Estudiante',
  email: 'luis@nodo.test',
);
const studentPassword = 'luis12345';

const gardenId = 'p-huerta';
const gardenTitle = 'Huerta urbana colaborativa';
const aiId = 'p-ia';
const aiTitle = 'Asistente de estudio con IA';

/// Datos iniciales: dos proyectos de [creator] y una postulación pendiente de
/// Sara a la huerta.
Map<String, List<Map<String, dynamic>>> _seed() => {
      'users': [
        {'id': creator.id, 'username': 'ana', 'name': creator.name},
        {'id': student.id, 'username': 'luis', 'name': student.name},
        {
          'id': 'u-sara',
          'username': 'sara',
          'name': 'Sara Gómez',
          'program': 'Diseño Industrial',
          'university': 'Uninorte',
        },
      ],
      'categories': [
        {'id': 'c-social', 'name': 'SOCIAL'},
        {'id': 'c-tec', 'name': 'TECNOLOGÍA'},
      ],
      'skills': [
        {'id': 's-garden', 'name': 'JARDINERÍA'},
        {'id': 's-flutter', 'name': 'FLUTTER'},
      ],
      'projects': [
        {
          'id': gardenId,
          'creator_id': creator.id,
          'title': gardenTitle,
          'description': 'Diseñar y construir una huerta en el campus.',
          'total_spots': 3,
          'filled_spots': 0,
          'status': 'idea',
          'created_at': '2026-10-02T10:00:00.000Z',
        },
        {
          'id': aiId,
          'creator_id': creator.id,
          'title': aiTitle,
          'description': 'Resumir apuntes y generar quizzes automáticamente.',
          'total_spots': 2,
          'filled_spots': 0,
          'status': 'idea',
          'created_at': '2026-10-01T10:00:00.000Z',
        },
      ],
      'project_categories': [
        {'project_id': gardenId, 'category_id': 'c-social'},
        {'project_id': aiId, 'category_id': 'c-tec'},
      ],
      'project_skills': [
        {'project_id': gardenId, 'skill_id': 's-garden'},
        {'project_id': aiId, 'skill_id': 's-flutter'},
      ],
      'user_skills': [],
      'project_updates': [],
      'applications': [
        {
          'id': 'a-sara',
          'project_id': gardenId,
          'applicant_id': 'u-sara',
          'motivation': 'Me interesa el diseño del espacio y la comunidad.',
          'experience': 'Menos de 1 año',
          'status': 'pending',
          'submitted_at': '2026-10-03T10:00:00.000Z',
        },
      ],
    };

/// Arranca la app completa igual que `main()` (AppModule + NodoApp), pero
/// con la base de datos y la sesión en memoria. Devuelve la base de datos
/// para comprobar lo que la app escribió.
Future<InMemoryDatabase> startNodo(WidgetTester tester) async {
  final database = InMemoryDatabase(_seed());
  final auth = InMemoryAuthRepository(const [
    TestAccount(creator, creatorPassword),
    TestAccount(student, studentPassword),
  ]);

  await tester.pumpWidget(
    AppModule(
      database: database,
      authRepository: auth,
      child: const NodoApp(),
    ),
  );
  await tester.pumpAndSettle();
  return database;
}

/// Desplaza [scrollable] hasta que [finder] se construya y quede visible.
Future<void> scrollTo(
  WidgetTester tester,
  Finder finder, {
  required Finder scrollable,
}) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(of: scrollable, matching: find.byType(Scrollable))
        .first,
  );
  await tester.pumpAndSettle();
}

/// Inicia sesión desde una [LoginScreen] ya abierta.
Future<void> logIn(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byKey(const Key('login-email')), email);
  await tester.enterText(find.byKey(const Key('login-password')), password);
  await hideKeyboard(tester);
  await tester.tap(find.byKey(const Key('login-submit')));
  await tester.pumpAndSettle();
}

/// Cierra el teclado para que no tape los botones en dispositivos reales.
Future<void> hideKeyboard(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}
