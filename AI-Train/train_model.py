import pandas as pd
import numpy as np
import tensorflow as tf
import pickle

from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix, classification_report

import matplotlib.pyplot as plt
import seaborn as sns


# =========================
# LOAD DATASET
# =========================

data = pd.read_csv("dataset.csv")

X = data.iloc[:, :-1].values
y = data.iloc[:, -1].values


# =========================
# ENCODE LABELS
# =========================

le = LabelEncoder()
y = le.fit_transform(y)

with open("labels.pkl", "wb") as f:
    pickle.dump(le, f)

print("Labels:", list(le.classes_))


# =========================
# TRAIN / TEST SPLIT
# =========================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print("Training samples:", len(X_train))
print("Testing samples:", len(X_test))


# =========================
# BUILD MODEL
# =========================

model = tf.keras.Sequential([
    tf.keras.layers.Dense(
        128,
        activation='relu',
        input_shape=(63,)
    ),

    tf.keras.layers.Dense(
        64,
        activation='relu'
    ),

    tf.keras.layers.Dense(
        len(np.unique(y)),
        activation='softmax'
    )
])


# =========================
# COMPILE MODEL
# =========================

model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)


# =========================
# TRAIN MODEL
# =========================

model.fit(
    X_train,
    y_train,
    epochs=200,
    batch_size=16
)


# =========================
# TEST ACCURACY
# =========================

loss, acc = model.evaluate(
    X_test,
    y_test,
    verbose=0
)

print()
print("==============================")
print("MODEL TEST RESULTS")
print("==============================")
print(f"Test Accuracy: {acc * 100:.2f}%")
print(f"Test Loss: {loss:.4f}")


# =========================
# PREDICTIONS
# =========================

y_probability = model.predict(
    X_test,
    verbose=0
)

y_pred = np.argmax(
    y_probability,
    axis=1
)


# =========================
# CLASSIFICATION REPORT
# =========================

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


# =========================
# CONFUSION MATRIX
# =========================

cm = confusion_matrix(
    y_test,
    y_pred
)

print()
print("==============================")
print("CONFUSION MATRIX")
print("==============================")

print(cm)


# =========================
# SAVE CONFUSION MATRIX IMAGE
# =========================

plt.figure(figsize=(12, 10))

sns.heatmap(
    cm,
    annot=True,
    fmt='d',
    cmap='Blues',
    xticklabels=le.classes_,
    yticklabels=le.classes_
)

plt.xlabel("Predicted Label")
plt.ylabel("True Label")
plt.title("ASL Sign Language Confusion Matrix")

plt.tight_layout()

plt.savefig(
    "confusion_matrix.png",
    dpi=300
)

plt.show()


# =========================
# SAVE MODEL
# =========================

model.save("asl_model.keras")

print()
print("Confusion matrix saved as: confusion_matrix.png")
print("Model training complete!")