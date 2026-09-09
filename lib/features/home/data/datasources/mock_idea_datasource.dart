import '../../domain/entities/idea.dart';
import 'idea_datasource.dart';

/// Implementación temporal en memoria.
/// Se reemplaza por Hive/Supabase sin tocar presentation ni domain.
class MockIdeaDataSource implements IdeaDataSource {
  MockIdeaDataSource({List<Idea>? seed})
      : _ideas = List<Idea>.from(seed ?? _defaultIdeas);

  final List<Idea> _ideas;

  static const List<String> _categories = [
    'TODAS',
    'TECNOLOGÍA',
    'DISEÑO',
    'SOCIAL',
    'NEGOCIOS',
  ];

  static const List<Idea> _defaultIdeas = [
    Idea(
      id: '1',
      title: 'Huerta urbana colaborativa',
      description:
          'Buscamos estudiantes para diseñar y construir una huerta comunitaria en el campus.',
      category: 'SOCIAL',
      skills: ['DISEÑO/UX', 'GESTIÓN'],
      filledSpots: 3,
      totalSpots: 6,
      gradientColors: [0xFF7B6CF0, 0xFFB8A9FF],
    ),
    Idea(
      id: '2',
      title: 'Asistente de estudio con IA',
      description:
          'Plataforma web que resume apuntes y genera quizzes con procesamiento de lenguaje.',
      category: 'TECNOLOGÍA',
      skills: ['BACKEND', 'DATOS'],
      filledSpots: 2,
      totalSpots: 5,
      gradientColors: [0xFF4A3CC7, 0xFF7A6BE8],
    ),
    Idea(
      id: '3',
      title: 'Marca local de productos upcycled',
      description:
          'Crear identidad y prototipos de packaging para una línea de moda con materiales reutilizados.',
      category: 'DISEÑO',
      skills: ['BRANDING', 'PRODUCTO'],
      filledSpots: 1,
      totalSpots: 4,
      gradientColors: [0xFF6A5AE0, 0xFF9B8CF5],
    ),
    Idea(
      id: '4',
      title: 'Marketplace de freelancers universitarios',
      description:
          'Conectar talento del campus con microencargos reales de empresas locales.',
      category: 'NEGOCIOS',
      skills: ['PRODUCTO', 'GROWTH'],
      filledSpots: 4,
      totalSpots: 7,
      gradientColors: [0xFF553ECF, 0xFF8E7DF0],
    ),
    Idea(
      id: '5',
      title: 'App de voluntariado por barrios',
      description:
          'Mapear necesidades locales y coordinar jornadas de ayuda entre vecinos y estudiantes.',
      category: 'SOCIAL',
      skills: ['MÓVIL', 'COMUNIDAD'],
      filledSpots: 2,
      totalSpots: 6,
      gradientColors: [0xFF6858E8, 0xFFA99BFF],
    ),
  ];

  @override
  Future<List<String>> fetchCategories() async => List.unmodifiable(_categories);

  @override
  Future<List<Idea>> fetchIdeas({String? category}) async {
    if (category == null || category == 'TODAS') {
      return List.unmodifiable(_ideas);
    }
    return List.unmodifiable(
      _ideas.where((idea) => idea.category == category),
    );
  }

  @override
  Future<Idea> insertIdea(Idea idea) async {
    _ideas.insert(0, idea);
    return idea;
  }
}
