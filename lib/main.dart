import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/db/roble_database.dart';
import 'core/di/app_module.dart';
import 'core/theme/nodo_theme.dart';
import 'env/env.dart';
import 'features/auth/presentation/viewmodels/auth_view_model.dart';
import 'features/home/presentation/screens/home_screen.dart';

class NodoApp extends StatelessWidget {
  const NodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nodo',
      debugShowCheckedModeBanner: false,
      theme: buildNodoTheme(),
      home: const _BootstrapGate(),
    );
  }
}

class _BootstrapGate extends StatefulWidget {
  const _BootstrapGate();

  @override
  State<_BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<_BootstrapGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (!auth.isBootstrapped) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return const HomeScreen();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  Roble.configure();

  final database = Roble();
  await database.init();

  runApp(AppModule(database: database, child: const NodoApp()));
}
