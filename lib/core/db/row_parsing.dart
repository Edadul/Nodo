import 'dart:convert';

/// Helpers para leer filas de Roble sin asumir tipos exactos.
abstract final class RowParsing {
  /// Llave primaria del schema (`id`), la que referencian las FKs.
  static String schemaId(Map<String, dynamic> row) =>
      text(row['id']) ?? text(row['_id']) ?? '';

  /// Identificador interno de Roble (`_id`), el que usan update/delete.
  static String recordId(Map<String, dynamic> row) =>
      text(row['_id']) ?? text(row['id']) ?? '';

  static String? text(Object? value) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result == 'null' ? null : result;
  }

  static int integer(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static DateTime? dateTime(Object? value) {
    final raw = text(value);
    return raw == null ? null : DateTime.tryParse(raw)?.toLocal();
  }

  /// `gradient_colors` se guarda como JSON: `["0xFF7B6CF0", "0xFFB8A9FF"]`.
  static List<int>? colors(Object? value) {
    final raw = text(value);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final colors = decoded
          .map((color) => color is int ? color : int.tryParse('$color'))
          .whereType<int>()
          .toList(growable: false);
      return colors.length >= 2 ? colors : null;
    } on FormatException {
      return null;
    }
  }

  static String encodeColors(List<int> colors) => jsonEncode(
        colors
            .map((color) => '0x${color.toRadixString(16).toUpperCase()}')
            .toList(),
      );
}
