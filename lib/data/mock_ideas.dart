import 'package:flutter/material.dart';

import '../models/idea.dart';

const List<String> kIdeaCategories = [
  'TODAS',
  'TECNOLOGÍA',
  'DISEÑO',
  'SOCIAL',
  'NEGOCIOS',
];

const List<Idea> kMockIdeas = [
  Idea(
    id: '1',
    title: 'Huerta urbana colaborativa',
    description:
        'Buscamos estudiantes para diseñar y construir una huerta comunitaria en el campus.',
    category: 'SOCIAL',
    skills: ['DISEÑO/UX', 'GESTIÓN'],
    filledSpots: 3,
    totalSpots: 6,
    gradient: [Color(0xFF7B6CF0), Color(0xFFB8A9FF)],
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
    gradient: [Color(0xFF4A3CC7), Color(0xFF7A6BE8)],
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
    gradient: [Color(0xFF6A5AE0), Color(0xFF9B8CF5)],
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
    gradient: [Color(0xFF553ECF), Color(0xFF8E7DF0)],
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
    gradient: [Color(0xFF6858E8), Color(0xFFA99BFF)],
  ),
];
