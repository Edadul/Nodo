class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.isGuest = false,
  });

  /// `userId` de Roble: es el valor de `users.id` y de las FKs
  /// `projects.creator_id` / `applications.applicant_id`.
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  /// Sesión pública compartida (solo lectura).
  final bool isGuest;
}
