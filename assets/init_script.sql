CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    required_skills TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'TECNOLOGÍA',
    filled_spots INTEGER NOT NULL DEFAULT 0,
    total_spots INTEGER NOT NULL DEFAULT 5
);

CREATE TABLE IF NOT EXISTS applications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    motivation TEXT NOT NULL,
    skills TEXT NOT NULL,
    experience TEXT NOT NULL,
    submitted_at TEXT NOT NULL,
    applicant_name TEXT NOT NULL DEFAULT '',
    applicant_program TEXT NOT NULL DEFAULT '',
    applicant_university TEXT NOT NULL DEFAULT '',
    avatar_url TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    attachment_name TEXT,
    attachment_size_label TEXT,
    FOREIGN KEY (project_id) REFERENCES projects (id)
);

INSERT INTO projects
    (title, description, required_skills, category, filled_spots, total_spots)
VALUES
('Plataforma Estudiantil', 'Conectando perfiles técnicos, creativos y de negocios.', 'Flutter, Diseño UI/UX', 'TECNOLOGÍA', 2, 6),
('Red Social Académica', 'Facilitando la colaboración entre estudiantes y profesores.', 'Node.js, React, MongoDB', 'SOCIAL', 3, 7),
('Sistema de Gestión de Tareas', 'Organiza y prioriza tus tareas académicas de manera eficiente.', 'Python, Django, PostgreSQL', 'TECNOLOGÍA', 1, 5),
('Aplicación de Aprendizaje de Idiomas', 'Aprende nuevos idiomas con lecciones interactivas y juegos.', 'Java, Android Studio, SQLite', 'DISEÑO', 2, 5),
('Plataforma de Tutoría en Línea', 'Conecta a estudiantes con tutores expertos en diversas materias.', 'Ruby on Rails, HTML/CSS, JavaScript', 'SOCIAL', 4, 8),
('Sistema de Evaluación de Proyectos', 'Permite a los estudiantes recibir retroalimentación sobre sus proyectos.', 'PHP, Laravel, MySQL', 'NEGOCIOS', 2, 6),
('Aplicación de Gestión de Horarios', 'Crea y administra tu horario académico de manera sencilla.', 'Swift, iOS Development, Core Data', 'TECNOLOGÍA', 1, 4),
('Plataforma de Intercambio de Recursos Académicos', 'Comparte y accede a recursos educativos entre estudiantes.', 'JavaScript, Vue.js, Firebase', 'SOCIAL', 3, 6),
('Sistema de Seguimiento de Progreso Académico', 'Monitorea tu rendimiento académico y establece metas.', 'C#, .NET, SQL Server', 'NEGOCIOS', 2, 5),
('Aplicación de Preparación para Exámenes', 'Ofrece cuestionarios y simulaciones para prepararte para exámenes importantes.', 'Kotlin, Android Development, Room Database', 'DISEÑO', 2, 5);

INSERT INTO applications
    (project_id, motivation, skills, experience, submitted_at, applicant_name, applicant_program, applicant_university, status, attachment_name, attachment_size_label)
VALUES
(1, 'Hola María, me interesa mucho sumarme porque estudio biología y tengo experiencia en compostaje urbano. Me gustaría ayudar con la gestión técnica y estructurar los talleres didácticos para la comunidad.', 'BIOLOGÍA, COMPOSTAJE, GESTIÓN DE EQUIPOS', 'Más de 2 años', datetime('now', '-2 hours'), 'María García', 'Estudiante de Biología, 4to semestre', 'Universidad de Chile', 'pending', 'CV_Maria_Garcia.pdf', 'PDF • 2.4 MB'),
(1, 'Hola! Tengo experiencia en diseño UX/UI y me gustaría aportar en la construcción de los prototipos y la identidad visual del proyecto.', 'UX/UI, FIGMA, PROTOTIPADO', '1 a 2 años', datetime('now', '-1 day'), 'Juan Pérez', 'Estudiante de Diseño, 6to semestre', 'Universidad de Chile', 'accepted', 'CV_Juan_Perez.pdf', 'PDF • 1.1 MB'),
(1, 'Hola, soy de agronomía y me encanta la propuesta. Quiero aportar conocimientos sobre cultivos urbanos y manejo de huertas comunitarias.', 'AGRONOMÍA, HUERTOS URBANOS', '1 a 2 años', datetime('now', '-2 days'), 'Sofía Ruiz', 'Estudiante de Agronomía, 3er semestre', 'Universidad de Concepción', 'pending', NULL, NULL),
(1, 'Me postulo para ayudar con la logística y el café durante los talleres, y con la coordinación de voluntarios el día del evento.', 'LOGÍSTICA, COORDINACIÓN', 'Menos de 1 año', datetime('now', '-4 days'), 'Carlos Lima', 'Estudiante de Administración, 2do semestre', 'Universidad de Santiago', 'rejected', NULL, NULL),
(1, 'Me gustaría sumarme para apoyar la difusión del proyecto en redes sociales y ayudar a conseguir nuevos voluntarios.', 'MARKETING, REDES SOCIALES', 'Menos de 1 año', datetime('now', '-5 days'), 'Andrea Torres', 'Estudiante de Marketing, 5to semestre', 'Universidad de Chile', 'pending', NULL, NULL),
(1, 'Tengo experiencia coordinando equipos de trabajo en terreno y me interesa aportar en la logística de los talleres.', 'LOGÍSTICA, GESTIÓN DE EQUIPOS', '1 a 2 años', datetime('now', '-6 days'), 'Diego Fernández', 'Estudiante de Ingeniería Civil, 7mo semestre', 'Universidad de Concepción', 'pending', NULL, NULL),
(1, 'Me encantaría diseñar el material gráfico y la señalética para los talleres comunitarios.', 'DISEÑO GRÁFICO, ILUSTRACIÓN', '1 a 2 años', datetime('now', '-7 days'), 'Valentina Soto', 'Estudiante de Diseño Gráfico, 4to semestre', 'Universidad de Santiago', 'accepted', NULL, NULL),
(1, 'Puedo ayudar a construir una app simple para inscribir a los asistentes a los talleres y hacer seguimiento de asistencia.', 'PROGRAMACIÓN, FLUTTER', 'Más de 2 años', datetime('now', '-7 days'), 'Martín Rojas', 'Estudiante de Ingeniería Informática, 8vo semestre', 'Universidad de Chile', 'pending', NULL, NULL);