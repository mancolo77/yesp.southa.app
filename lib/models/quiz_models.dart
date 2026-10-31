class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty;
  final int points;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correct_index'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Легкий',
      points: json['points'] as int? ?? 100,
    );
  }
}

class WordItem {
  final String word;
  final String hint;
  final String category;
  final String difficulty;
  final int points;

  const WordItem({
    required this.word,
    required this.hint,
    required this.category,
    required this.difficulty,
    required this.points,
  });

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      word: (json['word'] as String? ?? '').toUpperCase(),
      hint: json['hint'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Средний',
      points: json['points'] as int? ?? 100,
    );
  }
}

class QuizCategory {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String colorHex;
  final List<QuizQuestion> questions;
  final List<WordItem> words;

  const QuizCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.colorHex,
    required this.questions,
    required this.words,
  });

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'sports_soccer',
      colorHex: json['color'] as String? ?? '#00F5D4',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      words: (json['words'] as List<dynamic>?)
              ?.map((e) => WordItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TrueFalseFact {
  final String id;
  final String statement;
  final bool isTrue;
  final String explanation;
  final int points;

  const TrueFalseFact({
    required this.id,
    required this.statement,
    required this.isTrue,
    required this.explanation,
    required this.points,
  });

  factory TrueFalseFact.fromJson(Map<String, dynamic> json) {
    return TrueFalseFact(
      id: json['id'] as String? ?? '',
      statement: json['statement'] as String? ?? '',
      isTrue: json['is_true'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
      points: json['points'] as int? ?? 80,
    );
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int target;
  final int xpReward;
  final int coinsReward;
  final String icon;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.xpReward,
    required this.coinsReward,
    required this.icon,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      target: json['target'] as int? ?? 1,
      xpReward: json['xp_reward'] as int? ?? 100,
      coinsReward: json['coins_reward'] as int? ?? 50,
      icon: json['icon'] as String? ?? 'sports_soccer',
    );
  }
}

class LoyaltyReward {
  final String id;
  final String title;
  final String category;
  final int cost;
  final String description;
  final String icon;
  final String colorHex;

  const LoyaltyReward({
    required this.id,
    required this.title,
    required this.category,
    required this.cost,
    required this.description,
    required this.icon,
    required this.colorHex,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Бонус',
      cost: json['cost'] as int? ?? 100,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'card_giftcard',
      colorHex: json['color'] as String? ?? '#00F5D4',
    );
  }
}

class UserRank {
  final int level;
  final String title;
  final int requiredXp;
  final String badge;
  final double bonusMultiplier;

  const UserRank({
    required this.level,
    required this.title,
    required this.requiredXp,
    required this.badge,
    required this.bonusMultiplier,
  });

  factory UserRank.fromJson(Map<String, dynamic> json) {
    return UserRank(
      level: json['level'] as int? ?? 1,
      title: json['title'] as String? ?? 'Новичок',
      requiredXp: json['required_xp'] as int? ?? 0,
      badge: json['badge'] as String? ?? '⚽',
      bonusMultiplier: (json['bonus_multiplier'] as num?)?.toDouble() ?? 1.0,
    );
  }
}

class AchievementItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int target;

  const AchievementItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
  });

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    return AchievementItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'emoji_events',
      target: json['target'] as int? ?? 1,
    );
  }
}

class LeaderboardEntry {
  final String name;
  final int score;
  final int rank;
  final String avatar;
  final int matches;

  const LeaderboardEntry({
    required this.name,
    required this.score,
    required this.rank,
    required this.avatar,
    required this.matches,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] as String? ?? 'Игрок',
      score: json['score'] as int? ?? 0,
      rank: json['rank'] as int? ?? 99,
      avatar: json['avatar'] as String? ?? '⚽',
      matches: json['matches'] as int? ?? 0,
    );
  }
}

class QuizDataBundle {
  final String appName;
  final String appTheme;
  final String language;
  final List<UserRank> ranks;
  final List<QuizCategory> categories;
  final List<TrueFalseFact> trueFalseFacts;
  final List<DailyChallenge> dailyChallenges;
  final List<LoyaltyReward> rewards;
  final List<AchievementItem> achievements;
  final List<LeaderboardEntry> leaderboard;

  const QuizDataBundle({
    required this.appName,
    required this.appTheme,
    required this.language,
    required this.ranks,
    required this.categories,
    required this.trueFalseFacts,
    required this.dailyChallenges,
    required this.rewards,
    required this.achievements,
    required this.leaderboard,
  });

  factory QuizDataBundle.fromJson(Map<String, dynamic> json) {
    final appInfo = json['app_info'] as Map<String, dynamic>? ?? {};

    return QuizDataBundle(
      appName: appInfo['name'] as String? ?? 'Олим Матч-Центр',
      appTheme: appInfo['theme'] as String? ?? 'РПЛ Квиз',
      language: appInfo['language'] as String? ?? 'ru',
      ranks: (json['ranks'] as List<dynamic>?)
              ?.map((e) => UserRank.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => QuizCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trueFalseFacts: (json['true_false_facts'] as List<dynamic>?)
              ?.map((e) => TrueFalseFact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyChallenges: (json['daily_challenges'] as List<dynamic>?)
              ?.map((e) => DailyChallenge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rewards: (json['rewards_store'] as List<dynamic>?)
              ?.map((e) => LoyaltyReward.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => AchievementItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      leaderboard: (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
