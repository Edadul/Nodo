import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../home/domain/entities/idea.dart';
import '../../domain/entities/project_status.dart';
import '../../domain/entities/project_update.dart';
import '../../domain/usecases/publish_project_update.dart';
import '../widgets/project_status_badge.dart';

class PublishUpdateScreen extends StatefulWidget {
  const PublishUpdateScreen({
    super.key,
    required this.idea,
    this.allowStatusChange = true,
  });

  final Idea idea;

  /// Solo el creador debería cambiar el ciclo de vida del proyecto.
  final bool allowStatusChange;

  @override
  State<PublishUpdateScreen> createState() => _PublishUpdateScreenState();
}

class _PublishUpdateScreenState extends State<PublishUpdateScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  ProjectStatus? _selectedStatus;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthViewModel>();
    final user = auth.signedInUser;
    if (user == null) {
      setState(() => _error = 'Inicia sesión para publicar');
      return;
    }
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Escribe un título y una descripción');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final publish = context.read<PublishProjectUpdate>();
      final update = await publish(
        projectId: widget.idea.id,
        author: user,
        title: _titleCtrl.text,
        body: _bodyCtrl.text,
        newStatus: widget.allowStatusChange ? _selectedStatus : null,
        projectRecordId: widget.idea.recordId,
      );
      if (!mounted) return;
      Navigator.pop<ProjectUpdate>(context, update);
    } catch (e) {
      setState(() => _error = 'No se pudo publicar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NodoColors.background,
      appBar: AppBar(
        title: const Text(
          'Publicar actualización',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            widget.idea.title,
            style: const TextStyle(
              color: NodoColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Cuenta qué está pasando. Así quien visita el proyecto entiende el avance sin porcentajes confusos.',
            style: TextStyle(
              color: NodoColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            decoration: _decoration('Título'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            minLines: 4,
            maxLines: 8,
            decoration: _decoration('¿Qué avanzaron o qué necesitan?'),
            textCapitalization: TextCapitalization.sentences,
          ),
          if (widget.allowStatusChange) ...[
            const SizedBox(height: 20),
            const Text(
              '¿Cambió el estado? (opcional)',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statusChip(null, 'Sin cambio'),
                ...ProjectStatus.values.map(
                  (status) => _statusChip(status, status.label),
                ),
              ],
            ),
            if (_selectedStatus != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Nuevo estado: '),
                  ProjectStatusBadge(status: _selectedStatus!),
                ],
              ),
            ],
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: NodoColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Publicar en el timeline',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(ProjectStatus? status, String label) {
    final selected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _selectedStatus = status),
      selectedColor: NodoColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : NodoColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      backgroundColor: NodoColors.surface,
      side: BorderSide(
        color: selected ? NodoColors.primary : NodoColors.chipBorder,
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: NodoColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: NodoColors.primary, width: 1.5),
      ),
    );
  }
}
