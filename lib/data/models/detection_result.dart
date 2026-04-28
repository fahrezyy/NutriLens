import 'dart:ui';

class DetectionResult {
  final String label;
  final double confidence;
  /// Normalized rect [0..1] in original image coordinates
  final Rect   rect;

  const DetectionResult({
    required this.label,
    required this.confidence,
    required this.rect,
  });

  @override
  String toString() =>
      'DetectionResult(label: $label, conf: ${confidence.toStringAsFixed(2)}, rect: $rect)';
}
