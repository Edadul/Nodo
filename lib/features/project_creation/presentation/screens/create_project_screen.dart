import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/nodo_theme.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../domain/validation/project_draft_validator.dart';
import '../viewmodels/create_project_view_model.dart';

/// Formulario de creación de proyecto. Hace `pop` con la [Idea] creada.
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key, this.viewModel});

  /// Permite inyectar un ViewModel en tests.
  final CreateProjectViewModel? viewModel;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  late final CreateProjectViewModel _viewModel;
  late final bool _ownsViewModel;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ??
        context.read<CreateProjectViewModel Function()>()();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadSuggestions();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final idea = await _viewModel.submit(
      title: _titleController.text,
      description: _descriptionController.text,
      creator: context.read<AuthViewModel?>()?.signedInUser,
    );
    if (!mounted) return;

    if (idea != null) {
      Navigator.pop(context, idea);
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: NodoColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    final errors = vm.fieldErrors;

    return Scaffold(
      backgroundColor: NodoColors.background,
      appBar: AppBar(
        title: const Text(
          'Nuevo proyecto',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          onPressed: vm.isSubmitting ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            const _SectionLabel('Título'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !vm.isSubmitting,
              maxLength: ProjectRules.titleMax,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => vm.clearFieldError(ProjectField.title),
              decoration: _inputDecoration(
                hint: 'Ej. Huerta urbana colaborativa',
                error: errors[ProjectField.title],
              ),
            ),
            const SizedBox(height: 12),
            const _SectionLabel('Descripción'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              enabled: !vm.isSubmitting,
              maxLines: 5,
              maxLength: ProjectRules.descriptionMax,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => vm.clearFieldError(ProjectField.description),
              decoration: _inputDecoration(
                hint: '¿Qué quieres construir y qué buscas en tu equipo?',
                error: errors[ProjectField.description],
              ),
            ),
            const SizedBox(height: 12),
            const _SectionLabel('Cupos para colaboradores'),
            const SizedBox(height: 8),
            _SpotsStepper(
              value: vm.totalSpots,
              enabled: !vm.isSubmitting,
              onChanged: vm.setTotalSpots,
              error: errors[ProjectField.totalSpots],
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              'Categorías (máx. ${ProjectRules.categoriesMax})',
            ),
            const SizedBox(height: 12),
            _TagPicker(
              suggestions: vm.categorySuggestions,
              selected: vm.selectedCategories,
              enabled: !vm.isSubmitting,
              onToggle: vm.toggleCategory,
              onAdd: vm.addCategory,
              hint: 'Otra categoría',
              error: errors[ProjectField.categories],
            ),
            const SizedBox(height: 24),
            _SectionLabel(
              'Habilidades requeridas (máx. ${ProjectRules.skillsMax})',
            ),
            const SizedBox(height: 12),
            _TagPicker(
              suggestions: vm.skillSuggestions,
              selected: vm.selectedSkills,
              enabled: !vm.isSubmitting,
              onToggle: vm.toggleSkill,
              onAdd: vm.addSkill,
              hint: 'Otra habilidad',
              error: errors[ProjectField.skills],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(
          color: NodoColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: vm.isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: NodoColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: vm.isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Publicar proyecto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({required String hint, String? error}) {
  return InputDecoration(
    hintText: hint,
    errorText: error,
    filled: true,
    fillColor: NodoColors.surface,
    hintStyle: const TextStyle(color: NodoColors.navInactive),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: NodoColors.chipBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: NodoColors.chipBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: NodoColors.primary, width: 1.6),
    ),
  );
}

class _SpotsStepper extends StatelessWidget {
  const _SpotsStepper({
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.error,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: NodoColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: NodoColors.chipBorder),
          ),
          child: Row(
            children: [
              IconButton(
                key: const Key('spots-decrement'),
                onPressed: enabled && value > ProjectRules.spotsMin
                    ? () => onChanged(value - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: Text(
                  '$value ${value == 1 ? 'cupo' : 'cupos'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: NodoColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                key: const Key('spots-increment'),
                onPressed: enabled && value < ProjectRules.spotsMax
                    ? () => onChanged(value + 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        if (error != null) _ErrorText(error!),
      ],
    );
  }
}

/// Chips de sugerencias + campo para agregar etiquetas propias.
class _TagPicker extends StatefulWidget {
  const _TagPicker({
    required this.suggestions,
    required this.selected,
    required this.enabled,
    required this.onToggle,
    required this.onAdd,
    required this.hint,
    this.error,
  });

  final List<String> suggestions;
  final Set<String> selected;
  final bool enabled;
  final ValueChanged<String> onToggle;

  /// Devuelve el mensaje de error, o null si se agregó.
  final String? Function(String) onAdd;
  final String hint;
  final String? error;

  @override
  State<_TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<_TagPicker> {
  final TextEditingController _controller = TextEditingController();
  String? _inputError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final error = widget.onAdd(_controller.text);
    setState(() {
      _inputError = error;
      if (error == null) _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = {...widget.suggestions, ...widget.selected}.toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.selected.contains(option)
                        ? Colors.white
                        : NodoColors.textPrimary,
                  ),
                ),
                selected: widget.selected.contains(option),
                showCheckmark: false,
                onSelected:
                    widget.enabled ? (_) => widget.onToggle(option) : null,
                selectedColor: NodoColors.primary,
                backgroundColor: NodoColors.surface,
                side: BorderSide(
                  color: widget.selected.contains(option)
                      ? NodoColors.primary
                      : NodoColors.chipBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                maxLength: ProjectRules.tagMax,
                textCapitalization: TextCapitalization.characters,
                decoration: _inputDecoration(
                  hint: widget.hint,
                  error: _inputError,
                ).copyWith(counterText: ''),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: widget.enabled ? _add : null,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: NodoColors.primary,
              ),
            ),
          ],
        ),
        if (widget.error != null) _ErrorText(widget.error!),
      ],
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: NodoColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
