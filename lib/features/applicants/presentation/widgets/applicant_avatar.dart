import 'package:flutter/material.dart';

import '../../../../core/theme/nodo_theme.dart';

class ApplicantAvatar extends StatelessWidget {
  const ApplicantAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 18,
  });

  final String name;
  final String? avatarUrl;
  final double radius;

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = words.take(2).map((word) => word[0].toUpperCase());
    return letters.isEmpty ? '?' : letters.join();
  }

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: NodoColors.primaryMuted,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: NodoColors.primaryMuted,
      child: Text(
        _initials,
        style: TextStyle(
          color: NodoColors.primaryDark,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.65,
        ),
      ),
    );
  }
}
