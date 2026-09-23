import 'package:roble/roble.dart';
import '../lib/env/env.dart';

Future<void> main() async {
  final roble = RobleApiDataBase(
    config: RobleApiConfig.fromContract(
      baseUrl: Env.baseUrl,
      contractId: Env.contractId,
    ),
  );

  try {
    await roble.login(email: Env.guestEmail, password: Env.guestPassword);
    print('LOGIN GUEST: OK');
  } catch (e) {
    print('LOGIN GUEST: FAIL $e');
    return;
  }

  final me = await roble.currentUser();
  print('CURRENT USER raw: $me');

  final id = (me['userId'] ?? me['id'] ?? me['_id'] ?? '').toString();
  print('== USER ID: $id');

  Future<void> probe(String label, Future<dynamic> Function() fn) async {
    try {
      final r = await fn();
      final list = r is List ? r : null;
      print('$label -> ${list == null ? r : 'rows=${list.length}'}');
      if (list != null && list.isNotEmpty) {
        final copy = List<Map<String, dynamic>>.from(list);
        print('  FIRST ROW KEYS: ${copy.first.keys.toList()}');
        print('  FIRST ROW: ${copy.first}');
      }
    } catch (e) {
      print('$label -> ERROR: $e');
    }
  }

  await probe('read users (no filter)', () => roble.read('users'));
  await probe('read users filter _id', () => roble.read('users', filters: {'_id': id}));
  await probe('read users filter id', () => roble.read('users', filters: {'id': id}));
  await probe('read users filter _owner', () => roble.read('users', filters: {'_owner': id}));
  await probe('read projects filter creator_id', () => roble.read('projects', filters: {'creator_id': id}));
  await probe('read projects (no filter)', () => roble.read('projects'));

  await roble.logout();
  print('DONE');
}