import 'package:roble/roble.dart';

/// Regla de negocio incumplida. [message] se muestra tal cual al usuario.
class ValidationFailure implements Exception {
  const ValidationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Traduce cualquier error a un mensaje apto para la UI.
String friendlyErrorMessage(Object error) {
  if (error is ValidationFailure) return error.message;
  if (error is RobleApiForbiddenException) {
    return 'Tu cuenta no tiene permiso para realizar esta acción.';
  }
  if (error is RobleApiNotFoundException) {
    return 'El registro ya no existe.';
  }
  if (error is RobleApiConflictException) {
    return 'El registro ya existe.';
  }
  if (error is RobleApiNetworkException || error is RobleApiTimeoutException) {
    return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
  }
  if (error is RobleApiAuthException) {
    return 'Tu sesión expiró. Inicia sesión de nuevo.';
  }
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
