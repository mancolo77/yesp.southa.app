import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../providers/loyalty_provider.dart';
import '../theme/app_theme.dart';

class WordPuzzleScreen extends StatefulWidget {
  final List<WordItem> words;

  const WordPuzzleScreen({super.key, required this.words});

  @override
  State<WordPuzzleScreen> createState() => _WordPuzzleScreenState();
}

class _WordPuzzleScreenState extends State<WordPuzzleScreen> {
  int _currentIndex = 0;
  List<String> _currentGuess = [];
  List<String> _letterBank = [];
  List<bool> _letterBankUsed = [];
  bool _isSolved = false;
  int _score = 0;

  WordItem get _currentWordItem => widget.words[_currentIndex];
  String get _targetWord => _currentWordItem.word.toUpperCase();

  @override
  void initState() {
    super.initState();
    _initWord();
  }

  void _initWord() {
    final word = _targetWord;
    _currentGuess = List.filled(word.length, '');

    // Collect target word letters
    final letters = word.split('').toList();

    // Add 4-6 random Russian letters
    const alphabet = 'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЭЮЯ';
    final random = Random();
    while (letters.length < word.length + 4) {
      final randChar = alphabet[random.nextInt(alphabet.length)];
      letters.add(randChar);
    }

    letters.shuffle(random);
    _letterBank = letters;
    _letterBankUsed = List.filled(letters.length, false);
    _isSolved = false;
  }

  void _tapLetterBank(int bankIndex) {
    if (_letterBankUsed[bankIndex] || _isSolved) return;

    // Find first empty slot in guess
    final emptySlot = _currentGuess.indexOf('');
    if (emptySlot == -1) return;

    setState(() {
      _currentGuess[emptySlot] = _letterBank[bankIndex];
      _letterBankUsed[bankIndex] = true;
    });

    _checkSolution();
  }

  void _tapGuessSlot(int slotIndex) {
    if (_isSolved || _currentGuess[slotIndex].isEmpty) return;

    final char = _currentGuess[slotIndex];
    // Find matching letter in bank that was used
    for (int i = 0; i < _letterBank.length; i++) {
      if (_letterBank[i] == char && _letterBankUsed[i]) {
        setState(() {
          _currentGuess[slotIndex] = '';
          _letterBankUsed[i] = false;
        });
        break;
      }
    }
  }

  void _clearGuess() {
    if (_isSolved) return;
    setState(() {
      _currentGuess = List.filled(_targetWord.length, '');
      _letterBankUsed = List.filled(_letterBank.length, false);
    });
  }

  void _checkSolution() {
    final guessStr = _currentGuess.join('');
    if (guessStr == _targetWord) {
      setState(() {
        _isSolved = true;
        _score += _currentWordItem.points;
      });

      final earnedCoins = (_currentWordItem.points * 0.8).round();
      context.read<LoyaltyProvider>().recordWordSolved(
            earnedXp: _currentWordItem.points,
            earnedCoins: earnedCoins,
          );
    }
  }

  void _nextWord() {
    if (_currentIndex < widget.words.length - 1) {
      setState(() {
        _currentIndex += 1;
        _initWord();
      });
    } else {
      // Completed all words
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.surfaceCard,
          content: Text(
            '🏆 Все футбольные слова разгаданы! Набрано $_score очков',
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
    final wordItem = _currentWordItem;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Угадай Слово РПЛ',
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
              // Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Слово ${_currentIndex + 1} из ${widget.words.length}',
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
              const SizedBox(height: 16),

              // Hint Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            wordItem.category,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '+${wordItem.points} XP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      wordItem.hint,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Word Slots
              Center(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(_currentGuess.length, (slotIdx) {
                    final char = _currentGuess[slotIdx];
                    final isFilled = char.isNotEmpty;

                    return GestureDetector(
                      onTap: () => _tapGuessSlot(slotIdx),
                      child: Container(
                        width: 44,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isSolved
                              ? AppTheme.secondary.withAlpha(40)
                              : (isFilled
                                  ? AppTheme.surfaceCard
                                  : AppTheme.surface),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isSolved
                                ? AppTheme.secondary
                                : (isFilled
                                    ? AppTheme.primary
                                    : AppTheme.surfaceBorder),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          char,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _isSolved
                                ? AppTheme.secondary
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Success Message if solved
              if (_isSolved) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.secondary),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.secondary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Отлично! Слово разгадано: $_targetWord',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary,
                              ),
                            ),
                            Text(
                              '+${wordItem.points} XP и баллы начислены в профиль',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentIndex < widget.words.length - 1
                          ? 'Следующее слово'
                          : 'Завершить испытание',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Letter Bank
              if (!_isSolved) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Выберите буквы:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearGuess,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text(
                        'Сбросить',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(_letterBank.length, (bankIdx) {
                      final char = _letterBank[bankIdx];
                      final isUsed = _letterBankUsed[bankIdx];

                      return GestureDetector(
                        onTap: () => _tapLetterBank(bankIdx),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: isUsed ? 0.25 : 1.0,
                          child: Container(
                            width: 44,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isUsed
                                  ? AppTheme.surface
                                  : AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isUsed
                                    ? AppTheme.surfaceBorder
                                    : AppTheme.primary.withAlpha(90),
                              ),
                            ),
                            child: Text(
                              char,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isUsed
                                    ? AppTheme.textMuted
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
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
