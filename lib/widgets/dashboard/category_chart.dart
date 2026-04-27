import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, Map<String, double>> insights;

  const CategoryChart({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'No data yet',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    final categories = insights.keys.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),

          // ── Bar Chart: Avg Satisfaction by Category ────
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 6,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.textPrimary,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final category = categories[group.x];
                      final labels = ['Satisfaction', 'Energy', 'Stress'];
                      return BarTooltipItem(
                        '$category\n${labels[rodIndex]}: ${rod.toY.toStringAsFixed(1)}',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= categories.length) {
                          return const SizedBox.shrink();
                        }
                        final cat = categories[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Icon(
                            AppTheme.categoryIcons[cat] ?? Icons.bolt_rounded,
                            size: 18,
                            color: AppTheme.categoryColors[cat] ?? AppTheme.primary,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppTheme.textTertiary,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.borderSubtle,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: categories.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final cat = entry.value;
                  final data = insights[cat]!;
                  final color =
                      AppTheme.categoryColors[cat] ?? AppTheme.primary;

                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: data['satisfaction']!,
                        color: color,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: (data['energy']! + 2).clamp(0, 5),  // shift to 0-4 range
                        color: color.withValues(alpha: 0.5),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: (data['stress']! + 2).clamp(0, 5),  // shift to 0-4 range
                        color: color.withValues(alpha: 0.25),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ],
                    barsSpace: 3,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Legend ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, 'Satisfaction', AppTheme.primary, 1.0),
              const SizedBox(width: 16),
              _buildLegendItem(context, 'Energy', AppTheme.primary, 0.5),
              const SizedBox(width: 16),
              _buildLegendItem(context, 'Stress', AppTheme.primary, 0.25),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // ── Category ROI Table ─────────────────────────
          ...categories.map((cat) {
            final data = insights[cat]!;
            final color = AppTheme.categoryColors[cat] ?? AppTheme.primary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    AppTheme.categoryIcons[cat] ?? Icons.bolt_rounded,
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(cat,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Text(
                    'ROI ${data['roi']!.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${data['count']!.toInt()}×',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text('Category Insights', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildLegendItem(
      BuildContext context, String label, Color color, double opacity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
