/// Contrato mínimo de persistencia que usan los datasources.
///
/// Cada fila de Roble trae dos identificadores:
/// - `_id`: lo asigna Roble y es el que usan [update] y [delete].
/// - `id`: la llave primaria del schema (UUID), la que referencian las FKs.
abstract class IDatabase {
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  });

  Future<Map<String, dynamic>> insert(
    String tableName,
    Map<String, dynamic> data,
  );

  /// Actualiza la fila cuyo `_id` es [recordId].
  Future<void> update(
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  );

  /// Borra la fila cuyo `_id` es [recordId].
  Future<void> delete(String tableName, String recordId);
}
