package com.example.sign_language_recognition

import android.graphics.BitmapFactory
import android.graphics.ImageFormat
import android.graphics.YuvImage
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.framework.image.BitmapImageBuilder
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "mediapipe_hand"

    private lateinit var handLandmarkerHelper: HandLandmarkerHelper

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        handLandmarkerHelper = HandLandmarkerHelper(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "initializeHandLandmarker" -> {
                    try {
                        handLandmarkerHelper.setup()

                        result.success(
                            "MediaPipe Hand Landmarker initialized"
                        )

                    } catch (e: Exception) {
                        Log.e(
                            "MediaPipe",
                            "Initialization failed",
                            e
                        )

                        result.error(
                            "MEDIAPIPE_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "processCameraFrame" -> {

                    try {

                        val data =
                            call.argument<ByteArray>("bytes")

                        val width =
                            call.argument<Int>("width")

                        val height =
                            call.argument<Int>("height")

                        val timestamp =
                            call.argument<Long>("timestamp")

                        if (
                            data == null ||
                            width == null ||
                            height == null ||
                            timestamp == null
                        ) {
                            result.error(
                                "INVALID_FRAME",
                                "Camera frame data is incomplete",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val yuvImage = YuvImage(
                            data,
                            ImageFormat.NV21,
                            width,
                            height,
                            null
                        )

                        val outputStream =
                            ByteArrayOutputStream()

                        yuvImage.compressToJpeg(
                            android.graphics.Rect(
                                0,
                                0,
                                width,
                                height
                            ),
                            80,
                            outputStream
                        )

                        val jpegBytes =
                            outputStream.toByteArray()

                        val bitmap =
                            BitmapFactory.decodeByteArray(
                                jpegBytes,
                                0,
                                jpegBytes.size
                            )

                        if (bitmap == null) {
                            result.error(
                                "BITMAP_ERROR",
                                "Could not create bitmap",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val mpImage =
                            BitmapImageBuilder(bitmap)
                                .build()

                        handLandmarkerHelper.processFrame(
                            mpImage,
                            timestamp
                        )

                        result.success(true)

                    } catch (e: Exception) {

                        Log.e(
                            "MediaPipe",
                            "Frame processing failed",
                            e
                        )

                        result.error(
                            "FRAME_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "getHandLandmarks" -> {

                    val landmarks =
                        handLandmarkerHelper
                            .getLatestLandmarks()

                    result.success(landmarks)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {

        if (::handLandmarkerHelper.isInitialized) {
            handLandmarkerHelper.close()
        }

        super.onDestroy()
    }
}