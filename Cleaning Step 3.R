# Load required libraries
library(dplyr)
library(lubridate)

data_source_path <- "your_path"
destination_path <- "your_path"
cryptocode <- "TRX" # example
cryptonumber <- 26

# Load the CSV file
df <- read.csv(data_source_path)

# Step 1: Convert 'DateTime' column to Date format and remove the time part
df$DateTime <- as.Date(df$DateTime)  # Keep only the date part

# Step 2: Resample the dataset to weekly (taking the mean for each week)
df_weekly <- df %>%
  group_by(week = floor_date(DateTime, "week")) %>%
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE), .names = "mean_{col}"))

# Step 3: Identify and remove duplicate columns with identical values (especially columns ending with '_Price')
# Check columns ending with '_Price'
price_cols <- grep("_Price$", colnames(df_weekly), value = TRUE)

# Identify duplicate columns by comparing them
duplicate_price_cols <- c()  # To store duplicate '_Price' columns

for (i in seq_along(price_cols)) {
  for (j in seq_along(price_cols)) {
    if (i < j && all(df_weekly[[price_cols[i]]] == df_weekly[[price_cols[j]]], na.rm = TRUE)) {
      duplicate_price_cols <- c(duplicate_price_cols, price_cols[j])
    }
  }
}

# Remove only the identified duplicate '_Price' columns
df_weekly_cleaned <- df_weekly %>%
  select(-all_of(duplicate_price_cols))

# Step 4: Clean column names (remove spaces and replace with underscores, and handle any special characters)
colnames(df_weekly_cleaned) <- gsub(" ", "_", colnames(df_weekly_cleaned))
colnames(df_weekly_cleaned) <- gsub("\\.", "_", colnames(df_weekly_cleaned))

# Step 5: Add the 'cryptono' and 'crypto' columns at the beginning
df_weekly_cleaned <- df_weekly_cleaned %>%
  mutate(cryptono = cryptonumber, crypto = cryptocode) %>%          # Add the two new columns
  relocate(cryptono, crypto, .before = everything()) # Move them to the beginnin

# Step 6: Filter the rows to keep only data between April 2023 and May 2022
df_weekly_cleaned_filtered <- df_weekly_cleaned %>%
  filter(week >= as.Date("2023-04-01") & week <= as.Date("2024-09-22"))

# View the cleaned weekly dataset
#print(df_weekly_cleaned_filtered)

# Write the cleaned data to a CSV file
write.csv(df_weekly_cleaned_filtered, destination_path, row.names = FALSE)
colnames(df_weekly_cleaned_filtered)
