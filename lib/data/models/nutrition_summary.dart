import 'food_item.dart';
import 'detection_result.dart';

class NutritionSummary {
  final List<DetectionResult> detections;

  /// e.g. {'nasi': 2, 'ayam goreng': 1}
  final Map<String, int> foodCounts;

  /// Aggregated nutrition totals
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;

  /// Resolved food items (after CSV lookup)
  final List<FoodItem> resolvedFoods;

  /// Gemini narrative text
  final String geminiAnalysis;

  const NutritionSummary({
    required this.detections,
    required this.foodCounts,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
    required this.resolvedFoods,
    required this.geminiAnalysis,
  });

  /// Comma-separated unique food names for display
  String get menuText => foodCounts.entries
      .map((e) => e.value > 1 ? '${e.key} (×${e.value})' : e.key)
      .join(', ');
}
