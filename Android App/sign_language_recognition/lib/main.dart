import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'asl_classifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep the app in portrait mode.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final cameras = await availableCameras();

  runApp(
    MyApp(cameras: cameras),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Language Recognition',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      home: WelcomePage(cameras: cameras),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

const Color turquoise = Color(0xFF32C7C5);
const Color darkPanel = Color(0xFF20292B);
const Color lightText = Color(0xFFE8E8E8);
const Color mutedText = Color(0xFF9A9A9A);

// ============================================================
// WELCOME PAGE
// ============================================================

class WelcomePage extends StatelessWidget {
  final List<CameraDescription> cameras;

  const WelcomePage({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.055,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.055,
                  ),

                  // ------------------------------------------------
                  // HAND IMAGE
                  // ------------------------------------------------

                  SizedBox(
                    height: size.height * 0.23,
                    width: size.width * 0.55,
                    child: Image.asset(
                      'assets/images/download-removebg-preview.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.025,
                  ),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  Text(
                    'Sign Language',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: lightText,
                      fontSize: size.width * 0.075,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),

                  Text(
                    'Recognition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: turquoise,
                      fontSize: size.width * 0.075,
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.045,
                  ),

                  // ------------------------------------------------
                  // DECORATIVE LINES
                  // ------------------------------------------------

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.32,
                        height: 1,
                        color: turquoise,
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.pan_tool_outlined,
                        color: turquoise,
                        size: 18,
                      ),
                      const SizedBox(width: 18),
                      Container(
                        width: size.width * 0.32,
                        height: 1,
                        color: turquoise,
                      ),
                    ],
                  ),

                  SizedBox(
                    height: size.height * 0.035,
                  ),

                  // ------------------------------------------------
                  // DESCRIPTION
                  // ------------------------------------------------

                  Text(
                    'Real-Time Hand Gesture Detection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: size.width * 0.031,
                      letterSpacing: 0.5,
                    ),
                  ),

                  Text(
                    'Powered by Computer Vision',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: size.width * 0.031,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.035,
                  ),

                  // ------------------------------------------------
                  // TECHNOLOGY LABELS
                  // ------------------------------------------------

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _techLabel('REAL-TIME'),
                      const SizedBox(width: 25),
                      _techLabel('AI-POWERED'),
                      const SizedBox(width: 25),
                      _techLabel('ON-DEVICE'),
                    ],
                  ),

                  SizedBox(
                    height: size.height * 0.065,
                  ),

                  // ------------------------------------------------
                  // START BUTTON
                  // ------------------------------------------------

                  SizedBox(
                    width: size.width * 0.43,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraPage(
                              cameras: cameras,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: turquoise,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'START',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '→',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.height * 0.045,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _techLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: turquoise,
        fontSize: 8,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.7,
      ),
    );
  }
}

// ============================================================
// CAMERA / RECOGNITION PAGE
// ============================================================

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  static const MethodChannel _channel =
  MethodChannel('mediapipe_hand');

  // ----------------------------------------------------------
  // TFLite ASL classifier
  // ----------------------------------------------------------

  final AslClassifier _classifier = AslClassifier();

  late CameraController _controller;

  bool _cameraReady = false;
  bool _streaming = false;
  bool _mediapipeReady = false;
  bool _processing = false;
  bool _modelReady = false;

  int _frameCount = 0;
  int _processedFrames = 0;

  List<double>? _landmarks;

  String _prediction = '-';
  double _confidence = 0.0;

  // ==========================================================
  // NEW: RECOGNIZED TEXT LOGIC
  // ==========================================================

  String _recognizedText = '';

  String? _candidateLetter;

  DateTime? _candidateStartTime;

  DateTime? _lastPredictionTime;

  // ==========================================================
  // INITIALIZATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // --------------------------------------------------------
      // CAMERA
      // --------------------------------------------------------

      _controller = CameraController(
        widget.cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller.initialize();

      if (!mounted) return;

      setState(() {
        _cameraReady = true;
      });

      // --------------------------------------------------------
      // MEDIAPIPE
      // --------------------------------------------------------

      final result = await _channel.invokeMethod(
        'initializeHandLandmarker',
      );

      debugPrint(result.toString());

      if (!mounted) return;

      setState(() {
        _mediapipeReady = true;
      });

      // --------------------------------------------------------
      // ASL MODEL
      // --------------------------------------------------------

      await _classifier.initialize();

      if (!mounted) return;

      setState(() {
        _modelReady = true;
      });

      debugPrint(
        'ASL TFLite model initialized successfully',
      );

      // --------------------------------------------------------
      // START DETECTION AUTOMATICALLY
      // --------------------------------------------------------

      await _startStream();
    } catch (e) {
      debugPrint(
        'Initialization error: $e',
      );
    }
  }

  // ==========================================================
  // START CAMERA STREAM
  // ==========================================================

  Future<void> _startStream() async {
    if (!_cameraReady ||
        !_mediapipeReady ||
        !_modelReady ||
        _streaming) {
      return;
    }

    await _controller.startImageStream(
          (CameraImage image) {
        _frameCount++;

        // Process approximately every 3rd frame.
        if (_frameCount % 3 != 0) {
          return;
        }

        if (_processing) {
          return;
        }

        _processFrame(image);
      },
    );

    if (!mounted) return;

    setState(() {
      _streaming = true;
    });
  }

  // ==========================================================
  // PROCESS CAMERA FRAME
  // ==========================================================

  Future<void> _processFrame(
      CameraImage image,
      ) async {
    _processing = true;

    try {
      // --------------------------------------------------------
      // CONVERT CAMERA FRAME
      // --------------------------------------------------------

      final bytes = _convertYuv420ToNv21(image);

      // --------------------------------------------------------
      // SEND FRAME TO MEDIAPIPE
      // --------------------------------------------------------

      await _channel.invokeMethod(
        'processCameraFrame',
        {
          'bytes': bytes,
          'width': image.width,
          'height': image.height,
          'timestamp':
          DateTime.now().millisecondsSinceEpoch,
        },
      );

      _processedFrames++;

      // --------------------------------------------------------
      // GET LANDMARKS
      // --------------------------------------------------------

      final landmarks =
      await _channel.invokeMethod(
        'getHandLandmarks',
      );

      if (landmarks != null) {
        final List<dynamic> values =
        List<dynamic>.from(landmarks);

        // 21 landmarks × 3 = 63
        if (values.length == 63) {
          final landmarkValues = values
              .map(
                (e) => (e as num).toDouble(),
          )
              .toList();

// Rotate landmarks 90° counter clockwise
          for (int i = 0; i < 21; i++) {
            final int index = i * 3;

            final double x = landmarkValues[index];
            final double y = landmarkValues[index + 1];

            landmarkValues[index] = 1.0 - y;
            landmarkValues[index + 1] = x;
          }

// ----------------------------------------------------
// MODEL PREDICTION
// ----------------------------------------------------

          final prediction =
          _classifier.predict(landmarkValues);

          if (!mounted) return;

          setState(() {
            _landmarks = landmarkValues;
            _prediction = prediction.label;
            _confidence = prediction.confidence;
          });

          // ----------------------------------------------------
          // NEW: STABLE LETTER RECOGNITION
          // ----------------------------------------------------

          _processRecognition(prediction.label);
        }
      } else {
        if (!mounted) return;

        setState(() {
          _landmarks = null;
        });

      }
    } catch (e) {
      debugPrint(
        'Frame processing error: $e',
      );
    } finally {
      _processing = false;
    }
  }

  // ==========================================================
  // NEW: ONE-SECOND LETTER RECOGNITION
  // ==========================================================

  void _processRecognition(String letter) {
    final now = DateTime.now();

    // --------------------------------------------------------
    // NEW LETTER / DIFFERENT PREDICTION
    // --------------------------------------------------------

    if (_candidateLetter != letter) {
      _candidateLetter = letter;
      _candidateStartTime = now;

      return;
    }

    // --------------------------------------------------------
    // SAFETY CHECK
    // --------------------------------------------------------

    if (_candidateStartTime == null) {
      _candidateStartTime = now;
      return;
    }

    // --------------------------------------------------------
    // HOW LONG HAS THIS SAME LETTER BEEN DETECTED?
    // --------------------------------------------------------

    final duration =
    now.difference(_candidateStartTime!);

    // --------------------------------------------------------
    // ONLY ACCEPT AFTER FULL 1 SECOND
    // --------------------------------------------------------

    if (duration.inMilliseconds >= 1000) {
      if (!mounted) return;

      setState(() {
        _recognizedText += letter;
      });

      // IMPORTANT:
      // Restart the 1-second timer.
      //
      // This allows:
      // A → A → A → A
      // to become:
      // AAAA
      //
      // while still requiring 1 full second
      // for every character.
      _candidateStartTime = now;
    }
  }

  // ==========================================================
  // YUV420 → NV21
  // ==========================================================

  Uint8List _convertYuv420ToNv21(
      CameraImage image,
      ) {
    final int width = image.width;
    final int height = image.height;

    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;

    final Uint8List nv21 =
    Uint8List(ySize + uvSize);

    int offset = 0;

    // Y plane
    for (int row = 0; row < height; row++) {
      final int rowStart =
          row * yPlane.bytesPerRow;

      for (int col = 0; col < width; col++) {
        nv21[offset++] =
        yPlane.bytes[rowStart + col];
      }
    }

    // VU planes
    for (int row = 0; row < height ~/ 2; row++) {
      final int uRowStart =
          row * uPlane.bytesPerRow;

      final int vRowStart =
          row * vPlane.bytesPerRow;

      for (int col = 0; col < width ~/ 2; col++) {
        final int uIndex =
            uRowStart +
                col * uPlane.bytesPerPixel!;

        final int vIndex =
            vRowStart +
                col * vPlane.bytesPerPixel!;

        nv21[offset++] =
        vPlane.bytes[vIndex];

        nv21[offset++] =
        uPlane.bytes[uIndex];
      }
    }

    return nv21;
  }

  // ==========================================================
  // STOP STREAM
  // ==========================================================

  Future<void> _stopStream() async {
    if (!_streaming) {
      return;
    }

    await _controller.stopImageStream();

    if (!mounted) return;

    setState(() {
      _streaming = false;
    });
  }

  // ==========================================================
  // CLEAR EVERYTHING
  // ==========================================================

  void _clearPrediction() {
    setState(() {
      _prediction = '-';
      _confidence = 0.0;
      _recognizedText = '';
    });

    _lastPredictionTime = null;
  }

  // ==========================================================
  // BACKSPACE
  // ==========================================================

  void _backspace() {
    if (_recognizedText.isEmpty) {
      return;
    }

    setState(() {
      _recognizedText =
          _recognizedText.substring(
            0,
            _recognizedText.length - 1,
          );
    });

    _lastPredictionTime = null;
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _controller.dispose();

    _classifier.close();

    super.dispose();
  }

  // ==========================================================
  // RECOGNITION UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (!_cameraReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: turquoise,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.055,
          ),
          child: Column(
            children: [

              // ------------------------------------------------
              // TOP BAR
              // ------------------------------------------------

              SizedBox(
                height: size.height * 0.055,
              ),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  // BACK
                  GestureDetector(
                    onTap: () async {
                      await _stopStream();

                      if (!mounted) return;

                      Navigator.pop(context);
                    },
                    child: Row(
                      children: const [
                        Text(
                          '‹',
                          style: TextStyle(
                            color: turquoise,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'BACK',
                          style: TextStyle(
                            color: turquoise,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // LIVE
                  Image.asset(
                    'assets/images/live.png',
                    width: 45,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              SizedBox(
                height: size.height * 0.025,
              ),

              // ------------------------------------------------
              // CAMERA AREA
              // ------------------------------------------------

              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [

                      CameraPreview(
                        _controller,
                      ),

                      // subtle camera border
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: turquoise
                                .withOpacity(0.25),
                            width: 1,
                          ),
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),

                      // Status
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.55),
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration:
                                const BoxDecoration(
                                  color: turquoise,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _landmarks != null
                                    ? 'HAND DETECTED'
                                    : 'WAITING...',
                                style:
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: size.height * 0.025,
              ),

              // ------------------------------------------------
              // RECOGNIZED TEXT LABEL
              // ------------------------------------------------

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RECOGNIZED TEXT...',
                  style: TextStyle(
                    color: turquoise,
                    fontSize: size.width * 0.032,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // TEXT OUTPUT BOX
              // ------------------------------------------------

            Expanded(
              flex: 3,
              child: GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _recognizedText += ' ';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: darkPanel,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: _recognizedText.isEmpty
                          ? Text(
                        'Waiting for sign...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.28),
                          fontSize: 12,
                        ),
                      )
                          : Text(
                        _recognizedText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

              SizedBox(
                height: size.height * 0.018,
              ),

              // ------------------------------------------------
              // BOTTOM CONTROLS
              // ------------------------------------------------

              Row(
                children: [

                  // CLEAR
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        onPressed:
                        _clearPrediction,
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor: turquoise,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              '×',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'CLEAR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // BACKSPACE
                  SizedBox(
                    width: 43,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _backspace,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor: turquoise,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/backspace.png',
                        width: 18,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: size.height * 0.025,
              ),
            ],
          ),
        ),
      ),
    );
  }
}