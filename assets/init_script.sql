CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    required_skills TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'TECNOLOGÍA',
    filled_spots INTEGER NOT NULL DEFAULT 0,
    total_spots INTEGER NOT NULL DEFAULT 5
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