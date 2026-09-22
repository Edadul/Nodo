// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co';

  static const List<int> _enviedkeycontractId = <int>[
    4193534221,
    3688060707,
    3520021589,
    2065638778,
    485699058,
    3348614344,
    602841254,
    4280163940,
    299060745,
    683232343,
    2907871094,
    2177819733,
    2473504478,
    1659582554,
    4234914432,
  ];

  static const List<int> _envieddatacontractId = <int>[
    4193534307,
    3688060748,
    3520021553,
    2065638677,
    485698989,
    3348614313,
    602841247,
    4280163845,
    299060798,
    683232357,
    2907870995,
    2177819749,
    2473504443,
    1659582523,
    4234914530,
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
    1186118420,
    2723666434,
    3714372889,
    2176383514,
    2791218066,
    572505226,
    2233675455,
    3668752811,
    1416456694,
  ];

  static const List<int> _envieddataguestPassword = <int>[
    1186118483,
    2723666551,
    3714372988,
    2176383593,
    2791218150,
    572505252,
    2233675406,
    3668752793,
    1416456645,
  ];

  static final String guestPassword = String.fromCharCodes(
    List<int>.generate(
      _envieddataguestPassword.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddataguestPassword[i] ^ _enviedkeyguestPassword[i]),
  );
}
