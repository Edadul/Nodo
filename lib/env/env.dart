import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de Roble.
///
/// Con los defaults del contrato basta `flutter run`.
/// Opcional: archivo `.env` / `.env.example` o `--dart-define`.
abstract final class Env {
  static bool _loaded = false;

  static String _baseUrl = 'https://roble-api.openlab.uninorte.edu.co';
  static String _contractId = 'nodo_a9a72e0eab';
  static String _guestEmail = 'guest@roble.local';
  static String _guestPassword = '';

  static String get baseUrl => _baseUrl;
  static String get contractId => _contractId;
  static String get guestEmail => _guestEmail;
  static String get guestPassword => _guestPassword;

  static bool get hasContract => contractId.trim().isNotEmpty;

  static bool get hasGuestCredentials =>
      guestEmail.isNotEmpty && guestPassword.isNotEmpty;

  static Future<void> load() async {
    if (_loaded) return;

    for (final file in ['.env', '.env.example']) {
      try {
        await dotenv.load(fileName: file);
        break;
      } catch (_) {
        // Sigue con defaults.
      }
    }

    _baseUrl = _pick('BASE_URL', _baseUrl);
    _contractId = _pick('CONTRACT_ID', _contractId);
    _guestEmail = _pick('GUEST_EMAIL', _guestEmail);
    _guestPassword = _pick('GUEST_PASSWORD', _guestPassword);

    _loaded = true;
  }

  static String _pick(String key, String fallback) {
    const defines = <String, String>{
      'BASE_URL': String.fromEnvironment('BASE_URL'),
      'CONTRACT_ID': String.fromEnvironment('CONTRACT_ID'),
      'GUEST_EMAIL': String.fromEnvironment('GUEST_EMAIL'),
      'GUEST_PASSWORD': String.fromEnvironment('GUEST_PASSWORD'),
    };

    final fromDefine = defines[key] ?? '';
    if (fromDefine.isNotEmpty) return fromDefine.trim();

    if (dotenv.isInitialized) {
      final fromFile = dotenv.maybeGet(key)?.trim() ?? '';
      if (fromFile.isNotEmpty) return fromFile;
    }

    return fallback;
  }
}
