import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../db/db_interface.dart';
import '../db/roble_database.dart';
import '../services/catalog_service.dart';
import '../services/user_profile_service.dart';

// Home
import '../../features/home/data/datasources/api_idea_datasource.dart';
import '../../features/home/data/repositories/idea_repository_impl.dart';
import '../../features/home/data/repositories/profile_repository.dart';
import '../../features/home/domain/usecases/get_ideas.dart';
import '../../features/home/domain/usecases/get_categories.dart';
import '../../features/home/presentation/viewmodels/home_view_model.dart';

// Project creation
import '../../features/project_creation/data/datasources/api_project_creation_datasource.dart';
import '../../features/project_creation/data/repositories/project_creation_repository_impl.dart';
import '../../features/project_creation/domain/usecases/create_project.dart';
import '../../features/project_creation/domain/usecases/get_catalog_suggestions.dart';
import '../../features/project_creation/presentation/viewmodels/create_project_view_model.dart';

// Application
import '../../features/application/data/datasources/api_application_datasource.dart';
import '../../features/application/data/repositories/application_repository_impl.dart';
import '../../features/application/domain/usecases/get_my_application.dart';
import '../../features/application/domain/usecases/submit_application.dart';
import '../../features/application/presentation/viewmodels/application_view_model.dart';

// Applicants
import '../../features/applicants/data/datasources/api_applicant_datasource.dart';
import '../../features/applicants/data/repositories/applicant_repository_impl.dart';
import '../../features/applicants/domain/usecases/decide_application.dart';
import '../../features/applicants/domain/usecases/get_applicants.dart';
import '../../features/applicants/presentation/viewmodels/applicants_view_model.dart';

// Auth
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/viewmodels/auth_view_model.dart';

class CoreModule {
  static List<SingleChildWidget> get providers => [
        Provider<CatalogService>(
          create: (context) => CatalogService(context.read<IDatabase>()),
        ),
        Provider<UserProfileService>(
          create: (context) => UserProfileService(context.read<IDatabase>()),
        ),
      ];
}

class HomeModule {
  static List<SingleChildWidget> get providers => [
        Provider<ProfileRepository>(
          create: (context) => ProfileRepository(context.read<IDatabase>()),
        ),
        Provider<ApiIdeaDataSource>(
          create: (context) => ApiIdeaDataSource(
            context.read<IDatabase>(),
            context.read<CatalogService>(),
          ),
        ),
        Provider<IdeaRepositoryImpl>(
          create: (context) => IdeaRepositoryImpl(context.read<ApiIdeaDataSource>()),
        ),
        Provider<GetIdeas>(
          create: (context) => GetIdeas(context.read<IdeaRepositoryImpl>()),
        ),
        Provider<GetCategories>(
          create: (context) => GetCategories(context.read<IdeaRepositoryImpl>()),
        ),
        Provider<HomeViewModel Function()>(
          create: (context) {
            return () => HomeViewModel(
                  getIdeas: context.read<GetIdeas>(),
                  getCategories: context.read<GetCategories>(),
                );
          },
        ),
      ];
}

class ProjectCreationModule {
  static List<SingleChildWidget> get providers => [
        Provider<ProjectCreationRepositoryImpl>(
          create: (context) => ProjectCreationRepositoryImpl(
            ApiProjectCreationDataSource(
              context.read<IDatabase>(),
              context.read<CatalogService>(),
              context.read<UserProfileService>(),
            ),
          ),
        ),
        Provider<CreateProjectViewModel Function()>(
          create: (context) {
            final repository = context.read<ProjectCreationRepositoryImpl>();
            return () => CreateProjectViewModel(
                  createProject: CreateProject(repository),
                  getSuggestions: GetCatalogSuggestions(repository),
                );
          },
        ),
      ];
}

class ApplicationModule {
  static List<SingleChildWidget> get providers => [
        Provider<ApiApplicationDataSource>(
          create: (context) => ApiApplicationDataSource(
            context.read<IDatabase>(),
            context.read<CatalogService>(),
            context.read<UserProfileService>(),
          ),
        ),
        Provider<ApplicationRepositoryImpl>(
          create: (context) => ApplicationRepositoryImpl(context.read<ApiApplicationDataSource>()),
        ),
        Provider<SubmitApplication>(
          create: (context) => SubmitApplication(context.read<ApplicationRepositoryImpl>()),
        ),
        Provider<GetMyApplication>(
          create: (context) => GetMyApplication(context.read<ApplicationRepositoryImpl>()),
        ),
        Provider<ApplicationViewModel Function()>(
          create: (context) {
            return () => ApplicationViewModel(
                  submitApplication: context.read<SubmitApplication>(),
                );
          },
        ),
      ];
}

class ApplicantsModule {
  static List<SingleChildWidget> get providers => [
        Provider<ApplicantRepositoryImpl>(
          create: (context) => ApplicantRepositoryImpl(
            ApiApplicantDataSource(
              context.read<IDatabase>(),
              context.read<CatalogService>(),
            ),
          ),
        ),
        Provider<GetApplicants>(
          create: (context) => GetApplicants(context.read<ApplicantRepositoryImpl>()),
        ),
        Provider<DecideApplication>(
          create: (context) => DecideApplication(context.read<ApplicantRepositoryImpl>()),
        ),
        Provider<ApplicantsViewModel Function(String, User?)>(
          create: (context) {
            return (String projectId, User? actor) => ApplicantsViewModel(
                  projectId: projectId,
                  actor: actor,
                  getApplicants: context.read<GetApplicants>(),
                  decideApplication: context.read<DecideApplication>(),
                );
          },
        ),
      ];
}

class AppModule extends StatelessWidget {
  final Widget child;
  final IDatabase database;

  const AppModule({
    super.key,
    required this.child,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<IDatabase>.value(value: database),
        ...CoreModule.providers,
        ...HomeModule.providers,
        ...ProjectCreationModule.providers,
        ...ApplicationModule.providers,
        ...ApplicantsModule.providers,
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(Roble.robleDatabase),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) =>
              AuthViewModel(repository: context.read<AuthRepository>()),
        ),
      ],
      child: child,
    );
  }
}
