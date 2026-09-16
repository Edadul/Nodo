import 'package:roble/roble.dart';
import '../../env/env.dart';

abstract class Roble {
  static final robleDatabase = RobleApiDataBase(
    config: RobleApiConfig.fromContract(
      baseUrl: Env.baseUrl,
      contractId: Env.contractId,
    ),
  );
}
