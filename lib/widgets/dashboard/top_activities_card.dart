import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TopActivitiesCard extends StatelessWidget {
  final List<MapEntry<String, double>> topByRoi;
  final List<MapEntry<String, int>> mostFrequent;

  const TopActivitiesCard({
    super.key,
    required this.topByRoi,
    required this.mostFrequent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top ROI ───────────────────────────────────
          _buildHeader(context, 'Highest ROI', Icons.trending_up_rounded),
          const SizedBox(height: 12),
          if (topByRoi.isEmpty)
            _buildEmpty(context)
          else
            ...topByRoi.asMap().entries.map((entry) => _buildRoiRow(
                  context,
                  rank: entry.key + 1,
                  name: entry.value.key,
                  roi: entry.value.value,
                )),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // ── Most Frequent ─────────────────────────────
          _buildHeader(context, 'Most Frequent', Icons.repeat_rounded),
          const SizedBox(height: 12),
          if (mostFrequent.isEmpty)
            _buildEmpty(context)
          else
            ...mostFrequent.asMap().entries.map((entry) => _buildFreqRow(
                  context,
                  rank: entry.key + 1,
                  name: entry.value.key,
                  count: entry.value.value,
                  maxCount: mostFrequent.first.value,
                )),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildRoiRow(
    BuildContext context, {
    required int rank,
    required String name,
    required double roi,
  }) {
    final colors = [
      AppTheme.primary,
      AppTheme.info,
      AppTheme.success,
      AppTheme.violet,
      AppTheme.warning,
    ];
    final color = colors[(rank - 1) % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              roi.toStringAsFixed(2),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreqRow(
    BuildContext context, {
    required int rank,
    required String name,
    required int count,
    required int maxCount,
  }) {
    final fraction = maxCount > 0 ? count / maxCount : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$count×',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'No data yet. Start logging activities!',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
