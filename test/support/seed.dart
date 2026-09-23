import 'package:nodo/features/auth/domain/entities/user.dart';

import 'fake_database.dart';

const creator = User(id: 'u-creator', name: 'Ana Creadora', email: 'ana@uni.edu');
const applicantUser =
    User(id: 'u-applicant', name: 'Luis Postulante', email: 'luis@uni.edu');
const otherUser = User(id: 'u-other', name: 'Sara Otra', email: 'sara@uni.edu');
const guest = User(
  id: 'u-guest',
  name: 'guest',
  email: 'guest@roble.local',
  isGuest: true,
);

const projectId = 'p-1';

/// BD con un proyecto de [creator] (2 cupos), una postulación pendiente de
/// [applicantUser] y otra de [otherUser].
FakeDatabase seededDatabase({int filledSpots = 0, int totalSpots = 2}) {
  return FakeDatabase({
    'users': [
      {'id': creator.id, 'username': 'ana', 'name': creator.name},
      {
        'id': applicantUser.id,
        'username': 'luis',
        'name': applicantUser.name,
        'program': 'Ingeniería de Sistemas',
        'university': 'Uninorte',
      },
      {'id': otherUser.id, 'username': 'sara', 'name': otherUser.name},
    ],
    'projects': [
      {
        'id': projectId,
        'creator_id': creator.id,
        'title': 'Plataforma Nodo',
        'description': 'Conectar estudiantes con proyectos colaborativos.',
        'total_spots': totalSpots,
        'filled_spots': filledSpots,
        'gradient_colors': '["0xFF7B6CF0", "0xFFB8A9FF"]',
        'created_at': '2026-09-20T10:00:00.000Z',
      },
    ],
    'categories': [
      {'id': 'c-tec', 'name': 'TECNOLOGÍA'},
    ],
    'project_categories': [
      {'project_id': projectId, 'category_id': 'c-tec'},
    ],
    'skills': [
      {'id': 's-flutter', 'name': 'FLUTTER'},
    ],
    'project_skills': [
      {'project_id': projectId, 'skill_id': 's-flutter'},
    ],
    'user_skills': [
      {'user_id': applicantUser.id, 'skill_id': 's-flutter'},
    ],
    'applications': [
      {
        'id': 'a-luis',
        'project_id': projectId,
        'applicant_id': applicantUser.id,
        'motivation': 'Tengo experiencia en Flutter y quiero aportar.',
        'experience': '1 a 2 años',
        'status': 'pending',
        'submitted_at': '2026-09-21T10:00:00.000Z',
      },
      {
        'id': 'a-sara',
        'project_id': projectId,
        'applicant_id': otherUser.id,
        'motivation': 'Me interesa el diseño del producto y la UX.',
        'experience': 'Menos de 1 año',
        'status': 'pending',
        'submitted_at': '2026-09-22T10:00:00.000Z',
      },
    ],
  });
}
