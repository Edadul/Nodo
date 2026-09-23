import 'package:nodo/core/db/db_interface.dart';

/// [IDatabase] en memoria con la semántica usada de Roble: cada fila recibe un
/// `_id`, `read` filtra por igualdad y `update`/`delete` van por `_id`.
class FakeDatabase implements IDatabase {
  FakeDatabase([Map<String, List<Map<String, dynamic>>>? seed]) {
    seed?.forEach((table, rows) {
      for (final row in rows) {
        _insertSync(table, row);
      }
    });
  }

  final Map<String, List<Map<String, dynamic>>> tables = {};
  int _nextId = 1;

  /// Si devuelve true para (operación, tabla) la llamada lanza, para probar
  /// errores y rollbacks. Operaciones: read, insert, update, delete.
  bool Function(String operation, String table)? failWhen;

  List<Map<String, dynamic>> rows(String table) => tables[table] ?? [];

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    _maybeFail('read', tableName);
    return rows(tableName)
        .where((row) => (filters ?? {}).entries.every(
              (filter) => '${row[filter.key]}' == '${filter.value}',
            ))
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> insert(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    _maybeFail('insert', tableName);
    return Map.of(_insertSync(tableName, data));
  }

  @override
  Future<void> update(
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    _maybeFail('update', tableName);
    final row = rows(tableName).firstWhere(
      (row) => row['_id'] == recordId,
      orElse: () => throw StateError('404 $tableName/$recordId'),
    );
    row.addAll(data);
  }

  @override
  Future<void> delete(String tableName, String recordId) async {
    _maybeFail('delete', tableName);
    rows(tableName).removeWhere((row) => row['_id'] == recordId);
  }

  Map<String, dynamic> _insertSync(String table, Map<String, dynamic> data) {
    final row = {'_id': 'rec-${_nextId++}', ...data};
    tables.putIfAbsent(table, () => []).add(row);
    return row;
  }

  void _maybeFail(String operation, String table) {
    if (failWhen?.call(operation, table) ?? false) {
      throw Exception('Fallo simulado: $operation $table');
    }
  }
}
