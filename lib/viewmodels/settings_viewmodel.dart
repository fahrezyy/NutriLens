import 'package:flutter/foundation.dart';

/// ViewModel for user-adjustable detection thresholds.
class SettingsViewModel extends ChangeNotifier {
  // ── Confidence Threshold (default 50%) ───────────────────────────────────
  double _confidenceThreshold = 0.50;
  double get confidenceThreshold => _confidenceThreshold;
  set confidenceThreshold(double v) {
    _confidenceThreshold = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  // ── Overlap / IoU Threshold (default 0%) ─────────────────────────────────
  double _overlapThreshold = 0.0;
  double get overlapThreshold => _overlapThreshold;
  set overlapThreshold(double v) {
    _overlapThreshold = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  // ── Opacity Threshold for bounding box overlay (default 50%) ─────────────
  double _opacityThreshold = 0.50;
  double get opacityThreshold => _opacityThreshold;
  set opacityThreshold(double v) {
    _opacityThreshold = v.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Reset all settings to defaults.
  void resetDefaults() {
    _confidenceThreshold = 0.50;
    _overlapThreshold    = 0.0;
    _opacityThreshold    = 0.50;
    notifyListeners();
  }
}
