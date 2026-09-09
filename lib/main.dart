import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/db/sqlite_database.dart';
import 'core/services/project_service.dart';
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

  databaseFactory = databaseFactoryFfi;

  final database = SQLiteDatabase();
  final projectService = ProjectService(database);

  runApp(
    MultiProvider(
      providers: [
        Provider<ProjectService>(create: (_) => projectService),
      ],
      child: const NodoApp(),
    ),
  );
}
