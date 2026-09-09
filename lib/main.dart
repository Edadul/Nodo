import 'package:flutter/material.dart';
import 'package:nodo/widgets/opportunity_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nodo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF8F7FA),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: const OpportunityCard(
                title: 'Huerta urbana colaborativa',
                description:
                    'Buscamos estudiantes para diseñar y construir una huerta comunitaria en el campus central para promover sustentabilidad.',
                tags: ['DISEÑO UX/UI', 'GESTIÓN'],
                filledSpots: 3,
                totalSpots: 6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
