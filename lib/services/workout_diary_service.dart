import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutItem {
  final String id;
  final String type; // 'Ходьба', 'Бег', 'Велосипед', 'Разминка', 'Командный спорт'
  final DateTime date;
  final int durationMinutes;
  final String note;
  final bool isCompleted;

  WorkoutItem({
    required this.id,
    required this.type,
    required this.date,
    required this.durationMinutes,
    required this.note,
    required this.isCompleted,
  });

  WorkoutItem copyWith({
    String? type,
    DateTime? date,
    int? durationMinutes,
    String? note,
    bool? isCompleted,
  }) {
    return WorkoutItem(
      id: id,
      type: type ?? this.type,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'note': note,
        'isCompleted': isCompleted,
      };

  factory WorkoutItem.fromJson(Map<String, dynamic> json) => WorkoutItem(
        id: json['id'] as String,
        type: json['type'] as String,
        date: DateTime.parse(json['date'] as String),
        durationMinutes: json['durationMinutes'] as int? ?? 30,
        note: json['note'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class WorkoutDiaryService with ChangeNotifier {
  static final WorkoutDiaryService _instance = WorkoutDiaryService._internal();
  factory WorkoutDiaryService() => _instance;
  WorkoutDiaryService._internal();

  final List<WorkoutItem> _items = [];
  int _weeklyGoal = 4; // Личная цель занятий в неделю

  List<WorkoutItem> get items => List.unmodifiable(_items);
  int get weeklyGoal => _weeklyGoal;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _weeklyGoal = prefs.getInt('workout_weekly_goal') ?? 4;
      final raw = prefs.getString('workout_items');
      _items.clear();
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = json.decode(raw);
        _items.addAll(list.map((e) => WorkoutItem.fromJson(e as Map<String, dynamic>)));
      } else {
        // Starter sample workouts
        final now = DateTime.now();
        _items.addAll([
          WorkoutItem(
            id: 'demo_1',
            type: 'Утренняя пробежка',
            date: DateTime(now.year, now.month, now.day, 8, 30),
            durationMinutes: 35,
            note: 'Легкий восстановительный темп в парке',
            isCompleted: true,
          ),
          WorkoutItem(
            id: 'demo_2',
            type: 'Командный спорт',
            date: DateTime(now.year, now.month, now.day, 19, 0),
            durationMinutes: 60,
            note: 'Тренировка с командой',
            isCompleted: false,
          ),
          WorkoutItem(
            id: 'demo_3',
            type: 'Велосипед',
            date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
            durationMinutes: 45,
            note: 'Кардио заезд',
            isCompleted: true,
          ),
          WorkoutItem(
            id: 'demo_4',
            type: 'Разминка и растяжка',
            date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2)),
            durationMinutes: 25,
            note: 'Суставная гимнастика',
            isCompleted: true,
          ),
        ]);
        await _save();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('workout_weekly_goal', _weeklyGoal);
      final raw = json.encode(_items.map((e) => e.toJson()).toList());
      await prefs.setString('workout_items', raw);
    } catch (_) {}
  }

  void addActivity({
    required String type,
    required DateTime date,
    required int durationMinutes,
    required String note,
  }) {
    final newItem = WorkoutItem(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      date: date,
      durationMinutes: durationMinutes,
      note: note,
      isCompleted: false,
    );
    _items.insert(0, newItem);
    _save();
    notifyListeners();
  }

  void updateActivity(WorkoutItem updated) {
    final idx = _items.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      _save();
      notifyListeners();
    }
  }

  void toggleCompleted(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final current = _items[idx];
      _items[idx] = current.copyWith(isCompleted: !current.isCompleted);
      _save();
      notifyListeners();
    }
  }

  void deleteActivity(String id) {
    _items.removeWhere((e) => e.id == id);
    _save();
    notifyListeners();
  }

  void setWeeklyGoal(int goal) {
    _weeklyGoal = goal;
    _save();
    notifyListeners();
  }

  // Filtered queries
  List<WorkoutItem> getTodayWorkouts() {
    final now = DateTime.now();
    return _items.where((e) {
      return e.date.year == now.year && e.date.month == now.month && e.date.day == now.day;
    }).toList();
  }

  int getCompletedCountThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final cleanStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return _items.where((e) => e.isCompleted && e.date.isAfter(cleanStart.subtract(const Duration(seconds: 1)))).length;
  }

  int getTotalDurationMinutesThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final cleanStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    return _items
        .where((e) => e.isCompleted && e.date.isAfter(cleanStart.subtract(const Duration(seconds: 1))))
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  int getCompletedCountThisMonth() {
    final now = DateTime.now();
    return _items.where((e) => e.isCompleted && e.date.year == now.year && e.date.month == now.month).length;
  }

  int getTotalDurationMinutesThisMonth() {
    final now = DateTime.now();
    return _items
        .where((e) => e.isCompleted && e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }
}

