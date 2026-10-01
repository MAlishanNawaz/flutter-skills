import 'package:flutter/material.dart';

import '../../../../core/design/tokens.dart';

/// Dumb widget: data in, nothing out. Every value is a token.
class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({super.key, required this.percent, required this.label});

  final int percent;
  final String label;

  @override
  Widget build(BuildContext context) => MergeSemantics(
        child: Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: AppColors.infoSurface,
            borderRadius: BorderRadius.circular(Radii.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppText.heading),
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.pill),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: Spacing.sm,
                  color: AppColors.primary,
                  backgroundColor: AppColors.track,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text('$percent%', style: AppText.bodySmall),
            ],
          ),
        ),
      );
}
