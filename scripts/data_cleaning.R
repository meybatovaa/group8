library(dplyr)
library(stringr)

setwd("/scratch_tmp/grp/msc_appbio/DCDM_group8/scripts/")

data <- read.csv("../output/merged_data.csv", row.names = 1)

#----------------#
# Inspect fields
#----------------#

# Check number of unique values for each field
for (field in colnames(data)) {
  count <- length(unique(data[ ,field]))
  print(paste("There are", count, "unique values in", field))
}

# Check unique life stages
print(unique(data[ ,"mouse_life_stage"]))
# These align with those described out in the SOP 

# Check mouse strains
print(sort(unique(data[ ,"mouse_strain"])))
# According to the SOP, there should only be 4 strains (C57BL, B6J, 129SV, C3H)
data %>%
  group_by(mouse_strain) %>%
  summarise(count = n(), .groups = "drop")
# Typos were likely made for C57BL strain as the frequencies for additional
# strains are significantly lower

# Check gene symbols under each accession id
# Create a dictionary with gene_accession_id as keys and gene_symbol as values
gene_dict <- tapply(data$gene_symbol, data$gene_accession_id, unique)
head(gene_dict)

# Check parameter names under each id
# Create a dictionary with parameter_id as keys and parameter_name as values
param_dict <- tapply(data$parameter_name, data$parameter_id, unique)
head(param_dict)
duplicated_values <- param_dict[duplicated(param_dict)]
duplicated_values

#--------------#
# Clean fields
#--------------#

# Copy the data to new data frame
new_data <- data

# Mouse strain
#-------------

# Modify the mouse_strain column
new_data <- new_data %>%
  mutate(mouse_strain = if_else(str_detect(mouse_strain, "^C5[0-9]BL"), "C57BL", mouse_strain))
# Check mouse strains
print(sort(unique(new_data[ ,"mouse_strain"])))

# Gene symbols
#-------------

# Standardise the gene symbols
# Format gene symbols in title case as described in the SOP
new_data$gene_symbol <- gsub("^(\\w)(\\w*)$", "\\U\\1\\L\\2", data$gene_symbol, perl = TRUE)

# Check gene symbols under each accession id as before 
new_gene_dict <- tapply(new_data$gene_symbol, new_data$gene_accession_id, unique)
head(new_gene_dict)

# Check number of unique values for each field as before
for (field in colnames(new_data)) {
  count <- length(unique(new_data[ ,field]))
  print(paste("There are", count, "unique values in", field))
}

# Save the cleaned data
write.csv(new_data, "../output/merged_data_clean.csv", row.names = F)
