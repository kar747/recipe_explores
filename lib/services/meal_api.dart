import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal.dart';

class MealApi {
  static const String baseUrl =
      'https://www.themealdb.com/api/json/v1/1';

  // Get all categories
  Future<List<Category>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List categories = data['categories'];

      return categories.map((item) => Category.fromJson(item)).toList();
    }

    throw Exception('Failed to load categories');
  }

  // Get meals by category
  Future<List<Meal>> getMealsByCategory(String category) async {
    final url = Uri.parse('$baseUrl/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List meals = data['meals'] ?? [];

      return meals.map((item) => Meal.fromJson(item)).toList();
    }

    throw Exception('Failed to load meals');
  }

  // Search meals by name
  Future<List<Meal>> searchMeals(String name) async {
    final url = Uri.https(
      'www.themealdb.com',
      '/api/json/v1/1/search.php',
      {'s': name},
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List meals = data['meals'] ?? [];

      return meals.map((item) => Meal.fromJson(item)).toList();
    }

    throw Exception('Failed to search meals');
  }

  // Get complete meal details
  Future<Meal> getMealDetails(String mealId) async {
    final url = Uri.parse('$baseUrl/lookup.php?i=$mealId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final meals = data['meals'];

      if (meals == null || meals.isEmpty) {
        throw Exception('Recipe not found');
      }

      return Meal.fromJson(meals[0]);
    }

    throw Exception('Failed to load recipe details');
  }
}