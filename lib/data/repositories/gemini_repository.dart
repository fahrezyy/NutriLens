import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants.dart';

class GeminiRepository {
  late final GenerativeModel _model;

  GeminiRepository() {
    _model = GenerativeModel(
      model:  AppConstants.GEMINI_MODEL,
      apiKey: AppConstants.GEMINI_API_KEY,
    );
  }

  /// Calls Gemini with the exact nutrition prompt.
  ///
  /// [menuList]     – e.g. ['nasi', 'ayam goreng (×2)', 'bakso']
  /// [calories]     – total calories
  /// [protein]      – total protein in grams
  /// [fat]          – total fat in grams
  /// [carbs]        – total carbohydrate in grams
  Future<String> generateNutritionAdvice({
    required List<String> menuList,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
  }) async {
    final semua_menu = menuList.join(', ');

    final prompt = '''Anda adalah ahli gizi digital. User memakan: $semua_menu.
        Total Nutrisi: Kalori ${calories.toStringAsFixed(1)}kkal, Protein ${protein.toStringAsFixed(1)}g,
        Lemak ${fat.toStringAsFixed(1)}g, Karbo ${carbs.toStringAsFixed(1)}g.
        Berikan penjelasan apakah kombinasi ini seimbang dan berikan satu saran singkat untuk mahasiswa UNISSULA.
        jangan gunakan kata analisis''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Tidak ada respons dari AI.';
  }
}
