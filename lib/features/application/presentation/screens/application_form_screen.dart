import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/nodo_theme.dart';
import '../../../home/domain/entities/idea.dart';
import '../viewmodels/application_view_model.dart';
import 'application_confirmation_screen.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key, required this.idea, this.viewModel});

  final Idea idea;

  /// Permite inyectar un ViewModel en tests.
  final ApplicationViewModel? viewModel;

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  static const List<String> _experienceLevels = [
    'Sin experiencia previa',
    'Menos de 1 año',
    '1 a 2 años',
    'Más de 2 años',
  ];

  final _formKey = GlobalKey<FormState>();
  late final ApplicationViewModel _viewModel;
  late final bool _ownsViewModel;

  final TextEditingController _motivationController = TextEditingController();
  final TextEditingController _customSkillController = TextEditingController();

  final Set<String> _selectedSkills = {};
  String? _experience;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ??
        ServiceLocator.instance.createApplicationViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _motivationController.dispose();
    _customSkillController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  void _addCustomSkill() {
    final skill = _customSkillController.text.trim();
    if (skill.isEmpty) return;

    setState(() {
      _selectedSkills.add(skill);
      _customSkillController.clear();
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una habilidad'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: NodoColors.primaryDark,
        ),
      );
      return;
    }

    final projectIdResult = int.tryParse(widget.idea.id);
    final application = await _viewModel.submit(
      projectId: projectIdResult ?? 0,
      motivation: _motivationController.text,
      skills: _selectedSkills.toList(growable: false),
      experience: _experience ?? '',
    );

    if (!mounted) return;

    if (application != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicationConfirmationScreen(
            idea: widget.idea,
            application: application,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage ?? 'Error al enviar'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: NodoColors.primaryDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = _viewModel.status == ApplicationStatus.submitting;

    return Scaffold(
      backgroundColor: NodoColors.background,
      appBar: AppBar(
        title: const Text(
          'Postulación',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          onPressed: isSubmitting ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              _ProjectHeader(idea: widget.idea),
              const SizedBox(height: 24),
              const _SectionLabel('Motivación'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _motivationController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  hint: 'Cuéntanos por qué quieres unirte y qué aportarías',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Escribe al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Habilidades que aportas'),
              const SizedBox(height: 4),
              const Text(
                'Elige entre las requeridas o agrega una propia',
                style: TextStyle(
                  color: NodoColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.idea.skills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.white : NodoColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() {
                        isSelected
                            ? _selectedSkills.remove(skill)
                            : _selectedSkills.add(skill);
                      });
                    },
                    selectedColor: NodoColors.primary,
                    backgroundColor: NodoColors.surface,
                    side: BorderSide(
                      color: isSelected
                          ? NodoColors.primary
                          : NodoColors.chipBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customSkillController,
                      decoration: _inputDecoration(
                        hint: 'Otra habilidad (ej. Comunidad)',
                      ),
                      onSubmitted: (_) => _addCustomSkill(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _addCustomSkill,
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: NodoColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Experiencia'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _experience,
                decoration: _inputDecoration(hint: 'Selecciona tu nivel'),
                isExpanded: true,
                items: _experienceLevels
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ),
                    )
                    .toList(),
                onChanged: isSubmitting
                    ? null
                    : (value) => setState(() => _experience = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona tu experiencia';
                  }
                  return null;
                },
              ),
            ],
          ),
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
              onPressed: isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: NodoColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Enviar postulación',
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

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
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
}

class _ProjectHeader extends StatelessWidget {
  const _ProjectHeader({required this.idea});

  final Idea idea;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: idea.gradientColors.map(Color.new).toList(growable: false),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            idea.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            idea.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ],
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