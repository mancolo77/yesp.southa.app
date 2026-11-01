import 'package:flutter/material.dart';
import '../../models/workout_entry.dart';
import '../../services/workout_storage_service.dart';
import '../../theme/app_theme.dart';

class TodayTab extends StatefulWidget {
  const TodayTab({super.key});

  @override
  State<TodayTab> createState() => _TodayTabState();
}

class _TodayTabState extends State<TodayTab> {
  final _service = WorkoutStorageService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Icons.directions_run_rounded;
      case 'cycling':
        return Icons.directions_bike_rounded;
      case 'warm-up':
        return Icons.fitness_center_rounded;
      case 'team sports':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }

  void _showAddEditSheet([WorkoutEntry? existing]) {
    final isEditing = existing != null;
    String selectedType = existing?.type ?? 'Running';
    int duration = existing?.durationMinutes ?? 30;
    String date = existing?.date ?? _service.todayDateStr;
    final noteCtrl = TextEditingController(text: existing?.note ?? '');

    final types = ['Walking', 'Running', 'Cycling', 'Warm-up', 'Team Sports'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Edit Activity' : 'Plan New Activity',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
                ),
                const SizedBox(height: 16),

                // Activity Type selector
                const Text(
                  'Activity Type',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: types.map((t) {
                    final isSel = selectedType == t;
                    return InkWell(
                      onTap: () => setSheetState(() => selectedType = t),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.darkNavy : AppTheme.sectionBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? AppTheme.darkNavy : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _iconForType(t),
                              size: 16,
                              color: isSel ? AppTheme.orangeAccent : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSel ? Colors.white : AppTheme.darkNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Duration Picker Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Planned Duration',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                    ),
                    Text(
                      '$duration min',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orangeAccent,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: duration.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 22,
                  activeColor: AppTheme.orangeAccent,
                  inactiveColor: AppTheme.border,
                  onChanged: (val) => setSheetState(() => duration = val.round()),
                ),
                const SizedBox(height: 10),

                // Optional Note
                const Text(
                  'Note (Optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Route, cadence, stretching focus...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.sectionBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button (height >= 48)
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isEditing) {
                        await _service.updateWorkout(
                          existing.copyWith(
                            type: selectedType,
                            durationMinutes: duration,
                            note: noteCtrl.text.trim(),
                          ),
                        );
                      } else {
                        await _service.addWorkout(
                          WorkoutEntry(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            type: selectedType,
                            date: date,
                            durationMinutes: duration,
                            note: noteCtrl.text.trim(),
                            isCompleted: false,
                          ),
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      foregroundColor: AppTheme.darkNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Add to Schedule',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayItems = _service.todayWorkouts;
    final completedWeek = _service.completedThisWeekCount;
    final weeklyGoal = _service.weeklyGoal;
    final progressFraction = weeklyGoal > 0 ? (completedWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Add Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Scheduled activities and daily progress',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditSheet(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      foregroundColor: AppTheme.darkNavy,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Add',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Required Weekly Goal Card (Dark Navy block with orange progress bar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkNavy,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: AppTheme.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: CustomPaint(
                  painter: DiaryDiagonalPainter(
                    stripeColor: AppTheme.secondaryBlue,
                    stripeWidth: 5,
                    gap: 12,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'WEEKLY ACTIVITY GOAL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppTheme.orangeAccent,
                              ),
                            ),
                            Text(
                              '$completedWeek of $weeklyGoal workouts',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.orangeAccent),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          completedWeek >= weeklyGoal
                              ? 'Goal achieved! Keep up the momentum.'
                              : '${weeklyGoal - completedWeek} more session${weeklyGoal - completedWeek > 1 ? 's' : ''} to reach this week target.',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Today's Workouts List
            Expanded(
              child: todayItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center_rounded, size: 52, color: AppTheme.textSecondary.withAlpha(90)),
                          const SizedBox(height: 12),
                          const Text(
                            'No workouts scheduled for today',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "Add" above to plan a workout.',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: todayItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = todayItems[index];

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(
                              color: item.isCompleted ? AppTheme.statusCompleted : AppTheme.border,
                              width: item.isCompleted ? 1.5 : 1.0,
                            ),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.isCompleted
                                      ? AppTheme.statusCompleted.withAlpha(20)
                                      : AppTheme.sectionBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _iconForType(item.type),
                                  color: item.isCompleted ? AppTheme.statusCompleted : AppTheme.orangeAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.type,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkNavy,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.durationMinutes} min${item.note.isNotEmpty ? ' • ${item.note}' : ''}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _service.toggleCompleted(item.id),
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: item.isCompleted
                                        ? AppTheme.statusCompleted.withAlpha(20)
                                        : AppTheme.sectionBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: item.isCompleted ? AppTheme.statusCompleted : AppTheme.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                        color: item.isCompleted ? AppTheme.statusCompleted : AppTheme.textSecondary,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item.isCompleted ? 'Done' : 'Pending',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: item.isCompleted ? AppTheme.statusCompleted : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
