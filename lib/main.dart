import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/nodo_theme.dart';

void main() {
  runApp(const NodoApp());
}

class NodoApp extends StatelessWidget {
  const NodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nodo',
      debugShowCheckedModeBanner: false,
      theme: buildNodoTheme(),
      home: const HomeScreen(),
    );
  }
}
