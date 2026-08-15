import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Prediction {
  final String label;
  final double confidence;

  Prediction({
    required this.label,
    required this.confidence,
  });
}

class AslClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  bool _initialized = false;

  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/asl_model.tflite',
    );

    final labelsData = await rootBundle.loadString(
      'assets/models/labels.txt',
    );

    _labels = labelsData
        .split('\n')
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList();

    print('LABELS: $_labels');

    _initialized = true;

    print('ASL model loaded successfully');
    print('Labels: ${_labels.length}');
    print(
      'Input shape: '
          '${_interpreter.getInputTensor(0).shape}',
    );
    print(
      'Output shape: '
          '${_interpreter.getOutputTensor(0).shape}',
    );
  }

  Prediction predict(List<double> landmarks) {
    if (!_initialized) {
      throw Exception(
        'ASL model is not initialized',
      );
    }

    if (landmarks.length != 63) {
      throw Exception(
        'Expected 63 landmarks, '
            'got ${landmarks.length}',
      );
    }

    final input = [
      landmarks,
    ];

    final outputTensor =
    _interpreter.getOutputTensor(0);

    final outputSize =
        outputTensor.shape.last;

    final output = [
      List<double>.filled(
        outputSize,
        0.0,
      ),
    ];

    _interpreter.run(
      input,
      output,
    );

    print('MODEL OUTPUT: ${output[0]}');

    int bestIndex = 0;
    double bestScore = output[0][0];

    for (int i = 1;
    i < output[0].length;
    i++) {
      if (output[0][i] > bestScore) {
        bestScore = output[0][i];
        bestIndex = i;
      }
    }

    String label = '?';

    if (bestIndex < _labels.length) {
      label = _labels[bestIndex];
    }

    return Prediction(
      label: label,
      confidence: bestScore,
    );
  }

  void close() {
    if (_initialized) {
      _interpreter.close();
      _initialized = false;
    }
  }
}