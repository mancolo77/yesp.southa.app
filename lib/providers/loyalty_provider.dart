import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';
import '../services/quiz_data_service.dart';

class LoyaltyProvider extends ChangeNotifier {
  QuizDataBundle? _bundle;
  bool _isLoading = true;

  int _xp = 180;
  int _coins = 450;
  int _completedQuizzes = 2;
  int _correctAnswers = 9;
  int _totalAnswers = 12;
  int _streakDays = 3;
  bool _dailyBonusClaimed = false;

  final Set<String> _unlockedRewards = {'rw_4'}; // One shield given as welcome gift
  final Set<String> _claimedChallenges = {};
  final Map<String, int> _challengeProgress = {
    'dc_1': 1,
    'dc_2': 3,
    'dc_3': 1,
    'dc_4': 2,
  };

  QuizDataBundle? get bundle => _bundle;
  bool get isLoading => _isLoading;

  int get xp => _xp;
  int get coins => _coins;
  int get completedQuizzes => _completedQuizzes;
  int get correctAnswers => _correctAnswers;
  int get totalAnswers => _totalAnswers;
  int get streakDays => _streakDays;
  bool get dailyBonusClaimed => _dailyBonusClaimed;

  double get accuracyRate {
    if (_totalAnswers == 0) return 100.0;
    return (_correctAnswers / _totalAnswers) * 100;
  }

  Set<String> get unlockedRewards => Set.unmodifiable(_unlockedRewards);
  Set<String> get claimedChallenges => Set.unmodifiable(_claimedChallenges);

  LoyaltyProvider({QuizDataBundle? initialBundle, bool autoInit = true}) {
    if (initialBundle != null) {
      _bundle = initialBundle;
      _isLoading = false;
    }
    if (autoInit) {
      init();
    }
  }

  Future<void> init() async {
    if (_bundle == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _bundle = await QuizDataService.loadQuizData();
      await _loadPreferences();
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt('loyalty_xp') ?? _xp;
    _coins = prefs.getInt('loyalty_coins') ?? _coins;
    _completedQuizzes = prefs.getInt('loyalty_quizzes') ?? _completedQuizzes;
    _correctAnswers = prefs.getInt('loyalty_correct') ?? _correctAnswers;
    _totalAnswers = prefs.getInt('loyalty_total') ?? _totalAnswers;
    _streakDays = prefs.getInt('loyalty_streak') ?? _streakDays;
    _dailyBonusClaimed = prefs.getBool('loyalty_daily_bonus_claimed') ?? false;

    final savedRewards = prefs.getStringList('unlocked_rewards');
    if (savedRewards != null) {
      _unlockedRewards.addAll(savedRewards);
    }

    final savedClaimed = prefs.getStringList('claimed_challenges');
    if (savedClaimed != null) {
      _claimedChallenges.addAll(savedClaimed);
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loyalty_xp', _xp);
    await prefs.setInt('loyalty_coins', _coins);
    await prefs.setInt('loyalty_quizzes', _completedQuizzes);
    await prefs.setInt('loyalty_correct', _correctAnswers);
    await prefs.setInt('loyalty_total', _totalAnswers);
    await prefs.setInt('loyalty_streak', _streakDays);
    await prefs.setBool('loyalty_daily_bonus_claimed', _dailyBonusClaimed);
    await prefs.setStringList('unlocked_rewards', _unlockedRewards.toList());
    await prefs.setStringList('claimed_challenges', _claimedChallenges.toList());
  }

  UserRank get currentRank {
    final ranks = _bundle?.ranks;
    if (ranks == null || ranks.isEmpty) {
      return const UserRank(
        level: 1,
        title: 'Новичок на трибунах',
        requiredXp: 0,
        badge: '⚽',
        bonusMultiplier: 1.0,
      );
    }

    UserRank highest = ranks.first;
    for (final r in ranks) {
      if (_xp >= r.requiredXp) {
        highest = r;
      }
    }
    return highest;
  }

  UserRank? get nextRank {
    final ranks = _bundle?.ranks;
    if (ranks == null) return null;

    final curr = currentRank;
    final index = ranks.indexWhere((r) => r.level == curr.level);
    if (index >= 0 && index < ranks.length - 1) {
      return ranks[index + 1];
    }
    return null;
  }

  double get rankProgress {
    final curr = currentRank;
    final next = nextRank;
    if (next == null) return 1.0;

    final base = curr.requiredXp;
    final target = next.requiredXp;
    final currentProg = _xp - base;
    final span = target - base;
    if (span <= 0) return 1.0;
    return (currentProg / span).clamp(0.0, 1.0);
  }

  bool isRewardPurchased(String rewardId) {
    return _unlockedRewards.contains(rewardId);
  }

  bool purchaseReward(LoyaltyReward reward) {
    if (_coins < reward.cost) {
      return false;
    }
    _coins -= reward.cost;
    _unlockedRewards.add(reward.id);
    _savePreferences();
    notifyListeners();
    return true;
  }

  void claimDailyBonus() {
    if (_dailyBonusClaimed) return;
    _dailyBonusClaimed = true;
    _streakDays += 1;
    _coins += 100;
    _xp += 50;
    _savePreferences();
    notifyListeners();
  }

  bool isChallengeCompleted(String challengeId) {
    final challenge = _bundle?.dailyChallenges.firstWhere(
      (c) => c.id == challengeId,
      orElse: () => const DailyChallenge(
        id: '',
        title: '',
        description: '',
        target: 1,
        xpReward: 0,
        coinsReward: 0,
        icon: '',
      ),
    );
    if (challenge == null || challenge.id.isEmpty) return false;
    final progress = _challengeProgress[challengeId] ?? 0;
    return progress >= challenge.target;
  }

  bool isChallengeClaimed(String challengeId) {
    return _claimedChallenges.contains(challengeId);
  }

  int getChallengeProgress(String challengeId) {
    return _challengeProgress[challengeId] ?? 0;
  }

  void claimDailyChallenge(DailyChallenge challenge) {
    if (_claimedChallenges.contains(challenge.id)) return;
    if (!isChallengeCompleted(challenge.id)) return;

    _claimedChallenges.add(challenge.id);
    _xp += challenge.xpReward;
    _coins += challenge.coinsReward;
    _savePreferences();
    notifyListeners();
  }

  void recordQuizResult({
    required int correctCount,
    required int totalCount,
    required int earnedXp,
    required int earnedCoins,
  }) {
    _completedQuizzes += 1;
    _correctAnswers += correctCount;
    _totalAnswers += totalCount;

    final multiplier = currentRank.bonusMultiplier;
    final finalXp = (earnedXp * multiplier).round();
    final finalCoins = (earnedCoins * multiplier).round();

    _xp += finalXp;
    _coins += finalCoins;

    // Increment challenge progress
    _challengeProgress['dc_1'] = (_challengeProgress['dc_1'] ?? 0) + 1;
    if (correctCount >= 5) {
      _challengeProgress['dc_2'] = (_challengeProgress['dc_2'] ?? 0) + correctCount;
    }

    _savePreferences();
    notifyListeners();
  }

  void recordWordSolved({
    required int earnedXp,
    required int earnedCoins,
  }) {
    final multiplier = currentRank.bonusMultiplier;
    _xp += (earnedXp * multiplier).round();
    _coins += (earnedCoins * multiplier).round();

    _challengeProgress['dc_3'] = (_challengeProgress['dc_3'] ?? 0) + 1;

    _savePreferences();
    notifyListeners();
  }

  void recordFactAnswered({
    required bool correct,
    required int earnedXp,
    required int earnedCoins,
  }) {
    _totalAnswers += 1;
    if (correct) {
      _correctAnswers += 1;
      _xp += earnedXp;
      _coins += earnedCoins;
      _challengeProgress['dc_4'] = (_challengeProgress['dc_4'] ?? 0) + 1;
    }
    _savePreferences();
    notifyListeners();
  }

  void resetProgressForDebug() {
    _xp = 180;
    _coins = 450;
    _completedQuizzes = 2;
    _correctAnswers = 9;
    _totalAnswers = 12;
    _streakDays = 3;
    _dailyBonusClaimed = false;
    _unlockedRewards.clear();
    _unlockedRewards.add('rw_4');
    _claimedChallenges.clear();
    _challengeProgress.clear();
    _challengeProgress.addAll({
      'dc_1': 1,
      'dc_2': 3,
      'dc_3': 1,
      'dc_4': 2,
    });
    _savePreferences();
    notifyListeners();
  }
}
