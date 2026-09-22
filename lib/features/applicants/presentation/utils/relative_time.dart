/// Formatea una fecha de envío como texto relativo corto, ej. "Hoy, 10:24 AM",
/// "Ayer" o "Hace 4 días". Puro (sin dependencias de Flutter) para ser testeable.
String formatRelativeSubmittedAt(DateTime submittedAt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final referenceDay = DateTime(reference.year, reference.month, reference.day);
  final submittedDay = DateTime(
    submittedAt.year,
    submittedAt.month,
    submittedAt.day,
  );
  final dayDifference = referenceDay.difference(submittedDay).inDays;

  if (dayDifference <= 0) {
    return 'Hoy, ${_formatHour(submittedAt)}';
  }
  if (dayDifference == 1) {
    return 'Ayer';
  }
  return 'Hace $dayDifference días';
}

String _formatHour(DateTime dateTime) {
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  var hour12 = dateTime.hour % 12;
  if (hour12 == 0) hour12 = 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour12:$minute $period';
}
