import 'package:flutter/material.dart';
import '../../models/workout_entry.dart';
import '../../services/workout_storage_service.dart';
import '../../theme/app_theme.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  final _service = WorkoutStorageService();
  String _filterType = 'All';

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

  void _confirmDelete(WorkoutEntry item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text(
          'Delete Workout?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
        ),
        content: Text(
          'Are you sure you want to remove "${item.type}" on ${item.date} from your log?',
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              _service.deleteWorkout(item.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSel ? Colors.white : AppTheme.darkNavy,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Duration',
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
                const Text(
                  'Note (Optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'Workout notes...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.sectionBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
                      isEditing ? 'Save Changes' : 'Schedule Workout',
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
    final types = ['All', 'Walking', 'Running', 'Cycling', 'Warm-up', 'Team Sports'];

    final sorted = List<WorkoutEntry>.from(_service.entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    final filtered = sorted.where((e) {
      if (_filterType == 'All') return true;
      return e.type == _filterType;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Calendar',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'View, edit and track workouts by date',
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
                      'Plan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Type Filter Chips (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: types.map((t) {
                  final isSelected = t == _filterType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _filterType = t),
                      selectedColor: AppTheme.darkNavy,
                      backgroundColor: AppTheme.sectionBg,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppTheme.darkNavy,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppTheme.darkNavy : AppTheme.border,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Workout Cards
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 54, color: AppTheme.textSecondary.withAlpha(90)),
                          const SizedBox(height: 12),
                          const Text(
                            'Add your first workout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "Plan" above to add your training schedule.',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isCompleted = item.isCompleted;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(
                              color: isCompleted ? AppTheme.statusCompleted.withAlpha(120) : AppTheme.border,
                            ),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Status badge & Date
                              Row(
                                children: [
                                  // Status Indicator with green checkmark or orange dot
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? AppTheme.statusCompleted.withAlpha(20)
                                          : AppTheme.orangeAccent.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isCompleted)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 14,
                                            color: AppTheme.statusCompleted,
                                          )
                                        else
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppTheme.orangeAccent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        const SizedBox(width: 5),
                                        Text(
                                          isCompleted ? 'Completed' : 'Scheduled',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isCompleted
                                                ? AppTheme.statusCompleted
                                                : AppTheme.textAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.date,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.darkNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Middle Row: Activity Info
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.sectionBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _iconForType(item.type),
                                      color: isCompleted ? AppTheme.statusCompleted : AppTheme.orangeAccent,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
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
                                          '${item.durationMinutes} minutes${item.note.isNotEmpty ? ' • ${item.note}' : ''}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 22, color: AppTheme.border),

                              // Bottom Actions Row: Toggle Done, Edit, Delete
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () => _service.toggleCompleted(item.id),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isCompleted
                                                ? Icons.check_box_rounded
                                                : Icons.check_box_outline_blank_rounded,
                                            size: 18,
                                            color: isCompleted
                                                ? AppTheme.statusCompleted
                                                : AppTheme.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isCompleted ? 'Mark Pending' : 'Mark Completed',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isCompleted
                                                  ? AppTheme.statusCompleted
                                                  : AppTheme.darkNavy,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        color: AppTheme.textSecondary,
                                        onPressed: () => _showAddEditSheet(item),
                                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                        color: Colors.red.shade600,
                                        onPressed: () => _confirmDelete(item),
                                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                      ),
                                    ],
                                  ),
                                ],
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
