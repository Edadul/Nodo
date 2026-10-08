/// Fases del ciclo de vida del proyecto (badge, no %).
enum ProjectStatus {
  idea('idea', 'Idea', 'Reclutando equipo'),
  inProgress('in_progress', 'En desarrollo', 'El equipo ya avanza'),
  closed('closed', 'Cerrado', 'Proyecto finalizado');

  const ProjectStatus(this.storageValue, this.label, this.subtitle);

  final String storageValue;
  final String label;
  final String subtitle;

  static ProjectStatus fromStorage(String? value) {
    return ProjectStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => ProjectStatus.idea,
    );
  }
}
