import pandas as pd

df = pd.read_csv("Mall_Customers.csv")
df = df.drop(["CustomerID","Genre","Age"], axis =1)
df.to_csv("new_mall_customers.csv", index = False)