
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';
import '../services/favorites_storage.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApi mealApi = MealApi();
  final FavoritesStorage favoritesStorage = FavoritesStorage();

  late Future<Meal> mealFuture;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    mealFuture = mealApi.getMealDetails(widget.mealId);
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final saved = await favoritesStorage.isFavorite(widget.mealId);
    if (mounted) {
      setState(() {
        isFavorite = saved;
      });
    }
  }

  Future<void> toggleFavorite() async {
    if (isFavorite) {
      await favoritesStorage.removeFavorite(widget.mealId);
    } else {
      await favoritesStorage.addFavorite(widget.mealId);
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Meal>(
        future: mealFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load recipe'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        mealFuture =
                            mealApi.getMealDetails(widget.mealId);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final meal = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  meal.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: toggleFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Text('Category: ${meal.category}'),
                Text('Area: ${meal.area}'),
                const SizedBox(height: 20),
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(meal.ingredients.length, (index) {
                  final ingredient = meal.ingredients[index];
                  final measure = meal.measures[index];

                  return Text(
                    measure.isEmpty ? ingredient : '$measure $ingredient',
                  );
                }),
                const SizedBox(height: 20),
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(meal.instructions),
              ],
            ),
          );
        },
      ),
    );
  }
}
