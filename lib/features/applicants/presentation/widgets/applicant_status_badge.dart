import 'package:flutter/material.dart';

import '../../domain/entities/applicant_status.dart';

class ApplicantStatusBadge extends StatelessWidget {
  const ApplicantStatusBadge({super.key, required this.status});

  final ApplicantStatus status;

  static const _backgroundColors = {
    ApplicantStatus.pending: Color(0xFFEDE7FA),
    ApplicantStatus.accepted: Color(0xFFE8F8EA),
    ApplicantStatus.rejected: Color(0xFFFEECEE),
  };

  static const _textColors = {
    ApplicantStatus.pending: Color(0xFF7C5CD1),
    ApplicantStatus.accepted: Color(0xFF26B932),
    ApplicantStatus.rejected: Color(0xFFF34A4A),
  };

  static const _labels = {
    ApplicantStatus.pending: 'Pendiente',
    ApplicantStatus.accepted: 'Aceptado',
    ApplicantStatus.rejected: 'Rechazado',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColors[status],
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        _labels[status]!,
        style: TextStyle(
          color: _textColors[status],
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
