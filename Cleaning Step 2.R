# Load necessary packages
if (!require("readr")) install.packages("readr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("summarytools")) install.packages("summarytools")  # For describing data

# Load the libraries
library(readr)
library(dplyr)
library(summarytools)

data_source_path <- "your_path"
destination_path <- "your_path"

# Import the data
data <- read_csv(data_source_path)

# List all column names
#colnames(data)

# Clean column names
clean_colnames <- gsub("^itb ", "", colnames(data))  # Remove "itb" and the following space
clean_colnames <- gsub(" 20[0-9]{2}-[0-9]{2}-[0-9]{2}t[0-9]{2} [0-9]{2} [0-9]{2}\\.[0-9]+z", "", clean_colnames)  # Remove date
colnames(data) <- clean_colnames  # Update column names

# Identify columns that end with '_Price'
price_cols <- grep("_Price$", colnames(data), value = TRUE)

# Check for duplicates and remove them
for (col in price_cols) {
  # Get the corresponding non-Price column (by removing '_Price' suffix)
  base_col <- gsub("_Price$", "", col)
  
  # If the base column exists in the data, check for equality
  if (base_col %in% colnames(data)) {
    # Check if all values in the Price column are equal to the base column
    if (all(data[[col]] == data[[base_col]], na.rm = TRUE)) {
      # If true, remove the Price column
      data[[col]] <- NULL
    }
  }
}

# Show cleaned column names after removing duplicates
#print(colnames(data))

# Save the updated data with new column names to a CSV file
write_csv(data, destination_path)
