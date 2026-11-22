import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal.dart';

class MealApi {
  static const String baseUrl =
      'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories.php');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List categories = data['categories'];

      return categories.map((item) {
        return Category.fromJson(item);
      }).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Meal>> getMealsByCategory(String category) async {
    final url = Uri.parse('$baseUrl/filter.php?c=$category');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List meals = data['meals'] ?? [];

      return meals.map((item) {
        return Meal.fromJson(item);
      }).toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<Meal>> searchMeals(String name) async {
    final url = Uri.parse('$baseUrl/search.php?s=$name');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List meals = data['meals'] ?? [];

      return meals.map((item) {
        return Meal.fromJson(item);
      }).toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }
}