import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/supabase_service.dart';

class ActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _activities.isNotEmpty;

  // ─── Data Fetching ──────────────────────────────────────────────

  Future<void> loadActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await SupabaseService.fetchAllActivities();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addActivity(Activity activity) async {
    try {
      await SupabaseService.insertActivity(activity);
      await loadActivities();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeActivity(String id) async {
    try {
      await SupabaseService.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Dashboard Analytics ────────────────────────────────────────

  /// Overall average ROI
  double get averageROI {
    if (_activities.isEmpty) return 0;
    final total = _activities.fold<double>(0, (sum, a) => sum + a.roiScore);
    return total / _activities.length;
  }

  /// Total hours logged
  double get totalHours {
    return _activities.fold<double>(0, (sum, a) => sum + a.timeSpent);
  }

  /// Total money spent
  double get totalMoneySpent {
    return _activities.fold<double>(0, (sum, a) => sum + a.moneySpent);
  }

  /// Top activities sorted by ROI (highest first), deduplicated by name
  List<MapEntry<String, double>> get topActivitiesByROI {
    final Map<String, List<double>> roiMap = {};
    for (final a in _activities) {
      roiMap.putIfAbsent(a.activityName, () => []).add(a.roiScore);
    }
    final avgMap = roiMap.map(
      (name, scores) => MapEntry(
        name,
        scores.reduce((a, b) => a + b) / scores.length,
      ),
    );
    final sorted = avgMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  /// Most frequent activities
  List<MapEntry<String, int>> get mostFrequentActivities {
    final Map<String, int> countMap = {};
    for (final a in _activities) {
      countMap[a.activityName] = (countMap[a.activityName] ?? 0) + 1;
    }
    final sorted = countMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  /// Category insights: avg satisfaction, energy, stress per category
  Map<String, Map<String, double>> get categoryInsights {
    final Map<String, List<Activity>> grouped = {};
    for (final a in _activities) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }

    return grouped.map((category, acts) {
      final n = acts.length;
      return MapEntry(category, {
        'satisfaction': acts.fold<double>(0, (s, a) => s + a.satisfaction) / n,
        'energy': acts.fold<double>(0, (s, a) => s + a.energyImpact) / n,
        'stress': acts.fold<double>(0, (s, a) => s + a.stressImpact) / n,
        'roi': acts.fold<double>(0, (s, a) => s + a.roiScore) / n,
        'count': n.toDouble(),
      });
    });
  }

  /// Weekly patterns: activity count & avg ROI per day of week
  Map<String, Map<String, double>> get weeklyPatterns {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<int, List<Activity>> grouped = {};

    for (final a in _activities) {
      final day = a.date.weekday; // 1=Mon, 7=Sun
      grouped.putIfAbsent(day, () => []).add(a);
    }

    final Map<String, Map<String, double>> result = {};
    for (int i = 1; i <= 7; i++) {
      final acts = grouped[i] ?? [];
      result[dayNames[i - 1]] = {
        'count': acts.length.toDouble(),
        'roi': acts.isEmpty
            ? 0
            : acts.fold<double>(0, (s, a) => s + a.roiScore) / acts.length,
      };
    }
    return result;
  }

  /// Time-of-day performance: avg ROI per segment
  Map<String, double> get timeOfDayPerformance {
    final Map<String, List<double>> grouped = {};
    for (final segment in Activity.timeSegments) {
      grouped[segment] = [];
    }
    for (final a in _activities) {
      grouped[a.timeSegment]?.add(a.roiScore);
    }
    return grouped.map((segment, scores) => MapEntry(
          segment,
          scores.isEmpty
              ? 0
              : scores.reduce((a, b) => a + b) / scores.length,
        ));
  }

  // ─── Recommendations ──────────────────────────────────────────

  /// Best activity recommendation for a given time segment.
  /// Returns null if no data for that segment.
  Map<String, dynamic>? bestActivityForSegment(String segment) {
    final segmentActivities =
        _activities.where((a) => a.timeSegment == segment).toList();

    if (segmentActivities.isEmpty) return null;

    // Group by activity name and compute avg ROI
    final Map<String, List<Activity>> grouped = {};
    for (final a in segmentActivities) {
      grouped.putIfAbsent(a.activityName, () => []).add(a);
    }

    String? bestName;
    double bestRoi = double.negativeInfinity;
    int bestCount = 0;
    String bestCategory = '';

    for (final entry in grouped.entries) {
      final avgRoi = entry.value.fold<double>(0, (s, a) => s + a.roiScore) /
          entry.value.length;
      if (avgRoi > bestRoi) {
        bestRoi = avgRoi;
        bestName = entry.key;
        bestCount = entry.value.length;
        bestCategory = entry.value.first.category;
      }
    }

    if (bestName == null) return null;

    return {
      'activityName': bestName,
      'category': bestCategory,
      'avgRoi': bestRoi,
      'frequency': bestCount,
      'totalInSegment': segmentActivities.length,
    };
  }

  /// Get all recommendations for all time segments
  Map<String, Map<String, dynamic>?> get allRecommendations {
    return {
      for (final segment in Activity.timeSegments)
        segment: bestActivityForSegment(segment),
    };
  }

  /// Current time segment based on system clock
  String get currentTimeSegment {
    return Activity.segmentFromHour(DateTime.now().hour);
  }
}
