import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Live', 'Upcoming', 'Results'];

  final List<Map<String, dynamic>> _matches = [
    {
      'league': 'South Africa PSL',
      'teamA': 'Mamelodi Sundowns',
      'teamB': 'Orlando Pirates',
      'scoreA': '2',
      'scoreB': '1',
      'time': '78\'',
      'isLive': true,
      'status': 'Second Half'
    },
    {
      'league': 'South Africa PSL',
      'teamA': 'Kaizer Chiefs',
      'teamB': 'Cape Town City',
      'scoreA': '1',
      'scoreB': '1',
      'time': '54\'',
      'isLive': true,
      'status': 'Second Half'
    },
    {
      'league': 'URC Rugby',
      'teamA': 'Stormers',
      'teamB': 'Bulls',
      'scoreA': '-',
      'scoreB': '-',
      'time': 'Today, 20:30',
      'isLive': false,
      'status': 'Upcoming'
    },
    {
      'league': 'South Africa PSL',
      'teamA': 'SuperSport United',
      'teamB': 'Stellenbosch FC',
      'scoreA': '-',
      'scoreB': '-',
      'time': 'Tomorrow, 17:00',
      'isLive': false,
      'status': 'Upcoming'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredMatches = _selectedFilter == 0
        ? _matches.where((m) => m['isLive'] == true).toList()
        : _selectedFilter == 1
            ? _matches.where((m) => m['isLive'] == false).toList()
            : _matches;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'South Africa Match Center',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('PSL / URC', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filters.length, (idx) {
                  final isSel = _selectedFilter == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filters[idx]),
                      selected: isSel,
                      onSelected: (_) => setState(() => _selectedFilter = idx),
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceCard,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.black : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredMatches.length,
                itemBuilder: (context, idx) {
                  final m = filteredMatches[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(color: AppTheme.border.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m['league'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            if (m['isLive'])
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentLive,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('LIVE ${m['time']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            else
                              Text(m['time'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(m['teamA'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 15))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                m['isLive'] ? '${m['scoreA']} - ${m['scoreB']}' : 'VS',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                            ),
                            Expanded(child: Text(m['teamB'], textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 15))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Match Details'),
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
