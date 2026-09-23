import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:roble/roble.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../presentation/viewmodels/auth_view_model.dart';
import '../repositories/auth_repository_impl.dart';

class AuthModule {
  static List<SingleChildWidget> get providers => [
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(context.read<RobleApiDataBase>()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(repository: context.read<AuthRepository>()),
        ),
      ];
}
