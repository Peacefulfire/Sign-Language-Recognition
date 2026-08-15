import pandas as pd

df = pd.read_csv("dataset.csv")

a = df[df["label"] == "A"]

print("Number of A samples:", len(a))
print()
print("First A sample:")
print(a.iloc[0].values)