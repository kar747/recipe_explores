import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String key = 'favorite_meals';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? [];
  }

  Future<void> addFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(key) ?? [];

    if (!favorites.contains(mealId)) {
      favorites.add(mealId);
      await prefs.setStringList(key, favorites);
    }
  }

  Future<void> removeFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(key) ?? [];

    favorites.remove(mealId);
    await prefs.setStringList(key, favorites);
  }

  Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavorites();
    return favorites.contains(mealId);
  }
}