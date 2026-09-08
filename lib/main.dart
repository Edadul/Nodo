import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/theme/nodo_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

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

void main() {
  ServiceLocator.instance.init();
  runApp(const NodoApp());
}
