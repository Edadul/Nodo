import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/core/theme/nodo_theme.dart';
import 'package:nodo/features/projects/domain/entities/project_status.dart';
import 'package:nodo/features/projects/domain/entities/project_update.dart';
import 'package:nodo/features/projects/presentation/widgets/project_status_badge.dart';
import 'package:nodo/features/projects/presentation/widgets/project_updates_timeline.dart';

ProjectUpdate _update(
  String id,
  String title, {
  DateTime? createdAt,
  ProjectStatus? status,
}) {
  return ProjectUpdate(
    id: id,
    recordId: 'rec-$id',
    projectId: 'project-1',
    authorId: 'user-1',
    authorName: 'Autor $id',
    title: title,
    body: 'Detalle de $title',
    createdAt: createdAt ?? DateTime(2026, 3, 5, 14, 30),
    status: status,
  );
}

Future<void> _pumpTimeline(
  WidgetTester tester,
  List<ProjectUpdate> updates, {
  String? emptyMessage,
}) {
  final timeline = emptyMessage == null
      ? ProjectUpdatesTimeline(updates: updates)
      : ProjectUpdatesTimeline(updates: updates, emptyMessage: emptyMessage);
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: timeline)),
    ),
  );
}

void main() {
  group('ProjectUpdatesTimeline sin actualizaciones', () {
    testWidgets('muestra el mensaje vacío por defecto',
        (WidgetTester tester) async {
      await _pumpTimeline(tester, const []);

      expect(
        find.text(
          'Aún no hay actualizaciones. El equipo puede publicar el avance '
          'del proyecto.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ProjectStatusBadge), findsNothing);
    });

    testWidgets('usa el mensaje vacío personalizado con su estilo secundario',
        (WidgetTester tester) async {
      await _pumpTimeline(tester, const [], emptyMessage: 'Sin avances aún');

      final finder = find.text('Sin avances aún');
      expect(finder, findsOneWidget);

      final text = finder.evaluate().first.widget as Text;
      expect(text.style!.color, equals(NodoColors.textSecondary));
      expect(text.style!.fontSize, equals(13.5));
    });
  });

  group('ProjectUpdatesTimeline con actualizaciones', () {
    testWidgets('pinta una entrada por actualización, identificada por key',
        (WidgetTester tester) async {
      await _pumpTimeline(tester, [
        _update('u-3', 'Lanzamos la beta'),
        _update('u-2', 'Prototipo listo'),
        _update('u-1', 'Arrancamos'),
      ]);

      expect(find.byKey(const ValueKey('timeline-entry-u-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('timeline-entry-u-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('timeline-entry-u-1')), findsOneWidget);
      expect(find.text('Lanzamos la beta'), findsOneWidget);
      expect(find.text('Detalle de Prototipo listo'), findsOneWidget);
      expect(find.text('Autor u-1'), findsOneWidget);
    });

    testWidgets('cada entrada contiene su propio título y autor',
        (WidgetTester tester) async {
      await _pumpTimeline(tester, [
        _update('u-2', 'Segundo avance'),
        _update('u-1', 'Primer avance'),
      ]);

      final firstEntry = find.byKey(const ValueKey('timeline-entry-u-2'));
      expect(
        find.descendant(of: firstEntry, matching: find.text('Segundo avance')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: firstEntry, matching: find.text('Primer avance')),
        findsNothing,
      );
    });

    testWidgets('formatea la fecha en español sin depender de intl',
        (WidgetTester tester) async {
      await _pumpTimeline(tester, [
        _update('u-1', 'Avance', createdAt: DateTime(2026, 3, 5, 9, 7)),
      ]);

      expect(find.text('5 mar · 09:07'), findsOneWidget);
    });

    testWidgets('muestra la insignia solo si la actualización cambió el estado',
        (WidgetTester tester) async {
      await _pumpTimeline(tester, [
        _update('u-2', 'Pasamos a desarrollo',
            status: ProjectStatus.inProgress),
        _update('u-1', 'Sin cambio de estado'),
      ]);

      expect(find.byType(ProjectStatusBadge), findsOneWidget);
      expect(find.text('En desarrollo'), findsOneWidget);
    });

    testWidgets('el título se destaca sobre el cuerpo del texto',
        (WidgetTester tester) async {
      await _pumpTimeline(tester, [_update('u-1', 'Título del avance')]);

      final title =
          find.text('Título del avance').evaluate().first.widget as Text;
      final body =
          find.text('Detalle de Título del avance').evaluate().first.widget
              as Text;

      expect(title.style!.fontWeight, equals(FontWeight.w800));
      expect(title.style!.color, equals(NodoColors.textPrimary));
      expect(title.style!.fontSize, greaterThan(body.style!.fontSize!));
    });
  });
}
