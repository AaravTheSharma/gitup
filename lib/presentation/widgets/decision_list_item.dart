import 'package:flutter/material.dart';
import '../../data/models/decision_model.dart';
import '../../utils/helpers.dart';
import '../../core/app_constants.dart';
import 'custom_card.dart';

class DecisionListItem extends StatelessWidget {
  final Decision decision;
  final VoidCallback? onTap;
  final bool showProgress;

  const DecisionListItem({
    super.key,
    required this.decision,
    this.onTap,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = decision.getProgress();
    final statusColor = Helpers.getStatusColor(decision.status);
    final statusBgColor = Helpers.getStatusBackgroundColor(decision.status);

    return CustomCard(
      onTap: onTap,
      borderColor: decision.isArchived 
          ? const Color(AppConstants.textSecondaryColor)
          : const Color(AppConstants.primaryColor),
      borderWidth: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      decision.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatDate(decision.creationDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Helpers.getStatusText(decision.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (showProgress && !decision.isArchived) ...[
            const SizedBox(height: AppConstants.paddingMedium),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Helpers.getProgressColor(progress),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            if (decision.options.length >= 2) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      decision.options.first.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      decision.options.last.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
          if (decision.category != 'Custom') ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                decision.category,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}