import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_api.dart';
import 'meal_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MealApi api = MealApi();
  final TextEditingController controller = TextEditingController();

  List<Meal> meals = [];
  bool loading = false;
  bool searched = false;

  @override
  void initState() {
    super.initState();

    controller.text = widget.initialQuery;

    if (widget.initialQuery.isNotEmpty) {
      search(widget.initialQuery);
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        meals = [];
        searched = false;
      });
      return;
    }

    setState(() {
      loading = true;
      searched = true;
    });

    try {
      meals = await api.searchMeals(query.trim());
    } catch (e) {
      meals = [];
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              onSubmitted: search,
              decoration: InputDecoration(
                hintText: 'Enter a meal name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    search('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (loading)
            const CircularProgressIndicator()
          else if (!searched)
            const Text('Search for your favorite meals')
          else if (meals.isEmpty)
            const Text('No meals found. Try another search.')
          else
            Expanded(
              child: GridView.builder(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MealDetailScreen(
                            mealId: meal.id,
                          ),
                        ),
                      );
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}