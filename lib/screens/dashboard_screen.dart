import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../widgets/dashboard/roi_summary_card.dart';
import '../widgets/dashboard/top_activities_card.dart';
import '../widgets/dashboard/category_chart.dart';
import '../widgets/dashboard/trend_chart.dart';
import '../widgets/dashboard/time_heatmap.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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

          if (!provider.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No activities yet',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start logging activities to see your analytics here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadActivities,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // ── ROI Summary ─────────────────────────────
                RoiSummaryCard(
                  totalActivities: provider.activities.length,
                  averageRoi: provider.averageROI,
                  totalHours: provider.totalHours,
                  totalSpent: provider.totalMoneySpent,
                ),
                const SizedBox(height: 16),

                // ── Top Activities ──────────────────────────
                TopActivitiesCard(
                  topByRoi: provider.topActivitiesByROI,
                  mostFrequent: provider.mostFrequentActivities,
                ),
                const SizedBox(height: 16),

                // ── Time of Day Performance ─────────────────
                TimeHeatmap(
                  timeOfDayPerformance: provider.timeOfDayPerformance,
                ),
                const SizedBox(height: 16),

                // ── Category Insights ───────────────────────
                CategoryChart(insights: provider.categoryInsights),
                const SizedBox(height: 16),

                // ── Weekly Trends ───────────────────────────
                TrendChart(weeklyPatterns: provider.weeklyPatterns),
              ],
            ),
          );
        },
      ),
    );
  }
}
