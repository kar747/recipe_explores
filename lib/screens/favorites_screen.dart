
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';
import '../services/favorites_storage.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesStorage storage = FavoritesStorage();
  final MealApi api = MealApi();

  List<Meal> meals = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() {
      loading = true;
    });

    final ids = await storage.getFavorites();
    final List<Meal> savedMeals = [];

    for (final id in ids) {
      try {
        final meal = await api.getMealDetails(id);
        savedMeals.add(meal);
      } catch (e) {
        // Skip recipes that cannot be loaded
      }
    }

    if (mounted) {
      setState(() {
        meals = savedMeals;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites ❤️'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : meals.isEmpty
              ? const Center(
                  child: Text(
                    'No favorite recipes yet!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: meals.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final meal = meals[index];

                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealDetailScreen(
                              mealId: meal.id,
                            ),
                          ),
                        );

                        loadFavorites();
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                meal.image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                meal.name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
