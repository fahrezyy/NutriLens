import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../core/constants.dart';
import '../models/detection_result.dart';

class DetectionRepository {
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    final options = InterpreterOptions()..threads = 2;
    _interpreter = await Interpreter.fromAsset(
      AppConstants.MODEL_PATH,
      options: options,
    );
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
  }

  /// Runs YOLO inference on [imageFile] and returns filtered detections.
  Future<List<DetectionResult>> detect(File imageFile) async {
    await loadModel();
    final interpreter = _interpreter!;

    // ── Load & resize image ──────────────────────────────────────────────────
    final bytes   = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Cannot decode image');

    final resized = img.copyResize(
      decoded,
      width:  AppConstants.INPUT_SIZE,
      height: AppConstants.INPUT_SIZE,
    );

    // ── Build input tensor [1, 640, 640, 3] as Float32 normalised [0..1] ───
    final input = List.generate(
      1,
      (_) => List.generate(
        AppConstants.INPUT_SIZE,
        (y) => List.generate(
          AppConstants.INPUT_SIZE,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    // ── Determine output shape ───────────────────────────────────────────────
    // YOLOv8 TFLite INT8 typically outputs [1, num_classes+4, num_anchors]
    // We'll query the actual output shape from the interpreter.
    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape  = outputTensor.shape; // e.g. [1, 25, 8400]

    // Support two common layouts:
    //   Layout A: [1, num_classes+4, num_anchors]  → YOLOv8 default
    //   Layout B: [1, num_anchors, num_classes+4]  → some exporters
    final int numClasses = AppConstants.LABELS.length;
    bool layoutA = false;
    int numAnchors = 0;

    if (outputShape.length == 3) {
      if (outputShape[1] == numClasses + 4) {
        // Layout A
        layoutA    = true;
        numAnchors = outputShape[2];
      } else {
        // Layout B
        layoutA    = false;
        numAnchors = outputShape[1];
      }
    }

    // Allocate output buffer
    final rawOutput = List.generate(
      outputShape[0],
      (_) => List.generate(
        outputShape[1],
        (_) => List.generate(outputShape[2], (_) => 0.0),
      ),
    );

    // ── Run inference ────────────────────────────────────────────────────────
    interpreter.run(input, rawOutput);

    // ── Parse detections ─────────────────────────────────────────────────────
    final detections = <DetectionResult>[];

    for (int a = 0; a < numAnchors; a++) {
      double cx, cy, w, h;
      List<double> classScores;

      if (layoutA) {
        // [1, numClasses+4, numAnchors]
        cx = rawOutput[0][0][a].toDouble();
        cy = rawOutput[0][1][a].toDouble();
        w  = rawOutput[0][2][a].toDouble();
        h  = rawOutput[0][3][a].toDouble();
        classScores = List.generate(
          numClasses,
          (c) => rawOutput[0][4 + c][a].toDouble(),
        );
      } else {
        // [1, numAnchors, numClasses+4]
        cx = rawOutput[0][a][0].toDouble();
        cy = rawOutput[0][a][1].toDouble();
        w  = rawOutput[0][a][2].toDouble();
        h  = rawOutput[0][a][3].toDouble();
        classScores = List.generate(
          numClasses,
          (c) => rawOutput[0][a][4 + c].toDouble(),
        );
      }

      final maxScore = classScores.reduce(max);
      if (maxScore < AppConstants.CONF_THRESHOLD) continue;

      final classIdx = classScores.indexOf(maxScore);
      final label    = classIdx < AppConstants.LABELS.length
          ? AppConstants.LABELS[classIdx]
          : 'unknown';

      // cx/cy/w/h are in [0..INPUT_SIZE] space — normalise to [0..1]
      final size = AppConstants.INPUT_SIZE.toDouble();
      final left   = (cx - w / 2).clamp(0.0, size) / size;
      final top    = (cy - h / 2).clamp(0.0, size) / size;
      final right  = (cx + w / 2).clamp(0.0, size) / size;
      final bottom = (cy + h / 2).clamp(0.0, size) / size;

      detections.add(DetectionResult(
        label:      label,
        confidence: maxScore,
        rect:       Rect.fromLTRB(left, top, right, bottom),
      ));
    }

    // ── Non-Maximum Suppression ──────────────────────────────────────────────
    return _nms(detections, AppConstants.IOU_THRESHOLD);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<DetectionResult> _nms(
    List<DetectionResult> detections,
    double iouThreshold,
  ) {
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    final kept = <DetectionResult>[];
    final suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      kept.add(detections[i]);
      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        if (_iou(detections[i].rect, detections[j].rect) > iouThreshold) {
          suppressed[j] = true;
        }
      }
    }
    return kept;
  }

  double _iou(Rect a, Rect b) {
    final interLeft   = max(a.left, b.left);
    final interTop    = max(a.top, b.top);
    final interRight  = min(a.right, b.right);
    final interBottom = min(a.bottom, b.bottom);

    final interW = (interRight  - interLeft).clamp(0.0, double.infinity);
    final interH = (interBottom - interTop ).clamp(0.0, double.infinity);
    final inter  = interW * interH;
    if (inter == 0) return 0;

    final union = a.width * a.height + b.width * b.height - inter;
    return inter / union;
  }
}
