import 'package:flutter/material.dart';
import '../../services/workout_diary_service.dart';
import '../../theme/app_theme.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({super.key});

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  final WorkoutDiaryService _diary = WorkoutDiaryService();

  final List<String> _activityTypes = [
    'Ходьба',
    'Бег',
    'Велосипед',
    'Разминка',
    'Командный спорт',
  ];

  void _showAddActivityDialog([WorkoutItem? itemToEdit]) {
    String selectedType = itemToEdit?.type ?? _activityTypes.first;
    int duration = itemToEdit?.durationMinutes ?? 30;
    final noteController = TextEditingController(text: itemToEdit?.note ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppTheme.screenPadding,
                right: AppTheme.screenPadding,
                top: AppTheme.screenPadding,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.screenPadding,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      itemToEdit == null ? 'Запланировать занятие' : 'Редактировать занятие',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Вид активности',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _activityTypes.map((type) {
                        final isSel = selectedType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedType = type);
                          },
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceSection,
                          labelStyle: TextStyle(
                            color: isSel ? AppTheme.darkNavy : AppTheme.darkNavy,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                            side: BorderSide(color: isSel ? AppTheme.primary : AppTheme.border),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Длительность',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                        Text(
                          '$duration мин',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    Slider(
                      value: duration.toDouble(),
                      min: 10,
                      max: 120,
                      divisions: 22,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppTheme.surfaceSection,
                      onChanged: (val) {
                        setModalState(() => duration = val.round());
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Заметка (необязательно)',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceSection,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          if (itemToEdit == null) {
                            _diary.addActivity(
                              type: selectedType,
                              date: DateTime.now(),
                              durationMinutes: duration,
                              note: noteController.text.trim(),
                            );
                          } else {
                            _diary.updateActivity(
                              itemToEdit.copyWith(
                                type: selectedType,
                                durationMinutes: duration,
                                note: noteController.text.trim(),
                              ),
                            );
                          }
                          Navigator.of(ctx).pop();
                        },
                        child: Text(itemToEdit == null ? 'Сохранить' : 'Обновить'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _diary,
      builder: (context, _) {
        final todayItems = _diary.getTodayWorkouts();
        final completedThisWeek = _diary.getCompletedCountThisWeek();
        final weeklyGoal = _diary.weeklyGoal;
        final weekProgress = weeklyGoal > 0 ? (completedThisWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Сегодня',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddActivityDialog(),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 20),
                    label: const Text(
                      'Добавить',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'План тренировок и учет активности',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 18),

              // 1. Тёмно-синий блок с недельной целью и оранжевой шкалой прогресса
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkNavy,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: AppTheme.cardShadow,
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.darkNavy,
                      AppTheme.navySurface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ЦЕЛЬ НА НЕДЕЛЮ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$completedThisWeek из $weeklyGoal занятий',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      completedThisWeek >= weeklyGoal ? 'Цель недели выполнена!' : 'Осталось занятий: ${weeklyGoal - completedThisWeek}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: weekProgress,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Список занятий на сегодня
              const Text(
                'Занятия на сегодня',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 12),
              if (todayItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSection,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.directions_run_rounded, size: 48, color: AppTheme.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        'На сегодня пока нет запланированных занятий',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddActivityDialog(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 48),
                        ),
                        child: const Text('Запланировать'),
                      ),
                    ],
                  ),
                )
              else
                ...todayItems.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(
                        color: item.isCompleted ? AppTheme.completedGreen : AppTheme.border,
                        width: item.isCompleted ? 1.5 : 1.0,
                      ),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        // Checkbox button
                        InkWell(
                          onTap: () => _diary.toggleCompleted(item.id),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: item.isCompleted ? AppTheme.completedGreen : AppTheme.surfaceSection,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: item.isCompleted ? AppTheme.completedGreen : AppTheme.border,
                              ),
                            ),
                            child: Icon(
                              item.isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                              color: item.isCompleted ? Colors.white : AppTheme.textSecondary,
                              size: 22,
                            ),
                          ),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.darkNavy,
                                      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceSection,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${item.durationMinutes} мин',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.note,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showAddActivityDialog(item);
                            } else if (val == 'delete') {
                              _diary.deleteActivity(item.id);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                            const PopupMenuItem(value: 'delete', child: Text('Удалить', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

