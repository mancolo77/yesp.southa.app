import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_entry.dart';

class WorkoutStorageService extends ChangeNotifier {
  static final WorkoutStorageService _instance = WorkoutStorageService._internal();
  factory WorkoutStorageService() => _instance;
  WorkoutStorageService._internal();

  List<WorkoutEntry> _entries = [];
  int _weeklyGoal = 4;
  bool _initialized = false;

  List<WorkoutEntry> get entries => List.unmodifiable(_entries);
  int get weeklyGoal => _weeklyGoal;

  String get todayDateStr => DateTime.now().toIso8601String().substring(0, 10);

  List<WorkoutEntry> get todayWorkouts {
    final today = todayDateStr;
    return _entries.where((e) => e.date == today).toList();
  }

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _weeklyGoal = prefs.getInt('w_weekly_goal') ?? 4;
    final rawJson = prefs.getString('w_workouts_data');

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List list = jsonDecode(rawJson);
        _entries = list.map((item) => WorkoutEntry.fromJson(item)).toList();
      } catch (_) {
        _loadDefaultEntries();
      }
    } else {
      _loadDefaultEntries();
      await _save();
    }

    _initialized = true;
    notifyListeners();
  }

  void _loadDefaultEntries() {
    final now = DateTime.now();
    final today = now.toIso8601String().substring(0, 10);
    final yesterday = now.subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    final twoDaysAgo = now.subtract(const Duration(days: 2)).toIso8601String().substring(0, 10);
    final tomorrow = now.add(const Duration(days: 1)).toIso8601String().substring(0, 10);

    _entries = [
      WorkoutEntry(
        id: 'w_1',
        type: 'Running',
        date: today,
        durationMinutes: 35,
        note: 'Morning easy 5K run in the park',
        isCompleted: true,
      ),
      WorkoutEntry(
        id: 'w_2',
        type: 'Warm-up',
        date: today,
        durationMinutes: 15,
        note: 'Stretching and core activation',
        isCompleted: false,
      ),
      WorkoutEntry(
        id: 'w_3',
        type: 'Cycling',
        date: yesterday,
        durationMinutes: 45,
        note: 'Interval ride around green route',
        isCompleted: true,
      ),
      WorkoutEntry(
        id: 'w_4',
        type: 'Walking',
        date: twoDaysAgo,
        durationMinutes: 40,
        note: 'Evening recovery walk',
        isCompleted: true,
      ),
      WorkoutEntry(
        id: 'w_5',
        type: 'Team Sports',
        date: tomorrow,
        durationMinutes: 60,
        note: 'Friendly weekend match',
        isCompleted: false,
      ),
    ];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('w_workouts_data', raw);
    await prefs.setInt('w_weekly_goal', _weeklyGoal);
  }

  Future<void> addWorkout(WorkoutEntry entry) async {
    _entries.insert(0, entry);
    await _save();
    notifyListeners();
  }

  Future<void> updateWorkout(WorkoutEntry entry) async {
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      _entries[idx] = entry;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteWorkout(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final idx = _entries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _entries[idx];
      _entries[idx] = current.copyWith(isCompleted: !current.isCompleted);
      await _save();
      notifyListeners();
    }
  }

  Future<void> setWeeklyGoal(int goal) async {
    _weeklyGoal = goal;
    await _save();
    notifyListeners();
  }

  // Week statistics calculations (Monday - Sunday)
  DateTime get _startOfCurrentWeek {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  }

  int get completedThisWeekCount {
    final start = _startOfCurrentWeek;
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _entries.where((e) {
      if (!e.isCompleted) return false;
      try {
        final d = DateTime.parse(e.date);
        return d.isAfter(start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(end.add(const Duration(seconds: 1)));
      } catch (_) {
        return false;
      }
    }).length;
  }

  int get totalMinutesThisWeek {
    final start = _startOfCurrentWeek;
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    int total = 0;
    for (var e in _entries) {
      if (!e.isCompleted) continue;
      try {
        final d = DateTime.parse(e.date);
        if (d.isAfter(start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(end.add(const Duration(seconds: 1)))) {
          total += e.durationMinutes;
        }
      } catch (_) {}
    }
    return total;
  }

  int get completedThisMonthCount {
    final now = DateTime.now();
    final prefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return _entries.where((e) => e.isCompleted && e.date.startsWith(prefix)).length;
  }

  int get totalMinutesThisMonth {
    final now = DateTime.now();
    final prefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    int total = 0;
    for (var e in _entries) {
      if (e.isCompleted && e.date.startsWith(prefix)) {
        total += e.durationMinutes;
      }
    }
    return total;
  }

  Map<String, int> get sportDistribution {
    final map = <String, int>{};
    for (var e in _entries) {
      if (e.isCompleted) {
        map[e.type] = (map[e.type] ?? 0) + 1;
      }
    }
    return map;
  }
}
