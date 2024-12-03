# Load required package 
if (!require("readr")) install.packages("readr")
if (!require("dplyr")) install.packages("dplyr")
if (!require("lubridate")) install.packages("lubridate")
if (!require("tidyverse")) install.packages("tidyverse")
library(readr)
library(dplyr)
library(lubridate)
library(tidyverse)

# Edit this for every cryptocurrency
data_source_path <- "your_path"
destination_path <- "your_path"
keywords <- "TRX_|trx_|ethereum_|itb_|tron_" 

# Set the path to folder
folder_path <- data_source_path

# Get a list of all CSV files in the folder
csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)

# Initialize an empty data frame for merging
merged_data <- data.frame()

# Function to extract a simplified metric name from a file name
extract_metric <- function(file_name) {
  metric_name <- gsub("\\.csv$", "", file_name)
  metric_name <- gsub(keywords, "", metric_name, ignore.case = TRUE)
  metric_name <- gsub("_", " ", metric_name)
  return(tolower(metric_name)) 
}

# Loop through each file and merge on DateTime
for (file in csv_files) {
  # Read the current CSV file
  df <- read.csv(file)
  
  # Remove duplicate DateTime entries, keeping the first occurrence
  df <- df %>%
    distinct(DateTime, .keep_all = TRUE)
  
  # Extract the file name (to use for naming columns)
  file_name <- basename(file)
  metric <- extract_metric(file_name)
  
  # Rename columns based on file name (except DateTime)
  colnames(df)[colnames(df) != "DateTime"] <- paste0(metric, "_", colnames(df)[colnames(df) != "DateTime"])
  
  # Merge dataframes on DateTime
  if (nrow(merged_data) == 0) {
    merged_data <- df
  } else {
    # Use full_join with caution to handle potential many-to-many relationships
    merged_data <- full_join(merged_data, df, by = "DateTime")
  }
}

# Check for memory limit and adjust if needed
if (mem.maxVSize() < 16 * 1024^3) {
  mem.maxVSize(32 * 1024^3) # Increase memory limit to 32 GB if possible
}

# Save the merged data to a CSV file (optional)
write.csv(merged_data, file = destination_path, row.names = FALSE)

# View the merged data
#print(head(merged_data))
