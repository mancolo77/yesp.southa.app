import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_models.dart';

class QuizDataService {
  static QuizDataBundle? _cachedBundle;

  static Future<QuizDataBundle> loadQuizData() async {
    if (_cachedBundle != null) {
      return _cachedBundle!;
    }

    String jsonString = '';
    try {
      jsonString = await rootBundle.loadString('assets/quiz_data.json');
    } catch (_) {
      try {
        jsonString = await rootBundle.loadString('assets/words.json');
      } catch (e) {
        throw Exception('Failed to load quiz asset files: $e');
      }
    }

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    _cachedBundle = QuizDataBundle.fromJson(jsonMap);
    return _cachedBundle!;
  }

  static void clearCache() {
    _cachedBundle = null;
  }
}
