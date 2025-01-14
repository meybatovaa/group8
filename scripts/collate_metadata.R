setwd("/scratch_tmp/grp/msc_appbio/DCDM_group8/scripts/")

#----------------------#
# IMPC parameters file
#----------------------#

# Read in lines of parameters file
lines <- readLines("../metadata/IMPC_parameter_description_corrected.txt")

# Remove the unnecessary first line ("x")
lines <- lines[-1]

# Process each line to remove unwanted parts
# Remove everything up to and including the third quotation mark - unnecessary line numbers
cleaned_lines <- gsub('^([^"]*"[^"]*"[^"]*")', "", lines) 
# Remove last quotation mark, even if there are trailing spaces
cleaned_lines <- gsub('"\\s*$', '', cleaned_lines)

# Separate the header (first element) and the data (remaining elements)
header <- strsplit(cleaned_lines[1], ", ")[[1]]  # Split header by ", "
data <- cleaned_lines[-1]  # Remove the header from the data

# Define a function to split each line correctly
split_line <- function(x) {
  # Regular expression to capture the 4 parts
  # First part: numeric value for impcParameterOrigId
  # Second part: name (no extra commas)
  # Third part: description (can contain extra commas)
  # Fourth part: parameterId (starts with 'IMPC')
  pattern <- '^([^,]+),\\s*([^,]+),\\s*(.*),\\s*(IMPC_[^,]+)$'
  matches <- regmatches(x, regexec(pattern, x))[[1]]
  return(matches[2:5])  # Return the 4 captured parts
}

# Apply the function to each row in the data
data_split <- lapply(data, split_line)

# Combine the list into a matrix
data_matrix <- do.call(rbind, data_split)

# Convert the matrix into a data frame
parameters <- as.data.frame(data_matrix)

# Assign column names from the header
colnames(parameters) <- header

# From inspection, 4 rows contained incorrect splitting of name and description
# Since a unique case, correct manually
incorrect_rows <- grep("in mm\\)", parameters$description)
# For each incorrect row, move 'in mm)' from description to name
parameters$description[incorrect_rows][1] <- sub("in mm\\) , ", "", parameters$description[incorrect_rows][1]) # The first row contains an extra space
parameters$description[incorrect_rows][2:4] <- sub("in mm\\), ", "", parameters$description[incorrect_rows][2:4])
parameters$name[incorrect_rows] <- paste0(parameters$name[incorrect_rows], ", in mm)")

# Remove any duplicated lines
parameters <- parameters %>% distinct()

# Save as csv file
write.csv(parameters, "../metadata/IMPC_parameter_description.csv", row.names = F)

#----------------------#
# IMPC procedures file
#----------------------#

lines <- readLines("../metadata/IMPC_procedure.txt")

# Process each line to remove unwanted parts
# Remove everything up to and including the third quotation mark - unnecessary line numbers
cleaned_lines <- gsub('^([^"]*"[^"]*"[^"]*")', "", lines) 
# Remove last quotation mark, even if there are trailing spaces
cleaned_lines <- gsub('"\\s*$', '', cleaned_lines)

# Separate the header (first element) and the data (remaining elements)
header <- strsplit(cleaned_lines[1], ", ")[[1]]  # Split header by ", "
data <- cleaned_lines[-1]  # Remove the header from the data

# Define a function to split each line correctly
split_line <- function(x) {
  # Regular expression to capture the 4 parts
  # First part: name (no extra commas)
  # Second part: description (can contain extra commas)
  # Third part: always a boolean value (TRUE/FALSE)
  # Fourth part: numeric value for impcParameterOrigId
  pattern <- '^([^,]+),\\s*(.*?),\\s*(TRUE|FALSE),\\s*(\\d+)$'
  matches <- regmatches(x, regexec(pattern, x))[[1]]
  return(matches[2:5])  # Return the 4 captured parts
}

# Apply the function to each row in the data
data_split <- lapply(data, split_line)

# Combine the list into a matrix
data_matrix <- do.call(rbind, data_split)

# Convert the matrix into a data frame
procedures <- as.data.frame(data_matrix)

# Assign column names from the header
colnames(procedures) <- header[-1] # Don't include procedureId since no lines seem to provide it

# Change isMandatory to Boolean values
procedures$isMandatory <- as.logical(procedures$isMandatory)

# Save as csv file
write.csv(procedures, "../metadata/IMPC_procedure.csv", row.names = F)

#-------------------#
# Disease info file
#-------------------#

lines <- readLines("../metadata/Disease_information.txt")

# Remove the unnecessary first line ("x")
lines <- lines[-1]

# Process each line to remove unwanted parts
# Remove everything up to and including the third quotation mark - unnecessary line numbers
cleaned_lines <- gsub('^([^"]*"[^"]*"[^"]*")', "", lines) 
# Remove last quotation mark, even if there are trailing spaces
cleaned_lines <- gsub('"\\s*$', '', cleaned_lines)

# Separate the header (first element) and the data (remaining elements)
header <- strsplit(cleaned_lines[1], ", ")[[1]]  # Split header by ", "
data <- cleaned_lines[-1]  # Remove the header from the data

# Define a function to split each line correctly
split_line <- function(x) {
  # Regular expression to capture the 4 parts
  # First part: disease_id (no extra commas)
  # Second part: disease_term (can contain extra commas)
  # Third part: always starts with 'MGI:'
  # Fourth part: numeric value which can contain decimal point
  pattern <- '^([^,]+),\\s*(.*?),\\s*(MGI:[^,]+),\\s*(\\d+(\\.\\d+)?)$'
  matches <- regmatches(x, regexec(pattern, x))[[1]]
  return(matches[2:5])  # Return the 4 captured parts
}

# Apply the function to each row in the data
data_split <- lapply(data, split_line)

# Combine the list into a matrix
data_matrix <- do.call(rbind, data_split)

# Convert the matrix into a data frame
diseases <- as.data.frame(data_matrix)

# Assign column names from the header
colnames(diseases) <- header

# Save as csv file
write.csv(diseases, "../metadata/Disease_information.csv", row.names = F)
