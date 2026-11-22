import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';

class MealListScreen extends StatefulWidget {
  final String category;

  const MealListScreen({
    super.key,
    required this.category,
  });

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  final MealApi mealApi = MealApi();

  late Future<List<Meal>> mealsFuture;

  @override
  void initState() {
    super.initState();
    mealsFuture = mealApi.getMealsByCategory(widget.category);
  }

  Widget mealCard(Meal meal) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              meal.image,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.restaurant, size: 50),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              meal.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Meal>>(
        future: mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load recipes'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        mealsFuture =
                            mealApi.getMealsByCategory(widget.category);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final meals = snapshot.data ?? [];

          if (meals.isEmpty) {
            return const Center(
              child: Text('No recipes found'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: meals.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              return mealCard(meals[index]);
            },
          );
        },
      ),
    );
  }
}