import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/app_theme.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<ActivityProvider>().loadActivities(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentSegment = provider.currentTimeSegment;
          final recommendations = provider.allRecommendations;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // ── Current Time Banner ───────────────────────
              _buildCurrentTimeBanner(context, currentSegment),
              const SizedBox(height: 8),

              // ── Current Segment Recommendation (hero) ─────
              _buildHeroRecommendation(
                context,
                segment: currentSegment,
                recommendation: recommendations[currentSegment],
              ),
              const SizedBox(height: 24),

              // Section Title
              Text(
                'All Time Segments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 12),

              // ── All Segment Cards ─────────────────────────
              ...Activity.timeSegments
                  .where((s) => s != currentSegment)
                  .map((segment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSegmentCard(
                          context,
                          segment: segment,
                          recommendation: recommendations[segment],
                          isCurrent: false,
                        ),
                      )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentTimeBanner(BuildContext context, String segment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          Icon(
            _segmentIcon(segment),
            size: 18,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 10),
          Text(
            'It\'s currently $segment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Now',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroRecommendation(
    BuildContext context, {
    required String segment,
    required Map<String, dynamic>? recommendation,
  }) {
    if (recommendation == null) {
      return _buildEmptyHero(context, segment);
    }

    final activityName = recommendation['activityName'] as String;
    final category = recommendation['category'] as String;
    final avgRoi = recommendation['avgRoi'] as double;
    final frequency = recommendation['frequency'] as int;
    final total = recommendation['totalInSegment'] as int;
    final color = AppTheme.categoryColors[category] ?? AppTheme.primary;
    final icon = AppTheme.categoryIcons[category] ?? Icons.bolt_rounded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recommended for $segment',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Best ROI',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 14),
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
              _buildStat(context, 'Avg ROI', avgRoi.toStringAsFixed(2),
                  AppTheme.primary),
              Container(
                width: 1,
                height: 32,
                color: AppTheme.border,
              ),
              _buildStat(
                  context, 'Logged', '$frequency×', AppTheme.info),
              Container(
                width: 1,
                height: 32,
                color: AppTheme.border,
              ),
              _buildStat(context, 'Total in slot', '$total',
                  AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 16),

          // Why this recommendation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 16, color: AppTheme.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Based on $frequency logged sessions, "$activityName" consistently delivers the highest ROI (${avgRoi.toStringAsFixed(2)}) during $segment compared to ${total - frequency} other entries in this time slot.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHero(BuildContext context, String segment) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Icon(
            _segmentIcon(segment),
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No data for $segment yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Log some activities during this time period to get personalized recommendations.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentCard(
    BuildContext context, {
    required String segment,
    required Map<String, dynamic>? recommendation,
    required bool isCurrent,
  }) {
    final segmentColors = {
      'Morning': AppTheme.warning,
      'Afternoon': AppTheme.info,
      'Evening': AppTheme.violet,
      'Night': AppTheme.primary,
    };
    final color = segmentColors[segment] ?? AppTheme.primary;

    if (recommendation == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Icon(_segmentIcon(segment), size: 22, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(segment,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                  const SizedBox(height: 2),
                  Text('No data yet',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final activityName = recommendation['activityName'] as String;
    final category = recommendation['category'] as String;
    final avgRoi = recommendation['avgRoi'] as double;
    final frequency = recommendation['frequency'] as int;
    final catColor = AppTheme.categoryColors[category] ?? color;
    final catIcon = AppTheme.categoryIcons[category] ?? Icons.bolt_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(catIcon, size: 20, color: catColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_segmentIcon(segment), size: 14, color: color),
                    const SizedBox(width: 6),
                    Text(
                      segment,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activityName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$category · $frequency× logged',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  avgRoi.toStringAsFixed(2),
                  style: TextStyle(
                    color: catColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'ROI',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  IconData _segmentIcon(String segment) {
    switch (segment) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Afternoon':
        return Icons.wb_cloudy_rounded;
      case 'Evening':
        return Icons.nights_stay_rounded;
      case 'Night':
        return Icons.dark_mode_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }
}
