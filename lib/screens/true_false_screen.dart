import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../providers/loyalty_provider.dart';
import '../theme/app_theme.dart';

class TrueFalseScreen extends StatefulWidget {
  final List<TrueFalseFact> facts;

  const TrueFalseScreen({super.key, required this.facts});

  @override
  State<TrueFalseScreen> createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  int _currentIndex = 0;
  bool? _userAnswer;
  bool _isAnswered = false;
  int _score = 0;
  int _correctCount = 0;

  TrueFalseFact get _currentFact => widget.facts[_currentIndex];

  void _handleAnswer(bool answer) {
    if (_isAnswered) return;

    final fact = _currentFact;
    final isCorrect = answer == fact.isTrue;

    setState(() {
      _userAnswer = answer;
      _isAnswered = true;
      if (isCorrect) {
        _score += fact.points;
        _correctCount += 1;
      }
    });

    final earnedCoins = (fact.points * 0.7).round();
    context.read<LoyaltyProvider>().recordFactAnswered(
          correct: isCorrect,
          earnedXp: isCorrect ? fact.points : 0,
          earnedCoins: isCorrect ? earnedCoins : 0,
        );
  }

  void _nextFact() {
    if (_currentIndex < widget.facts.length - 1) {
      setState(() {
        _currentIndex += 1;
        _userAnswer = null;
        _isAnswered = false;
      });
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceCard,
          content: Text(
            '🏆 Викторина «Правда или Миф» пройдена! Верно: $_correctCount из ${widget.facts.length}',
            style: GoogleFonts.inter(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.facts.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Правда или Миф')),
        body: const Center(child: Text('Нет доступных фактов')),
      );
    }

    final fact = _currentFact;
    final progress = (_currentIndex + 1) / widget.facts.length;
    final isCorrect = _userAnswer == fact.isTrue;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Правда или Миф РПЛ',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Факт ${_currentIndex + 1} из ${widget.facts.length}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_score XP',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.surfaceCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              // Fact Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_soccer_rounded,
                        color: AppTheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      fact.statement,
                      style: GoogleFonts.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '+${fact.points} XP за верный ответ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons True & False
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _isAnswered ? null : () => _handleAnswer(true),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: _isAnswered && fact.isTrue
                              ? AppTheme.accentGreen.withAlpha(40)
                              : (_isAnswered && _userAnswer == true && !fact.isTrue
                                  ? AppTheme.accentRose.withAlpha(40)
                                  : AppTheme.surfaceCard),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isAnswered && fact.isTrue
                                ? AppTheme.accentGreen
                                : (_isAnswered && _userAnswer == true && !fact.isTrue
                                    ? AppTheme.accentRose
                                    : AppTheme.accentGreen.withAlpha(80)),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.accentGreen,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Правда',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: _isAnswered ? null : () => _handleAnswer(false),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: _isAnswered && !fact.isTrue
                              ? AppTheme.accentGreen.withAlpha(40)
                              : (_isAnswered && _userAnswer == false && fact.isTrue
                                  ? AppTheme.accentRose.withAlpha(40)
                                  : AppTheme.surfaceCard),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isAnswered && !fact.isTrue
                                ? AppTheme.accentGreen
                                : (_isAnswered && _userAnswer == false && fact.isTrue
                                    ? AppTheme.accentRose
                                    : AppTheme.accentRose.withAlpha(80)),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.cancel_rounded,
                              color: AppTheme.accentRose,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Миф',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentRose,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Explanation Card when answered
              if (_isAnswered) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isCorrect ? AppTheme.accentGreen : AppTheme.accentRose)
                        .withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCorrect ? AppTheme.accentGreen : AppTheme.accentRose,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.highlight_off_rounded,
                            color:
                                isCorrect ? AppTheme.accentGreen : AppTheme.accentRose,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCorrect ? 'Абсолютно верно!' : 'Ошибка!',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? AppTheme.accentGreen
                                  : AppTheme.accentRose,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fact.explanation,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextFact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentIndex < widget.facts.length - 1
                          ? 'Следующий факт'
                          : 'Завершить викторину',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
