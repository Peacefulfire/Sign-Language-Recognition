import pandas as pd
import numpy as np

from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix
)

import matplotlib.pyplot as plt
import seaborn as sns


# ==========================================
# 1. LOAD DATASET
# ==========================================

data = pd.read_csv("dataset.csv")

X = data.iloc[:, :-1].values
y = data.iloc[:, -1].values


# ==========================================
# 2. ENCODE LABELS
# ==========================================

le = LabelEncoder()
y = le.fit_transform(y)

print("Labels:")
print(list(le.classes_))

print()
print("Total samples:", len(X))
print("Number of features:", X.shape[1])
print("Number of classes:", len(np.unique(y)))


# ==========================================
# 3. TRAIN / TEST SPLIT
# ==========================================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print()
print("Training samples:", len(X_train))
print("Testing samples:", len(X_test))


# ==========================================
# 4. CREATE RANDOM FOREST MODEL
# ==========================================

model = RandomForestClassifier(
    n_estimators=200,
    random_state=42,
    n_jobs=-1
)


# ==========================================
# 5. TRAIN MODEL
# ==========================================

print()
print("Training Random Forest model...")

model.fit(X_train, y_train)

print("Training complete!")


# ==========================================
# 6. MAKE PREDICTIONS
# ==========================================

y_pred = model.predict(X_test)


# ==========================================
# 7. CALCULATE ACCURACY
# ==========================================

accuracy = accuracy_score(y_test, y_pred)

print()
print("==============================")
print("RANDOM FOREST TEST RESULTS")
print("==============================")

print(f"Test Accuracy: {accuracy * 100:.2f}%")


# ==========================================
# 8. CLASSIFICATION REPORT
# ==========================================

print()
print("==============================")
print("CLASSIFICATION REPORT")
print("==============================")

print(
    classification_report(
        y_test,
        y_pred,
        target_names=le.classes_
    )
)


# ==========================================
# 9. CONFUSION MATRIX
# ==========================================

cm = confusion_matrix(y_test, y_pred)

plt.figure(figsize=(14, 12))

sns.heatmap(
    cm,
    annot=True,
    fmt="d",
    cmap="Blues",
    xticklabels=le.classes_,
    yticklabels=le.classes_
)

plt.title("ASL Sign Language Random Forest Confusion Matrix")

plt.xlabel("Predicted Label")
plt.ylabel("True Label")

plt.tight_layout()

plt.show()