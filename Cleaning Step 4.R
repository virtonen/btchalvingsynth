library(dplyr)
library(purrr)
library(tidyr)

# Step 1: Define the folder path where all CSV files are stored
folder_path <- "your_path"

# Step 2: List all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Step 3: Create a function to read in each CSV file and ensure consistent structure
read_csv_file <- function(file) {
  df <- read.csv(file)
  
  # Step 4: Ensure 'cryptono' and 'crypto' columns are first and named correctly
  if (!("cryptono" %in% colnames(df))) {
    df$cryptono <- NA  # Add 'cryptono' column if missing
  }
  
  if (!("crypto" %in% colnames(df))) {
    df$crypto <- NA  # Add 'crypto' column if missing
  }
  
  # Reorder columns to ensure 'cryptono' and 'crypto' are first
  df <- df %>% select(cryptono, crypto, everything())
  
  return(df)
}

# Step 5: Read all CSV files into a list of dataframes
df_list <- map(file_list, read_csv_file)

# Step 6: Stack all dataframes using bind_rows to create a long dataset
merged_df <- bind_rows(df_list)

# Step 7: Write the merged dataframe to a new CSV file
write.csv(merged_df, "your_path", row.names = FALSE)
