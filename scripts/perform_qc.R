#!/usr/bin/env Rscript

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
data_dir <- args[1]
sop_file <- args[2]
out_dir <- args[3]

# Loading the dataset and sop file
files <- list.files(path=data_dir, pattern="*.csv", full.names=T, recursive=FALSE)
sop <- read.csv(sop_file, header = T)

# Function to perform QC on a single file using the SOP
perform_qc <- function(file, sop) {
  
  data <- read.csv(file, header = F, row.names = 1) # Load file
  # Convert all row names to lower case to match SOP
  row.names(data) <- tolower(row.names(data))
  
  # Extract data fields from SOP
  fields <- sop[, 1]
  
  qc_results <- data.frame()
  
  # Iterate through data fields
  for (field in fields) {
    
    field_data <- data[field,]
    field_sop <- sop[sop$dataField == field, ]
    
    # Check missing data
    if (is.na(field_data)) {
      qc_results <- rbind(qc_results, data.frame(file = basename(file), field = field, result = 'fail', missing = 1, low = 0, high = 0))
    }
    
    # Check min and max length if data type is string
    else if (field_sop$dataType == "String") {
      length <- nchar(field_data)
      min_check <- length >= field_sop$minValue
      max_check <- length <= field_sop$maxValue
      if (!min_check) {
        qc_results <- rbind(qc_results, data.frame(file = basename(file), field = field, result = 'fail', missing = 0, low = 1, high = 0))
      } else if (!max_check) {
        qc_results <- rbind(qc_results, data.frame(file = basename(file), field = field, result = 'fail', missing = 0, low = 0, high = 1))
      } else {  
        qc_results <- rbind(qc_results, data.frame(file = basename(file), field = field, result = 'pass', missing = 0, low = 0, high = 0))
      }
      
    # Check min and max length if data type is float
    } else if (field_sop$dataType == "Float") {
      value <- as.numeric(field_data)
      min_check <- value >= field_sop$minValue
      max_check <- value <= field_sop$maxValue
      if (!min_check) {
        qc_results <- rbind(qc_results, data.frame(file = basename(file), field = field, result = 'fail', missing = 0, low = 1, high = 0))
      } else if (!max_check) {
        qc_results <- rbind(qc_results, data.frame(file = basename(file), field = field, result = 'fail', missing = 0, low = 0, high = 1))
      } else {  
        qc_results <- rbind(qc_results, data.frame(file = basename(file), field = field, result = 'pass', missing = 0, low = 0, high = 0))
      } 
    }
  }
  return(qc_results)
}

# Perform QC on all files
qc_results <- do.call(rbind, lapply(files, perform_qc, sop=sop))

# Save the results
write.csv(qc_results, paste0(out_dir, "qc_results.csv"))
