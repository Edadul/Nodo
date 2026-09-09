CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    required_skills TEXT NOT NULL
);

INSERT INTO projects (title, description, required_skills) VALUES
('Plataforma Estudiantil', 'Conectando perfiles técnicos, creativos y de negocios.', 'Flutter, Diseño UI/UX'),
('Red Social Académica', 'Facilitando la colaboración entre estudiantes y profesores.', 'Node.js, React, MongoDB'),
('Sistema de Gestión de Tareas', 'Organiza y prioriza tus tareas académicas de manera eficiente.', 'Python, Django, PostgreSQL'),
('Aplicación de Aprendizaje de Idiomas', 'Aprende nuevos idiomas con lecciones interactivas y juegos.', 'Java, Android Studio, SQLite'),
('Plataforma de Tutoría en Línea', 'Conecta a estudiantes con tutores expertos en diversas materias.', 'Ruby on Rails, HTML/CSS, JavaScript'),
('Sistema de Evaluación de Proyectos', 'Permite a los estudiantes recibir retroalimentación sobre sus proyectos.', 'PHP, Laravel, MySQL'),
('Aplicación de Gestión de Horarios', 'Crea y administra tu horario académico de manera sencilla.', 'Swift, iOS Development, Core Data'),
('Plataforma de Intercambio de Recursos Académicos', 'Comparte y accede a recursos educativos entre estudiantes.', 'JavaScript, Vue.js, Firebase'),
('Sistema de Seguimiento de Progreso Académico', 'Monitorea tu rendimiento académico y establece metas.', 'C#, .NET, SQL Server'),
('Aplicación de Preparación para Exámenes', 'Ofrece cuestionarios y simulaciones para prepararte para exámenes importantes.', 'Kotlin, Android Development, Room Database');