  import 'package:flutter/material.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.filledSpots,
    required this.totalSpots,
    this.category = 'SOCIAL',
    this.status = 'NUEVO',
    this.onTap,
  }) : assert(totalSpots > 0),
       assert(filledSpots >= 0),
       assert(filledSpots <= totalSpots);

  final String category;
  final String status;
  final String title;
  final String description;
  final List<String> tags;
  final int filledSpots;
  final int totalSpots;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = const Color(0xFF262338);
    final secondaryTextColor = const Color(0xFF858198);

    return Semantics(
      button: onTap != null,
      label: title,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE4E2E7)),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CardHeader(category: category, status: status),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 23, 22, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 17,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Wrap(
                        spacing: 9,
                        runSpacing: 8,
                        children: tags
                            .map((tag) => _Tag(label: tag))
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 29),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _SpotsProgress(
                              filledSpots: filledSpots,
                              totalSpots: totalSpots,
                              textColor: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          _ArrowButton(onTap: onTap),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.category, required this.status});

  final String category;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(16, 17, 17, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7957D1), Color(0xFF5D3EA6)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HeaderPill(label: category, backgroundColor: Color(0x557F69D9)),
          _HeaderPill(label: status, backgroundColor: Color(0x337F69D9)),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.backgroundColor});

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5D596D),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SpotsProgress extends StatelessWidget {
  const _SpotsProgress({
    required this.filledSpots,
    required this.totalSpots,
    required this.textColor,
  });

  final int filledSpots;
  final int totalSpots;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$filledSpots de $totalSpots cupos',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        const SizedBox(height: 7),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEF3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: filledSpots / totalSpots,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF756F84),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEDE7FC),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 43,
          height: 43,
          child: Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF7957D1),
            size: 29,
          ),
        ),
      ),
    );
  }
}
