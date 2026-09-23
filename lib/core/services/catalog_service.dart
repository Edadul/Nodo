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

  /// Caché en memoria de `id → name` por tabla. Los catálogos cambian poco y
  /// se leen en casi cada pantalla (home, crear proyecto, postular...), así
  /// que releerlos por red cada vez agota rápido la cuota de peticiones del
  /// backend. Vive mientras viva esta instancia (un singleton en el DI), así
  /// que se comparte entre pantallas durante toda la sesión.
  final Map<CatalogTable, Map<String, String>> _cache = {};

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

  /// Mapa `id → name` de todo el catálogo. Se sirve de caché salvo la
  /// primera vez o cuando `forceRefresh` lo pide explícitamente.
  Future<Map<String, String>> readAll(
    CatalogTable table, {
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) _cache.remove(table);

    final cached = _cache[table];
    if (cached != null) return cached;

    final rows = await _database.read(table.tableName);
    final map = <String, String>{
      for (final row in rows)
        if (RowParsing.text(row['name']) != null)
          RowParsing.schemaId(row): RowParsing.text(row['name'])!,
    };
    _cache[table] = map;
    return map;
  }

  /// Devuelve el `id` del registro con ese nombre, creándolo si no existe.
  Future<String> ensure(CatalogTable table, String name) async {
    final normalized = normalize(name);
    final existing = await _findId(table, normalized);
    if (existing != null) return existing;

    final id = generateUuidV4();
    try {
      await _database.insert(table.tableName, {'id': id, 'name': normalized});
      _cache[table]?[id] = normalized;
      return id;
    } catch (_) {
      // Otro usuario pudo crearlo a la vez (name es UNIQUE): la caché local
      // no se habría enterado, así que aquí sí toca ir a red.
      final created = await _findId(table, normalized, forceRefresh: true);
      if (created != null) return created;
      rethrow;
    }
  }

  Future<String?> _findId(
    CatalogTable table,
    String name, {
    bool forceRefresh = false,
  }) async {
    final all = await readAll(table, forceRefresh: forceRefresh);
    for (final entry in all.entries) {
      if (entry.value == name) return entry.key;
    }
    return null;
  }
}
