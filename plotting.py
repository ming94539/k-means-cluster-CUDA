import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

#Before clustering
df = pd.read_csv("new_mall_customers.csv")
df.plot(x="Annual Income (k$)", y="Spending Score (1-100)",kind="scatter")
plt.show()
#After clustering
df2 = pd.read_csv("output.csv")
sns.scatterplot(x=df2.x, y=df2.y, 
                hue=df2.c, 
                palette=sns.color_palette("hls", n_colors=5))
plt.xlabel("Annual income (k$)")
plt.ylabel("Spending Score (1-100)")
plt.title("Clustered: spending (y) vs income (x)")

plt.show()

