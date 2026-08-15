import urllib.request
from pathlib import Path

import cv2
import numpy as np
import tensorflow as tf
import pickle

from mediapipe.tasks.python.vision.core import image as image_module
from mediapipe.tasks.python.vision.hand_landmarker import (
    HandLandmarker,
    HandLandmarkerOptions,
)
from mediapipe.tasks.python.core import base_options as base_options_module
from mediapipe.tasks.python.vision.core import vision_task_running_mode as running_mode_module

MODEL_URL = 'https://storage.googleapis.com/mediapipe-assets/hand_landmarker.task'
MODEL_PATH = Path('hand_landmarker.task')

LANDMARK_CONNECTIONS = [
    (0, 1), (1, 2), (2, 3), (3, 4),
    (0, 5), (5, 6), (6, 7), (7, 8),
    (5, 9), (9, 10), (10, 11), (11, 12),
    (9, 13), (13, 14), (14, 15), (15, 16),
    (13, 17), (17, 18), (18, 19), (19, 20),
    (0, 17),
]


def download_model(model_path: Path, url: str):
    if model_path.exists():
        return
    print(f'Downloading hand landmarker model from {url}...')
    with urllib.request.urlopen(url) as response:
        model_path.write_bytes(response.read())
    print(f'Model downloaded to {model_path}')


def cv2_to_mediapipe_image(image: np.ndarray):
    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    rgb = np.ascontiguousarray(rgb, dtype=np.uint8)
    return image_module.Image(image_module.ImageFormat.SRGB, rgb)


def draw_landmarks(frame: np.ndarray, landmarks):
    height, width, _ = frame.shape

    for start_idx, end_idx in LANDMARK_CONNECTIONS:
        start = landmarks[start_idx]
        end = landmarks[end_idx]

        start_px = (int(start.x * width), int(start.y * height))
        end_px = (int(end.x * width), int(end.y * height))

        cv2.line(frame, start_px, end_px, (0, 255, 0), 2)

    for lm in landmarks:
        point = (int(lm.x * width), int(lm.y * height))
        cv2.circle(frame, point, 4, (0, 0, 255), -1)


if __name__ == "__main__":

    # Load trained model
    model = tf.keras.models.load_model("asl_model.keras")

    # Load labels
    with open("labels.pkl", "rb") as f:
        le = pickle.load(f)

    download_model(MODEL_PATH, MODEL_URL)

    base_options = base_options_module.BaseOptions(
        model_asset_path=str(MODEL_PATH)
    )

    options = HandLandmarkerOptions(
        base_options=base_options,
        running_mode=running_mode_module.VisionTaskRunningMode.IMAGE,
        num_hands=1,
        min_hand_detection_confidence=0.5,
        min_hand_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    # Open camera
    cap = cv2.VideoCapture(0)

    if not cap.isOpened():
        print("Could not open camera.")
        exit()

    with HandLandmarker.create_from_options(options) as landmarker:

        while True:

            ret, frame = cap.read()

            if not ret:
                break

            # Removed horizontal flip
            # frame = cv2.flip(frame, 1)

            mp_image = cv2_to_mediapipe_image(frame)

            result = landmarker.detect(mp_image)

            if result.hand_landmarks:

                hand = result.hand_landmarks[0]

                draw_landmarks(frame, hand)

                features = []

                for lm in hand:
                    features.extend([lm.x, lm.y, lm.z])

                features = np.array(features).reshape(1, -1)

                prediction = model.predict(features, verbose=0)

                class_id = np.argmax(prediction)

                label = le.inverse_transform([class_id])[0]

                confidence = np.max(prediction) * 100

                cv2.putText(
                    frame,
                    f"Sign: {label}",
                    (30, 50),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (0, 255, 0),
                    2,
                )

                cv2.putText(
                    frame,
                    f"Confidence: {confidence:.2f}%",
                    (30, 90),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    0.8,
                    (255, 255, 0),
                    2,
                )

            cv2.imshow("Sign Language Recognition", frame)

            key = cv2.waitKey(1) & 0xFF

            if key == 27:  # ESC key
                break

    cap.release()
    cv2.destroyAllWindows()