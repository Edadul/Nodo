import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import 'applicant_datasource.dart';

/// Implementación en memoria con datos de ejemplo (demo / tests).
class MockApplicantDataSource implements ApplicantDataSource {
  MockApplicantDataSource({List<Applicant>? seed})
      : _applicants = List<Applicant>.from(seed ?? _defaultSeed());

  final List<Applicant> _applicants;

  static List<Applicant> _defaultSeed() {
    final now = DateTime.now();
    return [
      Applicant(
        id: 1,
        projectId: 1,
        name: 'María García',
        program: 'Estudiante de Biología, 4to semestre',
        university: 'Universidad de Chile',
        motivation:
            'Hola María, me interesa mucho sumarme porque estudio biología y '
            'tengo experiencia en compostaje urbano. Me gustaría ayudar con '
            'la gestión técnica y estructurar los talleres didácticos para '
            'la comunidad.',
        skills: const ['BIOLOGÍA', 'COMPOSTAJE', 'GESTIÓN DE EQUIPOS'],
        status: ApplicantStatus.pending,
        submittedAt: DateTime(now.year, now.month, now.day, 10, 24),
        attachmentName: 'CV_Maria_Garcia.pdf',
        attachmentSizeLabel: 'PDF • 2.4 MB',
      ),
      Applicant(
        id: 2,
        projectId: 1,
        name: 'Juan Pérez',
        program: 'Estudiante de Diseño, 6to semestre',
        university: 'Universidad de Chile',
        motivation:
            'Hola! Tengo experiencia en diseño UX/UI y me gustaría aportar '
            'en la construcción de los prototipos y la identidad visual del '
            'proyecto.',
        skills: const ['UX/UI', 'FIGMA', 'PROTOTIPADO'],
        status: ApplicantStatus.accepted,
        submittedAt: now.subtract(const Duration(days: 1)),
        attachmentName: 'CV_Juan_Perez.pdf',
        attachmentSizeLabel: 'PDF • 1.1 MB',
      ),
      Applicant(
        id: 3,
        projectId: 1,
        name: 'Sofía Ruiz',
        program: 'Estudiante de Agronomía, 3er semestre',
        university: 'Universidad de Concepción',
        motivation:
            'Hola, soy de agronomía y me encanta la propuesta. Quiero '
            'aportar conocimientos sobre cultivos urbanos y manejo de '
            'huertas comunitarias.',
        skills: const ['AGRONOMÍA', 'HUERTOS URBANOS'],
        status: ApplicantStatus.pending,
        submittedAt: now.subtract(const Duration(days: 2)),
      ),
      Applicant(
        id: 4,
        projectId: 1,
        name: 'Carlos Lima',
        program: 'Estudiante de Administración, 2do semestre',
        university: 'Universidad de Santiago',
        motivation:
            'Me postulo para ayudar con la logística y el café durante los '
            'talleres, y con la coordinación de voluntarios el día del '
            'evento.',
        skills: const ['LOGÍSTICA', 'COORDINACIÓN'],
        status: ApplicantStatus.rejected,
        submittedAt: now.subtract(const Duration(days: 4)),
      ),
      Applicant(
        id: 5,
        projectId: 1,
        name: 'Andrea Torres',
        program: 'Estudiante de Marketing, 5to semestre',
        university: 'Universidad de Chile',
        motivation:
            'Me gustaría sumarme para apoyar la difusión del proyecto en '
            'redes sociales y ayudar a conseguir nuevos voluntarios.',
        skills: const ['MARKETING', 'REDES SOCIALES'],
        status: ApplicantStatus.pending,
        submittedAt: now.subtract(const Duration(days: 5)),
      ),
      Applicant(
        id: 6,
        projectId: 1,
        name: 'Diego Fernández',
        program: 'Estudiante de Ingeniería Civil, 7mo semestre',
        university: 'Universidad de Concepción',
        motivation:
            'Tengo experiencia coordinando equipos de trabajo en terreno y '
            'me interesa aportar en la logística de los talleres.',
        skills: const ['LOGÍSTICA', 'GESTIÓN DE EQUIPOS'],
        status: ApplicantStatus.pending,
        submittedAt: now.subtract(const Duration(days: 6)),
      ),
      Applicant(
        id: 7,
        projectId: 1,
        name: 'Valentina Soto',
        program: 'Estudiante de Diseño Gráfico, 4to semestre',
        university: 'Universidad de Santiago',
        motivation:
            'Me encantaría diseñar el material gráfico y la señalética para '
            'los talleres comunitarios.',
        skills: const ['DISEÑO GRÁFICO', 'ILUSTRACIÓN'],
        status: ApplicantStatus.accepted,
        submittedAt: now.subtract(const Duration(days: 7)),
      ),
      Applicant(
        id: 8,
        projectId: 1,
        name: 'Martín Rojas',
        program: 'Estudiante de Ingeniería Informática, 8vo semestre',
        university: 'Universidad de Chile',
        motivation:
            'Puedo ayudar a construir una app simple para inscribir a los '
            'asistentes a los talleres y hacer seguimiento de asistencia.',
        skills: const ['PROGRAMACIÓN', 'FLUTTER'],
        status: ApplicantStatus.pending,
        submittedAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  List<Applicant> get applicants => List.unmodifiable(_applicants);

  @override
  Future<List<Applicant>> fetchApplicantsByProject(int projectId) async {
    return _applicants
        .where((applicant) => applicant.projectId == projectId)
        .toList(growable: false);
  }

  @override
  Future<Applicant> updateApplicantStatus(
    int applicantId,
    ApplicantStatus status,
  ) async {
    final index = _applicants.indexWhere(
      (applicant) => applicant.id == applicantId,
    );
    if (index == -1) {
      throw StateError('Postulante no encontrado: $applicantId');
    }

    final updated = _applicants[index].copyWith(status: status);
    _applicants[index] = updated;
    return updated;
  }
}
