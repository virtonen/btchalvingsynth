# Deriving new variable transformations and selecting non-correlated predictors

df <- read.csv("your-path-to-merged-data")
head(df)

# Define the columns representing the holdings brackets
holdings_columns <- c(
  "mean_addresses_by_holdings_in_usd_X_0_00____1_00",
  "mean_addresses_by_holdings_in_usd_X_1_00____10_00",
  "mean_addresses_by_holdings_in_usd_X_10_00____100_00",
  "mean_addresses_by_holdings_in_usd_X_100_00____1k",
  "mean_addresses_by_holdings_in_usd_X_1k____10k",
  "mean_addresses_by_holdings_in_usd_X_10k____100k",
  "mean_addresses_by_holdings_in_usd_X_100k____1m",
  "mean_addresses_by_holdings_in_usd_X_1m____10m",
  "mean_addresses_by_holdings_in_usd_X___10m"
)

# Add "_share" columns for each bracket
df <- df %>%
  rowwise() %>%
  mutate(
    total_holdings = sum(c_across(all_of(holdings_columns)), na.rm = TRUE),
    across(
      all_of(holdings_columns),
      .fns = ~ 100 * .x / total_holdings,
      .names = "{.col}_share"
    )
  ) %>%
  ungroup()

# Add logged variables and calculate the share of highers to lowers
df <- df %>%
  mutate(
    # Add logged variables (adding 1 to avoid issues with log(0))
    log_all_time_highers = log(mean_all_time_highers_lowers_undefined_All_Time_Highers + 1),
    log_all_time_lowers = log(mean_all_time_highers_lowers_undefined_All_Time_Lowers + 1),
    log_avg_time_between_transactions = log(mean_average_time_between_transactions_Seconds + 1),
    log_hodler_balance = log(mean_balance_by_time_held_undefined_Hodlers__1Y__ + 1),
    
    # Calculate the share of highers to lowers
    share_highers_to_lowers = mean_all_time_highers_lowers_undefined_All_Time_Highers / 
                              mean_all_time_highers_lowers_undefined_All_Time_Lowers
  )

# Create shares for Hodlers, Cruisers, and Traders
df <- df %>%
  mutate(
    # Calculate the total balance for the three groups
    total_balance_by_time_held = mean_balance_by_time_held_undefined_Hodlers__1Y__ +
                                 mean_balance_by_time_held_undefined_Cruisers__1_12M_ +
                                 mean_balance_by_time_held_undefined_Traders___1M_,
    
    # Calculate shares
    mean_balance_by_time_held_undefined_Hodlers__1Y___share = mean_balance_by_time_held_undefined_Hodlers__1Y__ / total_balance_by_time_held,
    mean_balance_by_time_held_undefined_Cruisers__1_12M__share = mean_balance_by_time_held_undefined_Cruisers__1_12M_ / total_balance_by_time_held,
    mean_balance_by_time_held_undefined_Traders___1M__share = mean_balance_by_time_held_undefined_Traders___1M_ / total_balance_by_time_held
  )

# Add addresses share variables
df <- df %>%
  mutate(
    # Calculate the share of zero balance addresses out of total addresses
    mean_total_addresses_Total_Zero_Balance_share = mean_total_addresses_Total_Zero_Balance / mean_total_addresses_Total,
    
    # Calculate the share of addresses with balance out of total addresses
    mean_total_addresses_Total_With_Balance_share = mean_total_addresses_Total_With_Balance / mean_total_addresses_Total,
    
    # Calculate the share of zero balance daily active addresses out of total daily active addresses
    mean_daily_active_addresses_Zero_Balance_Addresses_share = mean_daily_active_addresses_Zero_Balance_Addresses / mean_daily_active_addresses_Active_Addresses
  )



# Check the structure of the updated dataframe
head(df)

# Calculate correlation matrix for all numeric predictors in the dataset
# Exclude non-numeric columns to get correlations only between numeric predictors
numeric_df <- df %>% select(where(is.numeric))
cor_matrix <- cor(numeric_df, use = "complete.obs")

# Visualize the correlation matrix to see how predictors correlate
corrplot(cor_matrix, method = "color", tl.cex = 0.6)


# Set the initial predictors list
predictors_list <- c(
  "mean_active_addresses_ratio_Active"
)

# Define a threshold for low correlation (adjust as necessary)
cor_threshold <- 0.7

# Function to add predictors with low correlation to existing predictors_list
add_predictors <- function(cor_matrix, predictors_list, cor_threshold) {
  for (col in colnames(cor_matrix)) {
    if (col %in% predictors_list) next  # Skip if already in predictors_list

    # Calculate maximum absolute correlation of this column with predictors in predictors_list
    max_cor <- max(abs(cor_matrix[col, predictors_list]), na.rm = TRUE)

    # Add to predictors_list if maximum correlation is below threshold
    if (max_cor < cor_threshold) {
      predictors_list <- c(predictors_list, col)
    }
  }
  return(predictors_list)
}

# Apply the function to extend the predictors_list
predictors_list <- add_predictors(cor_matrix, predictors_list, cor_threshold)

# Check the extended predictors_list
print(predictors_list)

------------------------------------------------------------------------------------------------------------------------------
# 2024 SCM model with a new list of predictors

# New list of predictors
predictors_list <- c(
  "mean_active_addresses_ratio_Active",
  "mean_addresses_by_holdings_in_usd_X_1m____10m_share",
  "mean_addresses_by_holdings_in_usd_X___10m_share",
  "log_all_time_highers",
  "log_all_time_lowers",
  "mean_daily_active_addresses_Zero_Balance_Addresses_share",
  "log_hodler_balance",
  "mean_balance_by_time_held_undefined_Hodlers__1Y___share",
  "mean_balance_by_time_held_undefined_Traders___1M__share",
  "mean_new_adoption_rate_New_Adoption_Rate"
)

# Define the key dates
#start_date <- as.Date("2023-04-02")  # Week 1
#halving_date <- as.Date("2024-04-21")  # Week 56
#end_date <- as.Date("2024-09-22")  # Week 78

# Define the time periods
time_predictors_prior <- c(1:56)
time_optimize_ssr <- time_predictors_prior
time_plot <- c(1:78)

all_controls <- c(2:26) # define the list of all control units
excluded_units <- c(6, 14) # excluded due to NAs: DOGE, JET
controls_identifier <- setdiff(all_controls, excluded_units) # create the final list of control units by excluding the specified units

# Prepare the data for Synth
dataprep.out <- dataprep(
  df,
  predictors = predictors_list,
  predictors.op = "mean",
  dependent = "wallet_value",  # Use the wallet value as the dependent variable
  unit.variable = "cryptono",
  time.variable = "week_index",
  unit.names.variable = "crypto",
  treatment.identifier = 1,  # Set your treated unit identifier here
  controls.identifier = controls_identifier,
  time.predictors.prior = time_predictors_prior,
  time.optimize.ssr = time_optimize_ssr,
  time.plot = time_plot
)
# Run synth
synth.out <- synth(dataprep.out)

# Get result tables and assess pre-treatment fit
synth.tables <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res = synth.out
)
print(synth.tables)

# Plot the results
path.plot(
  synth.res = synth.out,
  dataprep.res = dataprep.out,
  Ylab = "Wallet Value ($100 initial investment)",
  Xlab = "Week",
  Legend = c("BTC Wallet Value", "Synthetic BTC Wallet Value"),
  Legend.position = "topleft"
)

abline(v   = 56,
       lty = 2)

------------------------------------------------------------------------------------------------------------------------------
# Placebo in time: 10 weeks earlier

# Define the time periods
time_predictors_prior <- c(1:46)
time_optimize_ssr <- time_predictors_prior
time_plot <- c(1:78)

all_controls <- c(2:26) # define the list of all control units
excluded_units <- c(6, 14) # excluded due to NAs: DOGE, JET
controls_identifier <- setdiff(all_controls, excluded_units) # create the final list of control units by excluding the specified units

# Prepare the data for Synth
dataprep.out <- dataprep(
  df,
  predictors = predictors_list,
  predictors.op = "mean",
  dependent = "wallet_value",  # Use the wallet value as the dependent variable
  unit.variable = "cryptono",
  time.variable = "week_index",
  unit.names.variable = "crypto",
  treatment.identifier = 1,  # Set your treated unit identifier here
  controls.identifier = controls_identifier,
  time.predictors.prior = time_predictors_prior,
  time.optimize.ssr = time_optimize_ssr,
  time.plot = time_plot
)
# Run synth
synth.out <- synth(dataprep.out)

# Get result tables and assess pre-treatment fit
synth.tables <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res = synth.out
)
print(synth.tables)

# Plot the results
path.plot(
  synth.res = synth.out,
  dataprep.res = dataprep.out,
  Ylab = "Wallet Value ($100 initial investment)",
  Xlab = "Week",
  Legend = c("BTC Wallet Value", "Synthetic BTC Wallet Value"),
  Legend.position = "topleft"
)

abline(v   = 56, #47
       lty = 2)

------------------------------------------------------------------------------------------------------------------------------
# Placebo in-space: TRX as the treated unit

# Define the time periods
time_predictors_prior <- c(1:56)
time_optimize_ssr <- time_predictors_prior
time_plot <- c(1:78)

all_controls <- c(1:25) # define the list of all control units
excluded_units <- c(6, 14) # excluded due to NAs: DOGE, JET
controls_identifier <- setdiff(all_controls, excluded_units) # create the final list of control units by excluding the specified units

# Prepare the data for Synth
dataprep.out <- dataprep(
  df,
  predictors = predictors_list,
  predictors.op = "mean",
  dependent = "wallet_value",  # Use the wallet value as the dependent variable
  unit.variable = "cryptono",
  time.variable = "week_index",
  unit.names.variable = "crypto",
  treatment.identifier = 26,  # Set your treated unit identifier here
  controls.identifier = controls_identifier,
  time.predictors.prior = time_predictors_prior,
  time.optimize.ssr = time_optimize_ssr,
  time.plot = time_plot
)
# Run synth
synth.out <- synth(dataprep.out)

# Get result tables and assess pre-treatment fit
synth.tables <- synth.tab(
  dataprep.res = dataprep.out,
  synth.res = synth.out
)
print(synth.tables)

# Plot the results
path.plot(
  synth.res = synth.out,
  dataprep.res = dataprep.out,
  Ylab = "Wallet Value ($100 initial investment)",
  Xlab = "Week",
  Legend = c("TRX Wallet Value", "Synthetic TRX Wallet Value"),
  Legend.position = "topleft"
)

abline(v   = 56,
       lty = 2)
