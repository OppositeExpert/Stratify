import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'activity_logs';

  /// Insert a new activity
  static Future<void> insertActivity(Activity activity) async {
    await _client.from(_table).insert(activity.toJson());
  }

  /// Fetch all activities, newest first
  static Future<List<Activity>> fetchAllActivities() async {
    final response = await _client
        .from(_table)
        .select()
        .order('date', ascending: false)
        .order('start_time', ascending: false);

    return (response as List)
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch activities within a date range
  static Future<List<Activity>> fetchActivitiesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final startStr =
        '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final response = await _client
        .from(_table)
        .select()
        .gte('date', startStr)
        .lte('date', endStr)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch activities by time segment
  static Future<List<Activity>> fetchActivitiesByTimeSegment(
    String segment,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('time_segment', segment)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => Activity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Delete an activity by ID
  static Future<void> deleteActivity(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
