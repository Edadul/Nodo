/// Estado de una postulación desde la perspectiva del administrador.
enum ApplicantStatus {
  pending,
  accepted,
  rejected;

  /// Serializa a texto para persistencia (BD).
  String get storageValue => name;

  static ApplicantStatus fromStorage(String? value) {
    return ApplicantStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => ApplicantStatus.pending,
    );
  }
}
