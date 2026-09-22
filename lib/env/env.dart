import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'BASE_URL')
  static final String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'CONTRACT_ID', obfuscate: true)
  static final String contractId = _Env.contractId;

  @EnviedField(varName: 'GUEST_EMAIL')
  static final String guestEmail = _Env.guestEmail;

  @EnviedField(varName: 'GUEST_PASSWORD', obfuscate: true)
  static final String guestPassword = _Env.guestPassword;
}
