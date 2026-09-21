import 'package:flutter_test/flutter_test.dart';
import 'package:nodo/features/applicants/presentation/utils/relative_time.dart';

void main() {
  final now = DateTime(2026, 9, 16, 18, 0);

  test('mismo día muestra "Hoy, HH:mm"', () {
    final submittedAt = DateTime(2026, 9, 16, 10, 24);
    expect(formatRelativeSubmittedAt(submittedAt, now: now), 'Hoy, 10:24 AM');
  });

  test('día anterior muestra "Ayer"', () {
    final submittedAt = DateTime(2026, 9, 15, 9, 0);
    expect(formatRelativeSubmittedAt(submittedAt, now: now), 'Ayer');
  });

  test('varios días atrás muestra "Hace N días"', () {
    final submittedAt = DateTime(2026, 9, 12, 9, 0);
    expect(formatRelativeSubmittedAt(submittedAt, now: now), 'Hace 4 días');
  });

  test('hora de la tarde usa formato PM', () {
    final submittedAt = DateTime(2026, 9, 16, 15, 5);
    expect(formatRelativeSubmittedAt(submittedAt, now: now), 'Hoy, 3:05 PM');
  });
}
