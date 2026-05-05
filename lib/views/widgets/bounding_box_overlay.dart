import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/detection_result.dart';
import '../../core/theme.dart';

/// Displays the captured image with YOLO bounding boxes overlaid.
class BoundingBoxOverlay extends StatelessWidget {
  final File                  imageFile;
  final List<DetectionResult> detections;
  final double                boxOpacity;

  const BoundingBoxOverlay({
    super.key,
    required this.imageFile,
    required this.detections,
    this.boxOpacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image
        Image.file(imageFile, fit: BoxFit.cover),

        // Dark gradient at bottom for readability
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end:   Alignment.bottomCenter,
              colors: [Colors.transparent, AppTheme.surface],
              stops: [0.55, 1.0],
            ),
          ),
        ),

        // Bounding box overlay
        LayoutBuilder(
          builder: (_, constraints) => CustomPaint(
            painter: _BoxPainter(
              detections: detections,
              size:       constraints.biggest,
              boxOpacity: boxOpacity,
            ),
          ),
        ),
      ],
    );
  }
}

class _BoxPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final Size                  size;
  final double                boxOpacity;

  _BoxPainter({
    required this.detections,
    required this.size,
    this.boxOpacity = 1.0,
  });

  static final _colors = [
    AppTheme.primary,
    AppTheme.proteinColor,
    AppTheme.calorieColor,
    AppTheme.carbColor,
    AppTheme.fatColor,
    AppTheme.accent,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < detections.length; i++) {
      final d     = detections[i];
      final color = _colors[i % _colors.length].withValues(alpha: boxOpacity);

      final rect = Rect.fromLTWH(
        d.rect.left   * size.width,
        d.rect.top    * size.height,
        d.rect.width  * size.width,
        d.rect.height * size.height,
      );

      // Semi-transparent fill
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 0.15 * boxOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        fillPaint,
      );

      // Box border
      final boxPaint = Paint()
        ..color       = color
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        boxPaint,
      );

      // Label background
      final label     = '${_capitalize(d.label)} ${(d.confidence * 100).toStringAsFixed(0)}%';
      final textPainter = TextPainter(
        text: TextSpan(
          text:  label,
          style: TextStyle(
              color:      Colors.black.withValues(alpha: boxOpacity),
              fontSize:   11,
              fontWeight: FontWeight.w700,
              background: Paint()..color = color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(rect.left + 4, rect.top + 4),
      );
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  bool shouldRepaint(covariant _BoxPainter old) =>
      old.detections != detections ||
      old.size != size ||
      old.boxOpacity != boxOpacity;
}
