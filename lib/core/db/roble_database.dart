import 'package:roble/roble.dart';

import '../../env/env.dart';
import 'db_interface.dart';

class Roble implements IDatabase {
  static final robleDatabase = RobleApiDataBase(
    config: RobleApiConfig.fromContract(
      baseUrl: Env.baseUrl,
      contractId: Env.contractId,
    ),
  );

  /// La sesión real la abre [AuthRepository.restoreOrGuest].
  /// Aquí solo se asegura que el cliente exista.
  Future<void> init() async {
    // no-op: bootstrap de auth ocurre en AuthViewModel.bootstrap()
  }

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) {
    // Sin sesión (ni guest ni anónimo): lee tablas públicas.
    if (!robleDatabase.isLoggedIn) {
      return robleDatabase.publicRead(tableName, filters: filters);
    }
    return robleDatabase.read(tableName, filters: filters);
  }

  @override
  Future<Map<String, dynamic>> insert(
    String tableName,
    Map<String, dynamic> data,
  ) {
    return robleDatabase.create(tableName, data);
  }

  @override
  Future<void> update(
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    await robleDatabase.update(tableName, recordId, data);
  }

  @override
  Future<void> delete(String tableName, String recordId) async {
    await robleDatabase.delete(tableName, recordId);
  }
}
