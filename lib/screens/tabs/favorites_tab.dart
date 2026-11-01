import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  final List<Map<String, String>> _favorites = const [
    {'name': 'Mamelodi Sundowns', 'city': 'Pretoria • PSL', 'icon': 'sports_soccer'},
    {'name': 'Orlando Pirates', 'city': 'Soweto • PSL', 'icon': 'sports_soccer'},
    {'name': 'Springboks Rugby', 'city': 'National Team', 'icon': 'sports_rugby'},
    {'name': 'Proteas Cricket', 'city': 'National Team', 'icon': 'sports_cricket'},
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
                'Favorite Teams',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, idx) {
                    final f = _favorites[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.surfaceSecondary,
                            child: const Icon(Icons.star, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(f['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMain, fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(f['city']!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.star, color: AppTheme.primary),
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
