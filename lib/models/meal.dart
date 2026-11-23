class Meal {
  final String id;
  final String name;
  final String image;
  final String category;
  final String area;
  final String instructions;
  final List<String> ingredients;
  final List<String> measures;

  Meal({
    required this.id,
    required this.name,
    required this.image,
    this.category = '',
    this.area = '',
    this.instructions = '',
    this.ingredients = const [],
    this.measures = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measures.add(measure?.toString().trim() ?? '');
      }
    }

    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '',
      image: json['strMealThumb']?.toString() ?? '',
      category: json['strCategory']?.toString() ?? '',
      area: json['strArea']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      ingredients: ingredients,
      measures: measures,
    );
  }
}