import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class RecipeHistoryService {
  static const _key = 'recipe_view_history';
  static const _maxItems = 10;

  static Future<void> addView(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final entry = jsonEncode({
      'recipeId': recipe.recipeId,
      'title': recipe.title,
      'youtubeUrl': recipe.youtubeUrl,
      'youtubeTitle': recipe.youtubeTitle,
      'isSaved': recipe.isSaved,
      'createdAt': recipe.createdAt,
      'viewedAt': DateTime.now().toIso8601String(),
    });

    // 중복 제거 후 맨 앞에 추가, 최대 10개 유지
    final filtered = raw.where((e) {
      try {
        return jsonDecode(e)['recipeId'] != recipe.recipeId;
      } catch (_) {
        return false;
      }
    }).toList();

    filtered.insert(0, entry);
    if (filtered.length > _maxItems) filtered.removeRange(_maxItems, filtered.length);

    await prefs.setStringList(_key, filtered);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) {
      try {
        return Map<String, dynamic>.from(jsonDecode(e));
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((e) => e.isNotEmpty).toList();
  }
}
