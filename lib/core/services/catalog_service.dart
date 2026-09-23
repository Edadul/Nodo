import '../db/db_interface.dart';
import '../db/row_parsing.dart';
import '../utils/uuid.dart';

/// Tablas catálogo `categories` y `skills` (columna `name` única).
enum CatalogTable {
  categories('categories'),
  skills('skills');

  const CatalogTable(this.tableName);

  final String tableName;
}

class CatalogService {
  CatalogService(this._database);

  final IDatabase _database;

  static const nameMinLength = 2;
  static const nameMaxLength = 40;

  /// Mensaje de error para un nombre de categoría/habilidad, o null si es
  /// válido.
  static String? validateName(String value) {
    final name = normalize(value);
    if (name.length < nameMinLength) return 'Mínimo $nameMinLength caracteres';
    if (name.length > nameMaxLength) return 'Máximo $nameMaxLength caracteres';
    return null;
  }

  /// Mayúsculas y espacios simples, para que "ux  design" y "UX Design" sean
  /// el mismo registro.
  static String normalize(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();

  /// Mapa `id → name` de todo el catálogo.
  Future<Map<String, String>> readAll(CatalogTable table) async {
    final rows = await _database.read(table.tableName);
    return {
      for (final row in rows)
        if (RowParsing.text(row['name']) != null)
          RowParsing.schemaId(row): RowParsing.text(row['name'])!,
    };
  }

  /// Devuelve el `id` del registro con ese nombre, creándolo si no existe.
  Future<String> ensure(CatalogTable table, String name) async {
    final normalized = normalize(name);
    final existing = await _findId(table, normalized);
    if (existing != null) return existing;

    final id = generateUuidV4();
    try {
      await _database.insert(table.tableName, {'id': id, 'name': normalized});
      return id;
    } catch (_) {
      // Otro usuario pudo crearlo a la vez (name es UNIQUE).
      final created = await _findId(table, normalized);
      if (created != null) return created;
      rethrow;
    }
  }

  Future<String?> _findId(CatalogTable table, String name) async {
    final rows = await _database.read(table.tableName, filters: {'name': name});
    return rows.isEmpty ? null : RowParsing.schemaId(rows.first);
  }
}
