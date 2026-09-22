import 'package:flutter/material.dart';

import 'core/db/roble_database.dart';
import 'core/di/app_module.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final database = Roble();
  await database.init();

  runApp(
    AppModule(
      database: database,
      child: const NodoApp(),
    ),
  );
}
