/// Configuración de Roble (contrato Nodo).
///
/// La clave del invitado se pasa con:
/// `--dart-define=GUEST_PASSWORD=...`
abstract final class Env {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://roble-api.openlab.uninorte.edu.co',
  );

  static const String contractId = String.fromEnvironment(
    'CONTRACT_ID',
    defaultValue: 'nodo_a9a72e0eab',
  );

  static const String guestEmail = String.fromEnvironment(
    'GUEST_EMAIL',
    defaultValue: 'guest@roble.local',
  );

  static const String guestPassword = String.fromEnvironment(
    'GUEST_PASSWORD',
  );

  static bool get hasContract => contractId.trim().isNotEmpty;

  static bool get hasGuestCredentials =>
      guestEmail.isNotEmpty && guestPassword.isNotEmpty;
}
