import '../../domain/entities/application.dart';

/// Contrato de fuente de datos del feature Application (postulaciones).
abstract class ApplicationDataSource {
  Future<Application> insertApplication(Application application);
}