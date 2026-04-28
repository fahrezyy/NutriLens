import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/food_item.dart';

class NutritionRepository {
  Map<String, FoodItem>? _cache;

  Future<Map<String, FoodItem>> loadNutritionData() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/nutrition.csv');

    // The CSV uses semicolons as delimiter
    final rows = const CsvToListConverter(fieldDelimiter: ';')
        .convert(raw)
        .skip(1) // skip header
        .where((row) => row.length >= 6 && row[0].toString().trim().isNotEmpty)
        .toList();

    _cache = {
      for (final row in rows)
        row[5].toString().trim().toLowerCase(): FoodItem.fromCsvRow(row),
    };
    return _cache!;
  }

  /// Returns a FoodItem matched by name (case-insensitive) or null.
  Future<FoodItem?> findByName(String name) async {
    final data = await loadNutritionData();
    return data[name.toLowerCase()];
  }

  /// Aggregates totals given a map of {foodName: count}.
  Future<NutritionTotals> computeTotals(Map<String, int> foodCounts) async {
    final data = await loadNutritionData();

    double calories = 0, protein = 0, fat = 0, carbs = 0;
    final resolved = <FoodItem>[];

    for (final entry in foodCounts.entries) {
      final item = data[entry.key.toLowerCase()];
      if (item != null) {
        calories += item.calories * entry.value;
        protein  += item.proteins * entry.value;
        fat      += item.fat * entry.value;
        carbs    += item.carbohydrate * entry.value;
        resolved.add(item * entry.value);
      }
    }

    return NutritionTotals(
      calories:      calories,
      protein:       protein,
      fat:           fat,
      carbs:         carbs,
      resolvedFoods: resolved,
    );
  }
}

class NutritionTotals {
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;
  final List<FoodItem> resolvedFoods;

  const NutritionTotals({
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required this.resolvedFoods,
  })  : totalCalories = calories,
        totalProtein  = protein,
        totalFat      = fat,
        totalCarbs    = carbs;
}
