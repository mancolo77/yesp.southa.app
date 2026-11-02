class WorkoutEntry {
  final String id;
  final String type; // 'Walking', 'Running', 'Cycling', 'Warm-up', 'Team Sports'
  final String date; // 'YYYY-MM-DD'
  final int durationMinutes;
  final String note;
  final bool isCompleted;

  const WorkoutEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.durationMinutes,
    this.note = '',
    this.isCompleted = false,
  });

  WorkoutEntry copyWith({
    String? id,
    String? type,
    String? date,
    int? durationMinutes,
    String? note,
    bool? isCompleted,
  }) {
    return WorkoutEntry(
      id: id ?? this.id,
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
        'date': date,
        'durationMinutes': durationMinutes,
        'note': note,
        'isCompleted': isCompleted,
      };

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) => WorkoutEntry(
        id: json['id'] as String,
        type: json['type'] as String,
        date: json['date'] as String,
        durationMinutes: json['durationMinutes'] as int? ?? 30,
        note: json['note'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

