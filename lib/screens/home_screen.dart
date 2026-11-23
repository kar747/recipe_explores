
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/meal_api.dart';
import 'meal_list_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MealApi mealApi = MealApi();
  late Future<List<Category>> categoriesFuture;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    categoriesFuture = mealApi.getCategories();
  }

  Widget categoryCard(Category category) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MealListScreen(category: category.name),
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Image.network(
              category.image,
              height: 110,
              width: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.restaurant, size: 50),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void searchRecipe(String query) {
    if (query.trim().isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchScreen(initialQuery: query.trim()),
      ),
    );
  }

  Widget homeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discover Delicious Food',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find your favorite recipes',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            onSubmitted: searchRecipe,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Categories',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          FutureBuilder<List<Category>>(
            future: categoriesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Column(
                  children: [
                    const Text('Failed to load categories'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          categoriesFuture = mealApi.getCategories();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return const Center(child: Text('No categories found'));
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories.map(categoryCard).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Explorer'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: selectedIndex == 0
          ? homeContent()
          : selectedIndex == 1
              ? const SearchScreen()
              : const FavoritesScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.orange,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
