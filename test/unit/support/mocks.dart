import 'package:mocktail/mocktail.dart';
import 'package:nodo/core/db/db_interface.dart';
import 'package:nodo/features/applicants/data/datasources/applicant_datasource.dart';
import 'package:nodo/features/application/data/datasources/application_datasource.dart';
import 'package:nodo/features/home/data/datasources/idea_datasource.dart';
import 'package:nodo/features/project_creation/data/datasources/project_creation_datasource.dart';
import 'package:nodo/features/projects/data/datasources/api_project_updates_datasource.dart';
import 'package:roble/roble.dart';

/// Dobles de las dependencias externas: el cliente de Roble (Remote API), el
/// adaptador [IDatabase] y los datasources que hablan con la API.
class MockRobleApiDataBase extends Mock implements RobleApiDataBase {}

class MockDatabase extends Mock implements IDatabase {}

class MockIdeaDataSource extends Mock implements IdeaDataSource {}

class MockProjectCreationDataSource extends Mock
    implements ProjectCreationDataSource {}

class MockApplicationDataSource extends Mock implements ApplicationDataSource {}

class MockApplicantDataSource extends Mock implements ApplicantDataSource {}

class MockProjectUpdatesDataSource extends Mock
    implements ApiProjectUpdatesDataSource {}
