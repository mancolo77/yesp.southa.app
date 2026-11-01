import 'package:flutter/material.dart';
import '../../services/workout_diary_service.dart';
import '../../theme/app_theme.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final WorkoutDiaryService _diary = WorkoutDiaryService();
  DateTime _selectedDate = DateTime.now();

  void _showDeleteConfirm(WorkoutItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        title: const Text('Удалить занятие?', style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
        content: Text('Вы действительно хотите удалить «${item.type}»?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _diary.deleteActivity(item.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _diary,
      builder: (context, _) {
        final allItems = _diary.items;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Календарь',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'История и планирование спортивных занятий',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 18),

              // Horizontal date selector (Last 7 days + today + next 3 days)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(11, (index) {
                    final dayDate = DateTime.now().subtract(const Duration(days: 7)).add(Duration(days: index));
                    final isSelected = dayDate.year == _selectedDate.year &&
                        dayDate.month == _selectedDate.month &&
                        dayDate.day == _selectedDate.day;

                    // Check if has workouts
                    final dayWorkouts = allItems.where((w) =>
                        w.date.year == dayDate.year && w.date.month == dayDate.month && w.date.day == dayDate.day);
                    final hasCompleted = dayWorkouts.any((w) => w.isCompleted);
                    final hasPending = dayWorkouts.any((w) => !w.isCompleted);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedDate = dayDate),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : AppTheme.border,
                            ),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Text(
                                ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][dayDate.weekday - 1],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.darkNavy : AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${dayDate.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.darkNavy : AppTheme.darkNavy,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Marker
                              if (hasCompleted)
                                const Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.completedGreen)
                              else if (hasPending)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Workouts for selected date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Занятия на ${_selectedDate.day}.${_selectedDate.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Builder(builder: (context) {
                final selectedWorkouts = allItems.where((w) {
                  return w.date.year == _selectedDate.year &&
                      w.date.month == _selectedDate.month &&
                      w.date.day == _selectedDate.day;
                }).toList();

                if (selectedWorkouts.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSection,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.event_note_rounded, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'Добавьте первое занятие на этот день',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: selectedWorkouts.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        border: Border.all(
                          color: item.isCompleted ? AppTheme.completedGreen : AppTheme.border,
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.isCompleted ? Icons.check_circle_rounded : Icons.fiber_manual_record_rounded,
                            color: item.isCompleted ? AppTheme.completedGreen : AppTheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.type,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkNavy,
                                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.durationMinutes} мин',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                                if (item.note.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.note,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondary, size: 20),
                            onPressed: () => _showDeleteConfirm(item),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

