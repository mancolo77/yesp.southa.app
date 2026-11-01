import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StandingsTab extends StatelessWidget {
  const StandingsTab({super.key});

  final List<Map<String, dynamic>> _standings = const [
    {'pos': 1, 'team': 'Mamelodi Sundowns', 'p': 24, 'w': 18, 'pts': 58},
    {'pos': 2, 'team': 'Orlando Pirates', 'p': 24, 'w': 15, 'pts': 49},
    {'pos': 3, 'team': 'Stellenbosch FC', 'p': 24, 'w': 13, 'pts': 44},
    {'pos': 4, 'team': 'SuperSport United', 'p': 24, 'w': 11, 'pts': 40},
    {'pos': 5, 'team': 'Kaizer Chiefs', 'p': 24, 'w': 10, 'pts': 36},
    {'pos': 6, 'team': 'Cape Town City', 'p': 24, 'w': 9, 'pts': 33},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PSL Standings 2026',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 30, child: Text('#', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Club', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold))),
                    SizedBox(width: 35, child: Text('PL', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold))),
                    SizedBox(width: 35, child: Text('W', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold))),
                    SizedBox(width: 40, child: Text('PTS', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _standings.length,
                  itemBuilder: (context, idx) {
                    final item = _standings[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 30, child: Text('${item['pos']}', style: TextStyle(color: item['pos'] <= 3 ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.bold))),
                          Expanded(child: Text(item['team'], style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w600))),
                          SizedBox(width: 35, child: Text('${item['p']}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary))),
                          SizedBox(width: 35, child: Text('${item['w']}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary))),
                          SizedBox(width: 40, child: Text('${item['pts']}', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
