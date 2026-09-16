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
      'https://roble-api.test-openlab.uninorte.edu.co';

  static const List<int> _enviedkeycontractId = <int>[
    3800058240,
    2491195865,
    4215515577,
    985323419,
    1241133504,
    3659981917,
    1285063660,
    4010442079,
    2188458565,
    690851189,
    2548930329,
    2546693769,
    1003877406,
    3202858937,
    2899346485,
  ];

  static const List<int> _envieddatacontractId = <int>[
    3800058350,
    2491195830,
    4215515613,
    985323508,
    1241133471,
    3659981884,
    1285063637,
    4010442046,
    2188458610,
    690851143,
    2548930428,
    2546693817,
    1003877499,
    3202858968,
    2899346519,
  ];

  static final String contractId = String.fromCharCodes(
    List<int>.generate(
      _envieddatacontractId.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatacontractId[i] ^ _enviedkeycontractId[i]),
  );
}
