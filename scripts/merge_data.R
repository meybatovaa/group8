#!/usr/bin/env Rscript

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
data_dir <- args[1]
qc_file <- args[2]
out_dir <- args[3]

library(dplyr)

#---------------------#
# Remove failed files
#---------------------#
# Load the data files
files <- list.files(path=data_dir, pattern="*.csv", full.names=T, recursive=FALSE)
# Load qc_results
qc_results <- read.csv(qc_file)

# Extract failed qc results
fails <- filter(qc_results, result == 'fail')
# List failed files
fail_files <- paste0(data_dir, "/", fails$file)

# List passed files
pass_files <- setdiff(files, fail_files)

#-------------#
# Data fields
#-------------#
# Extract fields
fields <- unique(qc_results$field)

# Write function to extract necessary fields from a data file and combine as a vector
extract_fields <- function(data, fields) {
  # Make data fields lowercase to match qc results
  row.names(data) <- tolower(row.names(data))
  # Initialise vector to store data field values
  data_vec <- c()
  # Loop through each field
  for (field in fields) {
    # Append each field value to the vector
    data_vec <-c(data_vec, data[field, ])
  }
  return(data_vec)
}

#--------------#
# Collate data
#--------------#
# Initialise data frame at its final dimension - speeds up computation
df <- as.data.frame(matrix(NA, nrow = length(pass_files), ncol = length(fields)))
colnames(df) <- fields # Set header

# Merge all passed data files into one data frame
for (i in 1:length(pass_files)) {
  
  # Keep track of progress in multiples of 100
  if (i %% 100 == 0) {
    print(paste(i, "out of", length(pass_files)))
  }
  
  # Load in data with row names
  data <- read.csv(pass_files[i], header = F, row.names = 1)
  
  # Extract data vector
  data_vec <- extract_fields(data, fields)
  
  # Fill in data frame row
  df[i, ] <- data_vec
}

# Change pvalue data to numeric type
df$pvalue <- as.numeric(df$pvalue)

# Save the results
write.csv(df, paste0(out_dir, "merged_data.csv"))
