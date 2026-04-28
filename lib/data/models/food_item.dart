class FoodItem {
  final int    id;
  final String name;
  final double calories;
  final double proteins;
  final double fat;
  final double carbohydrate;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fat,
    required this.carbohydrate,
  });

  factory FoodItem.fromCsvRow(List<dynamic> row) {
    return FoodItem(
      id:           int.parse(row[0].toString().trim()),
      calories:     double.parse(row[1].toString().trim()),
      proteins:     double.parse(row[2].toString().trim()),
      fat:          double.parse(row[3].toString().trim()),
      carbohydrate: double.parse(row[4].toString().trim()),
      name:         row[5].toString().trim().toLowerCase(),
    );
  }

  FoodItem operator *(int multiplier) => FoodItem(
    id:           id,
    name:         name,
    calories:     calories * multiplier,
    proteins:     proteins * multiplier,
    fat:          fat * multiplier,
    carbohydrate: carbohydrate * multiplier,
  );
}
