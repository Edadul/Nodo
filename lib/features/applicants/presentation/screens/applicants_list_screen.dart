import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/nodo_theme.dart';
import '../../domain/entities/applicant.dart';
import '../../domain/entities/applicant_status.dart';
import '../viewmodels/applicants_view_model.dart';
import '../widgets/applicant_card.dart';
import '../widgets/applicants_screen_header.dart';
import 'applicant_detail_screen.dart';

class ApplicantsListScreen extends StatefulWidget {
  const ApplicantsListScreen({
    super.key,
    required this.projectId,
    this.viewModel,
  });

  final int projectId;

  /// Permite inyectar un ViewModel en tests.
  final ApplicantsViewModel? viewModel;

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  late final ApplicantsViewModel _viewModel;
  late final bool _ownsViewModel;

  static const _filters = [
    ApplicantsFilter.all,
    ApplicantsFilter.pending,
    ApplicantsFilter.accepted,
    ApplicantsFilter.rejected,
  ];

  static const _filterLabels = {
    ApplicantsFilter.all: 'Todas',
    ApplicantsFilter.pending: 'Pendientes',
    ApplicantsFilter.accepted: 'Aceptadas',
    ApplicantsFilter.rejected: 'Rechazadas',
  };

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ??
        ServiceLocator.instance.createApplicantsViewModel(widget.projectId);
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.load();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: NodoColors.primaryDark,
      ),
    );
  }

  Future<void> _updateStatus(Applicant applicant, ApplicantStatus status) async {
    final updated = await _viewModel.updateStatus(applicant.id, status);
    if (!mounted) return;
    if (updated != null) {
      _showMessage(
        status == ApplicantStatus.accepted
            ? '${applicant.name} fue aceptado/a'
            : '${applicant.name} fue rechazado/a',
      );
    } else {
      _showMessage(_viewModel.errorMessage ?? 'No se pudo actualizar');
    }
  }

  void _openDetail(Applicant applicant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicantDetailScreen(
          applicantId: applicant.id,
          viewModel: _viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NodoColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ApplicantsScreenHeader(title: 'Postulaciones'),
            _buildFilters(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final vm = _viewModel;
    return Container(
      width: double.infinity,
      color: NodoColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${vm.totalCount} postulaciones recibidas',
            style: const TextStyle(
              color: NodoColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in _filters) ...[
                  _FilterChip(
                    label: filter == ApplicantsFilter.all
                        ? _filterLabels[filter]!
                        : '${_filterLabels[filter]} (${vm.countFor(filter)})',
                    selected: vm.filter == filter,
                    onTap: () => vm.selectFilter(filter),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final vm = _viewModel;

    if (vm.status == ApplicantsStatus.loading ||
        vm.status == ApplicantsStatus.initial) {
      return const Center(
        child: CircularProgressIndicator(color: NodoColors.primary),
      );
    }

    if (vm.status == ApplicantsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vm.errorMessage ?? 'Error al cargar postulaciones',
                textAlign: TextAlign.center,
                style: const TextStyle(color: NodoColors.textSecondary),
              ),
              const SizedBox(height: 12),
              FilledButton(onPressed: vm.load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final applicants = vm.applicants;
    if (applicants.isEmpty) {
      return const Center(
        child: Text(
          'No hay postulaciones en este filtro',
          style: TextStyle(color: NodoColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: applicants.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final applicant = applicants[index];
        return ApplicantCard(
          applicant: applicant,
          onTap: () => _openDetail(applicant),
          onAccept: () => _updateStatus(applicant, ApplicantStatus.accepted),
          onReject: () => _updateStatus(applicant, ApplicantStatus.rejected),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? NodoColors.textPrimary : NodoColors.background,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: selected
                ? null
                : Border.all(color: Colors.black.withValues(alpha: 0.1)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : NodoColors.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
