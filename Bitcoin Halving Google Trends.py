import pandas as pd

# Load the provided CSV file
file_path = "2020 Bitcoin Halving Google Trends.csv" #same for 2024 Bitcoin Halving Google Trends.csv
df = pd.read_csv(file_path)

# Display the first few rows to understand the structure
df.head()

# Rename columns properly and clean the data
df = pd.read_csv(file_path, skiprows=1)  # Skip the first row (header)

# Rename columns for clarity
df.columns = ["Week", "Google Trends Interest"]

# Convert 'Week' to datetime format
df["Week"] = pd.to_datetime(df["Week"])

# Replace '<1' with 0 for proper numerical plotting
df["Google Trends Interest"] = df["Google Trends Interest"].replace("<1", 0).astype(int)

# Plot the cleaned data
import matplotlib.pyplot as plt

plt.figure(figsize=(12, 6))
plt.plot(df["Week"], df["Google Trends Interest"], linestyle='-', marker='', color='blue')
plt.xlabel("Year")
plt.ylabel("Google Trends Interest")
plt.title("Google Trends Interest for 'Bitcoin Halving' Over Time")
plt.grid(True)
plt.show()
