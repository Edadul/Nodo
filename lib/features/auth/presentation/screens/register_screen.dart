import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../viewmodels/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _passCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context, AuthViewModel vm) async {
    vm.setName(_nameCtrl.text);
    vm.setEmail(_emailCtrl.text);
    vm.setPassword(_passCtrl.text);
    final user = await vm.register();
    if (user != null && context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: NodoColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: NodoColors.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: SizedBox()),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Crear cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: NodoColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Regístrate para crear proyectos y postularte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: NodoColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _field(
                    controller: _nameCtrl,
                    label: 'Nombre',
                    onChanged: vm.setName,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    keyboard: TextInputType.emailAddress,
                    onChanged: vm.setEmail,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _passCtrl,
                    label: 'Contraseña',
                    obscure: true,
                    onChanged: vm.setPassword,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          vm.isLoading ? null : () => _submit(context, vm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NodoColors.primary,
                        foregroundColor: NodoColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Registrarme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(
                        color: NodoColors.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboard,
    bool obscure = false,
    required void Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: NodoColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: NodoColors.textSecondary,
          fontSize: 13,
        ),
        filled: true,
        fillColor: NodoColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NodoColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
