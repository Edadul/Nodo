import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/db/roble_database.dart';
import 'core/services/project_service.dart';
import 'core/theme/nodo_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

import 'features/home/data/datasources/api_idea_datasource.dart';
import 'features/home/data/repositories/idea_repository_impl.dart';
import 'features/home/domain/usecases/get_ideas.dart';
import 'features/home/domain/usecases/get_categories.dart';
import 'features/home/presentation/viewmodels/home_view_model.dart';

import 'features/application/data/datasources/api_application_datasource.dart';
import 'features/application/data/repositories/application_repository_impl.dart';
import 'features/application/domain/usecases/submit_application.dart';
import 'features/application/presentation/viewmodels/application_view_model.dart';

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
  final database = Roble();
  await database.init();

  final projectService = ProjectService(database);

  // Home dependencies
  final ideaDataSource = ApiIdeaDataSource(database);
  final ideaRepository = IdeaRepositoryImpl(ideaDataSource);
  final getIdeas = GetIdeas(ideaRepository);
  final getCategories = GetCategories(ideaRepository);

  // Application dependencies
  final appDataSource = ApiApplicationDataSource(database);
  final appRepository = ApplicationRepositoryImpl(appDataSource);
  final submitApplication = SubmitApplication(appRepository);

  runApp(
    MultiProvider(
      providers: [
        Provider<ProjectService>(create: (_) => projectService),
        // We provide factories so the screens can create fresh instances if needed,
        // or just provide the instances. Since the screens dispose them, we should provide a builder/factory.
        Provider<HomeViewModel Function()>(
          create: (_) => () => HomeViewModel(
            getIdeas: getIdeas,
            getCategories: getCategories,
          ),
        ),
        Provider<ApplicationViewModel Function()>(
          create: (_) => () => ApplicationViewModel(
            submitApplication: submitApplication,
          ),
        ),
      ],
      child: const NodoApp(),
    ),
  );
}
