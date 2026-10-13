import '../core/db/db_interface.dart';
import '../core/db/row_parsing.dart';
import '../core/utils/uuid.dart';
import 'demo_mode.dart';

/// Base en memoria con proyectos, avances y catálogos para revisar UI/UX.
class DemoDatabase implements IDatabase {
  DemoDatabase() {
    _seed();
  }

  final Map<String, List<Map<String, dynamic>>> _tables = {};

  void _seed() {
    _tables['categories'] = [
      _row(id: 'cat-tech', data: {'name': 'TECNOLOGÍA'}),
      _row(id: 'cat-design', data: {'name': 'DISEÑO'}),
      _row(id: 'cat-social', data: {'name': 'SOCIAL'}),
      _row(id: 'cat-biz', data: {'name': 'NEGOCIOS'}),
    ];

    _tables['skills'] = [
      _row(id: 'sk-flutter', data: {'name': 'FLUTTER'}),
      _row(id: 'sk-ux', data: {'name': 'DISEÑO/UX'}),
      _row(id: 'sk-backend', data: {'name': 'BACKEND'}),
      _row(id: 'sk-data', data: {'name': 'DATOS'}),
      _row(id: 'sk-brand', data: {'name': 'BRANDING'}),
      _row(id: 'sk-mgmt', data: {'name': 'GESTIÓN'}),
      _row(id: 'sk-mobile', data: {'name': 'MÓVIL'}),
      _row(id: 'sk-community', data: {'name': 'COMUNIDAD'}),
    ];

    _tables['users'] = [
      _row(
        id: kDemoCreatorId,
        data: {
          'name': kDemoCreatorName,
          'username': 'ana.rivera',
          'bio': 'Diseño productos con estudiantes',
          'avatar_url': '',
          'posts_count': 3,
          'followers_count': 12,
          'favorites_count': 4,
        },
      ),
      _row(
        id: 'applicant-1',
        data: {
          'name': 'Luis Pérez',
          'username': 'luis.perez',
          'bio': 'Diseño UX',
          'avatar_url': '',
        },
      ),
      _row(
        id: 'applicant-2',
        data: {
          'name': 'María Gómez',
          'username': 'maria.gomez',
          'bio': 'Gestión de proyectos',
          'avatar_url': '',
        },
      ),
    ];

    _tables['projects'] = [
      _project(
        id: 'proj-1',
        title: 'Huerta urbana colaborativa',
        description:
            'Diseñamos y construimos una huerta comunitaria en el campus. Buscamos gente de diseño, gestión y voluntariado.',
        status: 'in_progress',
        filled: 3,
        total: 6,
        gradient: RowParsing.encodeColors(const [0xFF7B6CF0, 0xFFB8A9FF]),
        creatorId: kDemoCreatorId,
      ),
      _project(
        id: 'proj-2',
        title: 'Asistente de estudio con IA',
        description:
            'Plataforma que resume apuntes y genera quizzes. Equipo backend + datos + móvil.',
        status: 'idea',
        filled: 2,
        total: 5,
        gradient: RowParsing.encodeColors(const [0xFF4A3CC7, 0xFF7A6BE8]),
        creatorId: kDemoCreatorId,
      ),
      _project(
        id: 'proj-3',
        title: 'Marca local upcycled',
        description:
            'Identidad y packaging para moda con materiales reutilizados. Enfoque branding y producto.',
        status: 'idea',
        filled: 1,
        total: 4,
        gradient: RowParsing.encodeColors(const [0xFF6A5AE0, 0xFF9B8CF5]),
        creatorId: 'otro-user',
      ),
      _project(
        id: 'proj-4',
        title: 'Marketplace de freelancers',
        description:
            'Conectar talento del campus con microencargos de empresas locales.',
        status: 'closed',
        filled: 4,
        total: 4,
        gradient: RowParsing.encodeColors(const [0xFF553ECF, 0xFF8E7DF0]),
        creatorId: 'otro-user',
      ),
      _project(
        id: 'proj-5',
        title: 'App de voluntariado por barrios',
        description:
            'Mapear necesidades locales y coordinar jornadas entre vecinos y estudiantes.',
        status: 'in_progress',
        filled: 2,
        total: 6,
        gradient: RowParsing.encodeColors(const [0xFF6858E8, 0xFFA99BFF]),
        creatorId: kDemoCreatorId,
      ),
    ];

    _tables['project_categories'] = [
      _link(projectId: 'proj-1', otherId: 'cat-social', key: 'category_id'),
      _link(projectId: 'proj-2', otherId: 'cat-tech', key: 'category_id'),
      _link(projectId: 'proj-3', otherId: 'cat-design', key: 'category_id'),
      _link(projectId: 'proj-4', otherId: 'cat-biz', key: 'category_id'),
      _link(projectId: 'proj-5', otherId: 'cat-social', key: 'category_id'),
    ];

    _tables['project_skills'] = [
      _link(projectId: 'proj-1', otherId: 'sk-ux', key: 'skill_id'),
      _link(projectId: 'proj-1', otherId: 'sk-mgmt', key: 'skill_id'),
      _link(projectId: 'proj-2', otherId: 'sk-backend', key: 'skill_id'),
      _link(projectId: 'proj-2', otherId: 'sk-data', key: 'skill_id'),
      _link(projectId: 'proj-3', otherId: 'sk-brand', key: 'skill_id'),
      _link(projectId: 'proj-4', otherId: 'sk-mgmt', key: 'skill_id'),
      _link(projectId: 'proj-5', otherId: 'sk-mobile', key: 'skill_id'),
      _link(projectId: 'proj-5', otherId: 'sk-community', key: 'skill_id'),
    ];

    final now = DateTime.now().toUtc();
    _tables['project_updates'] = [
      _update(
        projectId: 'proj-1',
        title: 'Primera siembra lista',
        body:
            'Armamos 4 camas elevadas y sembramos hierbas. El sábado abrimos jornada abierta.',
        daysAgo: 2,
        status: 'in_progress',
        now: now,
      ),
      _update(
        projectId: 'proj-1',
        title: 'Buscamos voluntarios de riego',
        body: 'Necesitamos 2 personas para turnos de mañana esta semana.',
        daysAgo: 5,
        now: now,
      ),
      _update(
        projectId: 'proj-2',
        title: 'Prototipo de resumen',
        body: 'Ya sube un PDF y devuelve 5 bullets. Siguiente: quizzes.',
        daysAgo: 1,
        status: 'idea',
        now: now,
      ),
      _update(
        projectId: 'proj-5',
        title: 'Mapa del barrio centro',
        body: 'Validamos 12 puntos de ayuda con la junta de acción comunal.',
        daysAgo: 3,
        status: 'in_progress',
        now: now,
      ),
    ];

    _tables['applications'] = [
      _row(
        id: 'app-1',
        data: {
          'project_id': 'proj-1',
          'applicant_id': 'applicant-1',
          'status': 'pending',
          'message': 'Me interesa el diseño de la huerta',
          'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        },
      ),
      _row(
        id: 'app-2',
        data: {
          'project_id': 'proj-1',
          'applicant_id': 'applicant-2',
          'status': 'accepted',
          'message': 'Puedo ayudar con gestión',
          'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
        },
      ),
    ];
  }

  Map<String, dynamic> _row({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return {
      '_id': 'rec-$id',
      'id': id,
      ...data,
    };
  }

  Map<String, dynamic> _project({
    required String id,
    required String title,
    required String description,
    required String status,
    required int filled,
    required int total,
    required String gradient,
    required String creatorId,
  }) {
    return _row(
      id: id,
      data: {
        'title': title,
        'description': description,
        'status': status,
        'filled_spots': filled,
        'total_spots': total,
        'gradient_colors': gradient,
        'creator_id': creatorId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
  }

  Map<String, dynamic> _link({
    required String projectId,
    required String otherId,
    required String key,
  }) {
    return _row(
      id: '$projectId-$otherId',
      data: {
        'project_id': projectId,
        key: otherId,
      },
    );
  }

  Map<String, dynamic> _update({
    required String projectId,
    required String title,
    required String body,
    required int daysAgo,
    required DateTime now,
    String? status,
  }) {
    final id = generateUuidV4();
    return _row(
      id: id,
      data: {
        'project_id': projectId,
        'author_id': kDemoCreatorId,
        'author_name': kDemoCreatorName,
        'title': title,
        'body': body,
        'created_at': now.subtract(Duration(days: daysAgo)).toIso8601String(),
        if (status != null) 'status': status,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> read(
    String tableName, {
    Map<String, dynamic>? filters,
  }) async {
    final rows = _tables.putIfAbsent(tableName, () => []);
    if (filters == null || filters.isEmpty) {
      return rows.map((r) => Map<String, dynamic>.from(r)).toList();
    }
    return rows
        .where((row) => filters.entries.every((e) => '${row[e.key]}' == '${e.value}'))
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> insert(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    final id = data['id']?.toString().isNotEmpty == true
        ? data['id'].toString()
        : generateUuidV4();
    final row = {
      '_id': data['_id']?.toString() ?? 'rec-$id',
      ...data,
      'id': id,
    };
    _tables.putIfAbsent(tableName, () => []).add(row);
    return Map<String, dynamic>.from(row);
  }

  @override
  Future<void> update(
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    final rows = _tables.putIfAbsent(tableName, () => []);
    final index = rows.indexWhere((r) => r['_id'] == recordId);
    if (index < 0) return;
    rows[index] = {...rows[index], ...data};
  }

  @override
  Future<void> delete(String tableName, String recordId) async {
    final rows = _tables.putIfAbsent(tableName, () => []);
    rows.removeWhere((r) => r['_id'] == recordId);
  }
}
