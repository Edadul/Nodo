// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const String baseUrl = 'https://roble-api.openlab.uninorte.edu.co';

  static const List<int> _enviedkeycontractId = <int>[
    3608013753,
    2001237210,
    2658145310,
    4289616423,
    2867535860,
    523751461,
    2552007411,
    2654395457,
    1348598579,
    642256915,
    1879438920,
    3969459081,
    3556497848,
    359578763,
    4217239877,
  ];

  static const List<int> _envieddatacontractId = <int>[
    3608013783,
    2001237173,
    2658145402,
    4289616456,
    2867535787,
    523751492,
    2552007370,
    2654395424,
    1348598532,
    642256929,
    1879438893,
    3969459129,
    3556497885,
    359578858,
    4217239847,
  ];

  static final String contractId = String.fromCharCodes(
    List<int>.generate(
      _envieddatacontractId.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatacontractId[i] ^ _enviedkeycontractId[i]),
  );

  static const String guestEmail = 'guest@roble.local';

  static const List<int> _enviedkeyguestPassword = <int>[
    1054050070,
    3550972257,
    444540866,
    4152563920,
    2910469094,
    3118904916,
    4160100621,
    1645488108,
    735974767,
  ];

  static const List<int> _envieddataguestPassword = <int>[
    1054050129,
    3550972180,
    444540839,
    4152563875,
    2910469010,
    3118904954,
    4160100668,
    1645488094,
    735974748,
  ];

  static final String guestPassword = String.fromCharCodes(
    List<int>.generate(
      _envieddataguestPassword.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddataguestPassword[i] ^ _enviedkeyguestPassword[i]),
  );
}
