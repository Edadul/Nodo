/// Miembro visible del equipo de un proyecto (creador o postulante aceptado).
class TeamMember {
  const TeamMember({
    required this.userId,
    required this.name,
    required this.isCreator,
    this.avatarUrl,
    this.program = '',
  });

  final String userId;
  final String name;
  final bool isCreator;
  final String? avatarUrl;
  final String program;

  String get roleLabel => isCreator ? 'Creador' : 'Integrante';
}
