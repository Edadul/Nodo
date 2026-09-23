import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/core/errors/failures.dart';
import 'package:nodo/core/services/catalog_service.dart';
import 'package:nodo/core/services/user_profile_service.dart';
import 'package:nodo/features/auth/domain/entities/user.dart';
import 'package:nodo/features/home/data/datasources/api_idea_datasource.dart';
import 'package:nodo/features/project_creation/data/datasources/api_project_creation_datasource.dart';
import 'package:nodo/features/project_creation/data/repositories/project_creation_repository_impl.dart';
import 'package:nodo/features/project_creation/domain/entities/project_draft.dart';
import 'package:nodo/features/project_creation/domain/usecases/create_project.dart';
import 'package:nodo/features/project_creation/domain/validation/project_draft_validator.dart';

import 'support/fake_database.dart';
import 'support/seed.dart';

ProjectDraft draft({
  String title = 'Huerta urbana colaborativa',
  String description = 'Diseñar y construir una huerta comunitaria en el campus.',
  int totalSpots = 3,
  List<String> categories = const ['social', 'Tecnología'],
  List<String> skills = const ['gestión', 'Flutter'],
}) {
  return ProjectDraft(
    title: title,
    description: description,
    totalSpots: totalSpots,
    categories: categories,
    skills: skills,
  );
}

void main() {
  group('validateProjectDraft', () {
    test('borrador válido no tiene errores', () {
      expect(validateProjectDraft(draft()), isEmpty);
    });

    test('marca cada campo inválido', () {
      final errors = validateProjectDraft(draft(
        title: 'App',
        description: 'Corta',
        totalSpots: 0,
        categories: const [],
        skills: const ['x'],
      ));
      expect(errors.keys, containsAll(ProjectField.values));
    });

    test('límites de cupos y categorías', () {
      expect(
        validateProjectDraft(draft(totalSpots: ProjectRules.spotsMax + 1)),
        contains(ProjectField.totalSpots),
      );
      expect(
        validateProjectDraft(draft(categories: const ['A1', 'B2', 'C3', 'D4'])),
        contains(ProjectField.categories),
      );
    });

    test('etiquetas repetidas con distinto formato cuentan una vez', () {
      final errors = validateProjectDraft(
        draft(categories: const ['ux', ' UX ', 'Ux', 'SOCIAL']),
      );
      expect(errors, isEmpty);
    });
  });

  group('CreateProject', () {
    late FakeDatabase db;
    late CreateProject createProject;

    setUp(() {
      db = seededDatabase();
      createProject = CreateProject(
        ProjectCreationRepositoryImpl(
          ApiProjectCreationDataSource(
            db,
            CatalogService(db),
            UserProfileService(db),
          ),
        ),
      );
    });

    test('rechaza invitado y sesión vacía', () async {
      expect(
        () => createProject(draft(), creator: guest),
        throwsA(isA<ValidationFailure>()),
      );
      expect(
        () => createProject(draft(), creator: null),
        throwsA(isA<ValidationFailure>()),
      );
      expect(db.rows('projects'), hasLength(1));
    });

    test('rechaza borrador inválido sin escribir', () async {
      await expectLater(
        createProject(draft(title: 'App'), creator: creator),
        throwsA(isA<ValidationFailure>()),
      );
      expect(db.rows('projects'), hasLength(1));
    });

    test('rechaza título repetido del mismo creador', () async {
      await expectLater(
        createProject(draft(title: '  plataforma NODO '), creator: creator),
        throwsA(isA<ValidationFailure>().having(
          (f) => f.message,
          'message',
          contains('Ya tienes un proyecto'),
        )),
      );
    });

    test('persiste proyecto, catálogos y tablas puente', () async {
      const newUser =
          User(id: 'u-new', name: 'Nueva Persona', email: 'nueva@uni.edu');

      final idea = await createProject(draft(), creator: newUser);

      final project =
          db.rows('projects').firstWhere((row) => row['id'] == idea.id);
      expect(project['creator_id'], newUser.id);
      expect(project['filled_spots'], 0);
      expect(project['total_spots'], 3);
      expect(idea.recordId, project['_id']);

      // Se creó la fila en users (FK de creator_id).
      expect(db.rows('users').map((u) => u['id']), contains(newUser.id));

      // Categorías normalizadas; TECNOLOGÍA reutiliza la existente.
      final categoryNames = db.rows('categories').map((c) => c['name']);
      expect(categoryNames, containsAll(['SOCIAL', 'TECNOLOGÍA']));
      expect(categoryNames.where((n) => n == 'TECNOLOGÍA'), hasLength(1));
      expect(
        db.rows('project_categories').where((l) => l['project_id'] == idea.id),
        hasLength(2),
      );
      expect(
        db.rows('project_skills').where((l) => l['project_id'] == idea.id),
        hasLength(2),
      );
      expect(idea.skills, containsAll(['GESTIÓN', 'FLUTTER']));
    });

    test('el feed muestra el proyecto nuevo con sus categorías', () async {
      final idea = await createProject(draft(), creator: otherUser);
      final feed = ApiIdeaDataSource(db, CatalogService(db));

      final social = await feed.fetchIdeas(category: 'SOCIAL');
      expect(social.map((i) => i.id), [idea.id]);
      expect(social.single.categories, ['SOCIAL', 'TECNOLOGÍA']);
      expect(await feed.fetchCategories(), ['TODAS', 'SOCIAL', 'TECNOLOGÍA']);
    });

    test('si falla una tabla puente se borra el proyecto', () async {
      db.failWhen = (operation, table) =>
          operation == 'insert' && table == 'project_skills';

      await expectLater(
        createProject(draft(), creator: creator),
        throwsA(isA<Exception>()),
      );
      expect(db.rows('projects'), hasLength(1));
    });
  });
}
