import '../../domain/entities/application.dart';

/// Contrato del feature Application (postulaciones).
abstract class ApplicationRepository {
  Future<Application> submit(Application application);
}