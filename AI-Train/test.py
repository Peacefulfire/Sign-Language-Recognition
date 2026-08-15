import os
import sys
from pathlib import Path
import urllib.request
import cv2
import numpy as np
import pandas as pd

MODEL_URL = 'https://storage.googleapis.com/mediapipe-assets/hand_landmarker.task'
MODEL_PATH = Path('hand_landmarker.task')
DATASET_PATH = Path('SignAlphaSet')
OUTPUT_CSV = Path('dataset.csv')

try:
    from mediapipe.tasks.python.components.containers import landmark as landmark_module
    from mediapipe.tasks.python.components.containers import category as category_module
    from mediapipe.tasks.python.vision.core import image as image_module
    from mediapipe.tasks.python.vision.hand_landmarker import HandLandmarker, HandLandmarkerOptions, HandLandmarkerResult
    from mediapipe.tasks.python.core import base_options as base_options_module
    from mediapipe.tasks.python.vision.core import vision_task_running_mode as running_mode_module
except ImportError as exc:
    print('Error importing MediaPipe task modules:', exc)
    print('Make sure you installed mediapipe in the same Python environment you are using.')
    sys.exit(1)


def download_model(model_path: Path, url: str):
    if model_path.exists():
        return
    print(f'Downloading hand landmarker model from {url}...')
    with urllib.request.urlopen(url) as response:
        model_path.write_bytes(response.read())
    print(f'Model downloaded to {model_path}')


def build_column_names():
    cols = []
    for i in range(21):
        cols.extend([f'x{i}', f'y{i}', f'z{i}'])
    cols.append('label')
    return cols


def cv2_to_mediapipe_image(image: np.ndarray):
    if image.ndim != 3 or image.shape[2] != 3:
        raise ValueError('Input image must be a color image with 3 channels.')
    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    rgb = np.ascontiguousarray(rgb, dtype=np.uint8)
    return image_module.Image(image_module.ImageFormat.SRGB, rgb)


def main():
    if not DATASET_PATH.exists() or not DATASET_PATH.is_dir():
        print(f'Dataset folder not found: {DATASET_PATH}')
        sys.exit(1)

    download_model(MODEL_PATH, MODEL_URL)

    model_options = base_options_module.BaseOptions(model_asset_path=str(MODEL_PATH))
    options = HandLandmarkerOptions(
        base_options=model_options,
        running_mode=running_mode_module.VisionTaskRunningMode.IMAGE,
        num_hands=1,
        min_hand_detection_confidence=0.5,
        min_hand_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    rows = []
    with HandLandmarker.create_from_options(options) as landmarker:
        for label in sorted(os.listdir(DATASET_PATH)):
            label_path = DATASET_PATH / label
            if not label_path.is_dir():
                continue

            print(f'Processing {label}...')
            for image_name in sorted(os.listdir(label_path)):
                image_path = label_path / image_name
                image = cv2.imread(str(image_path))
                if image is None:
                    continue

                mp_image = cv2_to_mediapipe_image(image)
                result = landmarker.detect(mp_image)

                if result.hand_landmarks:
                    hand = result.hand_landmarks[0]
                    row = []
                    for lm in hand:
                        row.extend([lm.x, lm.y, lm.z])
                    row.append(label)
                    rows.append(row)

    print(f'Total samples: {len(rows)}')
    cols = build_column_names()
    df = pd.DataFrame(rows, columns=cols[: len(rows[0])] if rows else cols)
    df.to_csv(OUTPUT_CSV, index=False)
    print(f'{OUTPUT_CSV} created successfully!')


if __name__ == '__main__':
    main()
