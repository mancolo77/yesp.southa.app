import 'package:flutter/material.dart';
import '../../services/workout_storage_service.dart';
import '../../theme/app_theme.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final _service = WorkoutStorageService();
  bool _showWeekStats = true; // true = Week, false = Month

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

  void _showChangeGoalDialog() {
    int current = _service.weeklyGoal;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          ),
          title: const Text(
            'Weekly Workout Target',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How many training sessions do you aim to complete each week?',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [3, 4, 5, 6].map((target) {
                  final isSel = current == target;
                  return InkWell(
                    onTap: () => setDialogState(() => current = target),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSel ? AppTheme.orangeAccent : AppTheme.sectionBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? AppTheme.orangeAccent : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        '$num',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSel ? AppTheme.darkNavy : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                _service.setWeeklyGoal(current);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orangeAccent,
                foregroundColor: AppTheme.darkNavy,
              ),
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedWeek = _service.completedThisWeekCount;
    final totalMinutesWeek = _service.totalMinutesThisWeek;

    final completedMonth = _service.completedThisMonthCount;
    final totalMinutesMonth = _service.totalMinutesThisMonth;

    final weeklyGoal = _service.weeklyGoal;
    final progressFraction = weeklyGoal > 0 ? (completedWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;

    final activeSessions = _showWeekStats ? completedWeek : completedMonth;
    final activeMinutes = _showWeekStats ? totalMinutesWeek : totalMinutesMonth;

    final sportsDist = _service.sportDistribution;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress & Stats',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Workout consistency and duration metrics',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _showChangeGoalDialog,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.sectionBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune_rounded, size: 16, color: AppTheme.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Goal',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Time Horizon Segment Control (Week / Month)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.sectionBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _showWeekStats = true),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _showWeekStats ? AppTheme.darkNavy : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'This Week',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _showWeekStats ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _showWeekStats = false),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_showWeekStats ? AppTheme.darkNavy : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'This Month',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: !_showWeekStats ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Key Metrics Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.statusCompleted.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded, color: AppTheme.statusCompleted, size: 20),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '$activeSessions',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Workouts Completed',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
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
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.orangeAccent.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.timer_rounded, color: AppTheme.orangeAccent, size: 20),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '$activeMinutes',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.orangeAccent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Active Minutes',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Goal Card with Diagonal Pattern Decor
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
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
                              'WEEKLY CONSISTENCY SCALE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppTheme.orangeAccent,
                              ),
                            ),
                            Text(
                              '${(progressFraction * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.orangeAccent,
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$completedWeek of $weeklyGoal workouts completed',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            Text(
                              'Target: $weeklyGoal/week',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sports Breakdown Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
              child: const Text(
                'Activity Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (sportsDist.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.sectionBg,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Complete sessions to view your activity breakdown.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: sportsDist.entries.map((entry) {
                      final total = sportsDist.values.fold(0, (a, b) => a + b);
                      final pct = total > 0 ? entry.value / total : 0.0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.darkNavy,
                                  ),
                                ),
                                Text(
                                  '${entry.value} sessions (${(pct * 100).toInt()}%)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppTheme.sectionBg,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.orangeAccent),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
