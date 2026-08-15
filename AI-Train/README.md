# Dataset extractor

This repository processes images in the `SignAlphaSet` folder and extracts MediaPipe hand landmarks into `dataset.csv`.

Installation (recommended inside a virtualenv):

```bash
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

Run:

```bash
python test.py
```

If `SignAlphaSet` is not present, create it and add subfolders `A`..`Z` containing images.

Troubleshooting MediaPipe on Windows:

- If you see an import error like "module 'mediapipe' has no attribute 'solutions'", try reinstalling MediaPipe with the matching wheel for your Python version:

```powershell
python -m pip uninstall mediapipe -y
python -m pip install mediapipe
```

- If the pip install fails or the import still fails, install a specific supported version (example):

```powershell
python -m pip install mediapipe==0.10.1
```

- Ensure you use the same Python executable shown in the environment info (`C:/Program Files/Python311/python.exe`). If installation still fails, install the Microsoft Visual C++ Redistributable and retry.
