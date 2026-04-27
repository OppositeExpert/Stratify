import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RoiSummaryCard extends StatelessWidget {
  final int totalActivities;
  final double averageRoi;
  final double totalHours;
  final double totalSpent;

  const RoiSummaryCard({
    super.key,
    required this.totalActivities,
    required this.averageRoi,
    required this.totalHours,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecorationElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average ROI',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      averageRoi.toStringAsFixed(2),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetric(
                context,
                icon: Icons.format_list_numbered_rounded,
                label: 'Activities',
                value: totalActivities.toString(),
                color: AppTheme.primary,
              ),
              _buildMetric(
                context,
                icon: Icons.schedule_rounded,
                label: 'Hours',
                value: totalHours.toStringAsFixed(1),
                color: AppTheme.info,
              ),
              _buildMetric(
                context,
                icon: Icons.currency_rupee_rounded,
                label: 'Spent',
                value: '₹${totalSpent.toInt()}',
                color: AppTheme.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
