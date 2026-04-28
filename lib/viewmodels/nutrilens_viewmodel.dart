import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/nutrition_summary.dart';
import '../data/repositories/detection_repository.dart';
import '../data/repositories/nutrition_repository.dart';
import '../data/repositories/gemini_repository.dart';

enum AnalysisState { idle, detecting, fetchingNutrition, generatingAdvice, done, error }

class NutriLensViewModel extends ChangeNotifier {
  final _detectionRepo  = DetectionRepository();
  final _nutritionRepo  = NutritionRepository();
  final _geminiRepo     = GeminiRepository();
  final _picker         = ImagePicker();

  // ── State ────────────────────────────────────────────────────────────────
  AnalysisState _state = AnalysisState.idle;
  AnalysisState get state => _state;

  File?             _capturedImage;
  File? get capturedImage => _capturedImage;

  NutritionSummary? _result;
  NutritionSummary? get result => _result;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _statusMessage = '';
  String get statusMessage => _statusMessage;

  bool get isProcessing =>
      _state == AnalysisState.detecting ||
      _state == AnalysisState.fetchingNutrition ||
      _state == AnalysisState.generatingAdvice;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Opens the camera and runs the full analysis pipeline.
  Future<void> captureAndAnalyze() async {
    final XFile? picked = await _picker.pickImage(
      source:       ImageSource.camera,
      imageQuality: 90,
    );
    if (picked == null) return; // user cancelled

    await analyzePhoto(File(picked.path));
  }

  /// Accepts an existing [imageFile] and runs the pipeline.
  Future<void> analyzePhoto(File imageFile) async {
    _capturedImage = imageFile;
    _result        = null;
    _errorMessage  = null;
    _setState(AnalysisState.detecting, '🔍 Mendeteksi makanan…');

    try {
      // ── Step 1: YOLO detection ──────────────────────────────────────────
      final detections = await _detectionRepo.detect(imageFile);

      if (detections.isEmpty) {
        _setState(AnalysisState.done, '');
        _result = NutritionSummary(
          detections:     [],
          foodCounts:     {},
          totalCalories:  0,
          totalProtein:   0,
          totalFat:       0,
          totalCarbs:     0,
          resolvedFoods:  [],
          geminiAnalysis: 'Tidak ada makanan yang terdeteksi dalam foto.',
        );
        notifyListeners();
        return;
      }

      // ── Step 2: Count food occurrences ──────────────────────────────────
      final foodCounts = <String, int>{};
      for (final d in detections) {
        foodCounts[d.label] = (foodCounts[d.label] ?? 0) + 1;
      }

      _setState(AnalysisState.fetchingNutrition, '📊 Menghitung nutrisi…');

      // ── Step 3: Lookup nutrition CSV ────────────────────────────────────
      final totals = await _nutritionRepo.computeTotals(foodCounts);

      _setState(AnalysisState.generatingAdvice, '🤖 Meminta saran dari AI…');

      // ── Step 4: Build menu list with multipliers ─────────────────────────
      final menuList = foodCounts.entries
          .map((e) => e.value > 1 ? '${e.key} (×${e.value})' : e.key)
          .toList();

      // ── Step 5: Gemini API ───────────────────────────────────────────────
      final geminiText = await _geminiRepo.generateNutritionAdvice(
        menuList: menuList,
        calories: totals.totalCalories,
        protein:  totals.totalProtein,
        fat:      totals.totalFat,
        carbs:    totals.totalCarbs,
      );

      // ── Step 6: Assemble result ──────────────────────────────────────────
      _result = NutritionSummary(
        detections:    detections,
        foodCounts:    foodCounts,
        totalCalories: totals.totalCalories,
        totalProtein:  totals.totalProtein,
        totalFat:      totals.totalFat,
        totalCarbs:    totals.totalCarbs,
        resolvedFoods: totals.resolvedFoods,
        geminiAnalysis: geminiText,
      );

      _setState(AnalysisState.done, '');
    } catch (e) {
      debugPrint('NutriLensViewModel error: $e');
      _errorMessage = e.toString();
      _setState(AnalysisState.error, '');
    }
  }

  void reset() {
    _capturedImage = null;
    _result        = null;
    _errorMessage  = null;
    _setState(AnalysisState.idle, '');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setState(AnalysisState s, String msg) {
    _state         = s;
    _statusMessage = msg;
    notifyListeners();
  }
}
