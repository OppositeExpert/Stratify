class Activity {
  final String? id;
  final DateTime date;
  final String startTime;
  final String timeSegment;
  final String category;
  final String activityName;
  final double timeSpent;
  final double moneySpent;
  final int satisfaction;
  final int energyImpact;
  final int stressImpact;
  final DateTime? createdAt;

  Activity({
    this.id,
    required this.date,
    required this.startTime,
    required this.timeSegment,
    required this.category,
    required this.activityName,
    required this.timeSpent,
    required this.moneySpent,
    required this.satisfaction,
    required this.energyImpact,
    required this.stressImpact,
    this.createdAt,
  });

  /// ROI Score formula:
  /// (satisfaction + energyImpact - stressImpact) / (timeSpent + moneySpent * 0.01 + 1)
  double get roiScore {
    final numerator = satisfaction + energyImpact - stressImpact;
    final denominator = timeSpent + moneySpent * 0.01 + 1;
    return numerator / denominator;
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String?,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      timeSegment: json['time_segment'] as String,
      category: json['category'] as String,
      activityName: json['activity_name'] as String,
      timeSpent: (json['time_spent'] as num).toDouble(),
      moneySpent: (json['money_spent'] as num).toDouble(),
      satisfaction: json['satisfaction'] as int,
      energyImpact: json['energy_impact'] as int,
      stressImpact: json['stress_impact'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'start_time': startTime,
      'time_segment': timeSegment,
      'category': category,
      'activity_name': activityName,
      'time_spent': timeSpent,
      'money_spent': moneySpent,
      'satisfaction': satisfaction,
      'energy_impact': energyImpact,
      'stress_impact': stressImpact,
    };
  }

  static const List<String> categories = [
    'Study',
    'Gym',
    'Social',
    'Entertainment',
    'Other',
  ];

  static const List<String> timeSegments = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
  ];

  /// Auto-detect time segment from hour
  static String segmentFromHour(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }
}
