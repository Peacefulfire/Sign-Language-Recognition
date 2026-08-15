package com.example.sign_language_recognition

import android.content.Context
import android.util.Log

import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarkerResult

class HandLandmarkerHelper(
    private val context: Context
) {

    private var handLandmarker: HandLandmarker? = null

    private var latestLandmarks: List<Float>? = null

    fun setup() {

        if (handLandmarker != null) {
            return
        }

        try {

            val baseOptions = BaseOptions.builder()
                .setModelAssetPath("hand_landmarker.task")
                .build()

            val options =
                HandLandmarker.HandLandmarkerOptions.builder()
                    .setBaseOptions(baseOptions)
                    .setRunningMode(RunningMode.LIVE_STREAM)
                    .setNumHands(1)
                    .setMinHandDetectionConfidence(0.5f)
                    .setMinHandPresenceConfidence(0.5f)
                    .setMinTrackingConfidence(0.5f)
                    .setResultListener { result, _ ->
                        onResults(result)
                    }
                    .setErrorListener { error ->
                        Log.e(
                            "MediaPipe",
                            "Hand Landmarker error",
                            error
                        )
                    }
                    .build()

            handLandmarker =
                HandLandmarker.createFromOptions(
                    context,
                    options
                )

            Log.d(
                "MediaPipe",
                "Hand Landmarker initialized successfully"
            )

        } catch (e: Exception) {

            Log.e(
                "MediaPipe",
                "Failed to initialize Hand Landmarker",
                e
            )

            throw e
        }
    }

    private fun onResults(
        result: HandLandmarkerResult
    ) {

        if (result.landmarks().isEmpty()) {

            latestLandmarks = null

            Log.d(
                "MediaPipe",
                "No hand detected"
            )

            return
        }

        val hand = result.landmarks()[0]

        val values = mutableListOf<Float>()

        for (landmark in hand) {

            values.add(landmark.x())
            values.add(landmark.y())
            values.add(landmark.z())
        }

        latestLandmarks = values

        Log.d(
            "MediaPipe",
            "Detected ${hand.size} landmarks"
        )
    }

    fun getLatestLandmarks(): List<Float>? {
        return latestLandmarks
    }

    // NEW: receives an MPImage and sends it to MediaPipe
    fun processFrame(
        image: MPImage,
        timestampMs: Long
    ) {
        try {

            handLandmarker?.detectAsync(
                image,
                timestampMs
            )

        } catch (e: Exception) {

            Log.e(
                "MediaPipe",
                "Failed to process camera frame",
                e
            )
        }
    }

    fun close() {

        handLandmarker?.close()

        handLandmarker = null
        latestLandmarks = null

        Log.d(
            "MediaPipe",
            "Hand Landmarker closed"
        )
    }
}