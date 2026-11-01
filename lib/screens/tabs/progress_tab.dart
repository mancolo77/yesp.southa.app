import 'package:flutter/material.dart';
import '../../services/workout_diary_service.dart';
import '../../theme/app_theme.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final WorkoutDiaryService _diary = WorkoutDiaryService();
  bool _isWeekSelected = true;

  void _showChangeGoalDialog() {
    int currentGoal = _diary.weeklyGoal;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        title: const Text('Цель занятий в неделю', style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentGoal тренировок',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                Slider(
                  value: currentGoal.toDouble(),
                  min: 1,
                  max: 7,
                  divisions: 6,
                  activeColor: AppTheme.primary,
                  onChanged: (val) {
                    setDialogState(() => currentGoal = val.round());
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              _diary.setWeeklyGoal(currentGoal);
              Navigator.of(ctx).pop();
            },
            child: const Text('Сохранить'),
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
        final completedCount = _isWeekSelected
            ? _diary.getCompletedCountThisWeek()
            : _diary.getCompletedCountThisMonth();

        final totalDurationMinutes = _isWeekSelected
            ? _diary.getTotalDurationMinutesThisWeek()
            : _diary.getTotalDurationMinutesThisMonth();

        final weeklyGoal = _diary.weeklyGoal;
        final weekCompleted = _diary.getCompletedCountThisWeek();
        final goalProgress = weeklyGoal > 0 ? (weekCompleted / weeklyGoal).clamp(0.0, 1.0) : 0.0;

        final hours = totalDurationMinutes ~/ 60;
        final mins = totalDurationMinutes % 60;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Прогресс',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Сводка активности и статистика выполнения цели',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),

              // Period Toggle (Неделя / Месяц)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSection,
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isWeekSelected = true),
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isWeekSelected ? AppTheme.surfaceCard : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                            boxShadow: _isWeekSelected ? AppTheme.cardShadow : null,
                          ),
                          child: Center(
                            child: Text(
                              'За неделю',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isWeekSelected ? AppTheme.darkNavy : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isWeekSelected = false),
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isWeekSelected ? AppTheme.surfaceCard : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                            boxShadow: !_isWeekSelected ? AppTheme.cardShadow : null,
                          ),
                          child: Center(
                            child: Text(
                              'За месяц',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !_isWeekSelected ? AppTheme.darkNavy : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Статистика (2 карточки)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Выполнено занятий',
                      value: '$completedCount',
                      subtitle: _isWeekSelected ? 'за 7 дней' : 'за текущий месяц',
                      icon: Icons.check_circle_outline_rounded,
                      accentColor: AppTheme.completedGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Общее время',
                      value: hours > 0 ? '$hours ч $mins м' : '$mins мин',
                      subtitle: 'активности',
                      icon: Icons.timer_outlined,
                      accentColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Личная цель по числу занятий в неделю
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
                          'ЛИЧНАЯ ЦЕЛЬ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                        InkWell(
                          onTap: _showChangeGoalDialog,
                          child: const Text(
                            'Изменить цель',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$weeklyGoal тренировок в неделю',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Выполнено на этой неделе: $weekCompleted из $weeklyGoal (${(goalProgress * 100).toInt()}%)',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: goalProgress,
                        minHeight: 10,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Дисклеймер
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSection,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppTheme.darkNavy, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Все данные тренировок и настройки хранятся локально на вашем устройстве. Дневник предназначен для поддержания личной дисциплины и регулярности занятий.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

