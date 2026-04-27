import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TimeHeatmap extends StatelessWidget {
  final Map<String, double> timeOfDayPerformance;

  const TimeHeatmap({super.key, required this.timeOfDayPerformance});

  @override
  Widget build(BuildContext context) {
    final segments = ['Morning', 'Afternoon', 'Evening', 'Night'];
    final icons = [
      Icons.wb_sunny_rounded,
      Icons.wb_cloudy_rounded,
      Icons.nights_stay_rounded,
      Icons.dark_mode_rounded,
    ];
    final colors = [
      AppTheme.warning,
      AppTheme.info,
      AppTheme.violet,
      AppTheme.primary,
    ];

    // Find max for relative sizing
    final values = segments.map((s) => timeOfDayPerformance[s] ?? 0).toList();
    final maxVal = values.fold<double>(0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded,
                  size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('Time of Day Performance',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(segments.length, (i) {
              final roi = values[i];
              final fraction = maxVal > 0 ? (roi / maxVal).clamp(0.0, 1.0) : 0.0;
              final color = colors[i];

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i < segments.length - 1 ? 8 : 0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05 + fraction * 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: color.withValues(alpha: 0.15 + fraction * 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icons[i], size: 22, color: color),
                        const SizedBox(height: 8),
                        Text(
                          roi.toStringAsFixed(2),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          segments[i],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
