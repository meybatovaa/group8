library(dplyr)

setwd("/scratch_tmp/grp/msc_appbio/DCDM_group8/scripts/")

parameters <- read.csv("../metadata/IMPC_parameter_description_orig.csv")
procedures <- read.csv("../metadata/IMPC_procedure.csv")
diseases <- read.csv("../metadata/Disease_information.csv")
data <- read.csv("../output/merged_data.csv", row.names = 1)

# Write function to count the number of missing values in a data file
count_missing <- function(data) {
  # Copy the data
  data_copy <- data
  # Convert empty spaces to NA
  data_copy[data_copy == ""] <- NA
  
  # Count total missing values in data
  total_count <- data_copy %>% summarise(count = sum(is.na(.)))
  print(paste("There are a total of", total_count, "missing values."))
  
  # Count missing values in the description field (if one exists) since that is where they are expected
  if ('description' %in% colnames(data)) {
    description_count <- data_copy %>% summarise(count = sum(is.na(description)))
    print(paste(description_count, "of these are in the 'description' field."))
  }
}

count_missing(data) # No missing values
count_missing(parameters) # Missing values in all fields
count_missing(procedures) # All missing values in 'description' field
count_missing(diseases) # No missing values

# Check for missing lines in parameter file
which(rowSums(is.na(parameters)) == ncol(parameters))
# From inspection, these missing lines are due to lines being separated by an additional "\n" character in the 'description' field
# This is difficult to deal with in R, so make a copy of the original txt file and correct these manually since there are a relatively small number of them
# Find these lines by these row indexes.

# Import corrected parameters file
parameters <- read.csv("../metadata/IMPC_parameter_description.csv")
count_missing(parameters)

# Write a function to write the data to a new csv where blank spaces are replaced by NAs
write_to_NA <- function(data, output_file) {
  # Copy the data
  data_copy <- data
  # Convert empty spaces to NA
  data_copy[data_copy == ""] <- NA
  
  write.csv(data_copy, output_file, row.names = F)
}

# Write new parameter and procedure files since they were the only ones to contain missing values
write_to_NA(parameters, "../metadata/IMPC_parameter_description.csv")
write_to_NA(procedures, "../metadata/IMPC_procedure.csv")
