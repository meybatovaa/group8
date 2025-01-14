# 7BBG1003 Group Coursework

## Data Egress
Retrieved the `Group8.zip` file from CREATE HPC at `/scratch_tmp/grp/msc_appbio/7BBG1003/CW` containing:

- `data.zip` : Zipped folder containing all phenotype analysis `.csv` files
- `IMPC_SOP.csv` : Standard operating procedure for IMPC phenotype analysis data
- `IMPC_parameter_description.txt` : Description of parameters belonging to each phenotype analysis
- `IMPC_procedure.txt` : Description of procedures used for each parameter
- `Disease_information.txt` : PhenoDigm scores for human disease to mouse phenotype association
- `query_genes.csv` : List of the genotypes the collaborator would like to query from the database

## Working Directory
Work from `/scratch_tmp/grp/msc_appbio/DCDM_group8/` with the following subdirectories:

- `data/` : Contains all phenotype analysis `.csv` files unzipped from `Group8.zip`
- `metadata/` : Contains all experimental metadata `.txt` and `.csv` files, e.g. `IMPC_SOP.csv`, `IMPC_parameter_description.txt`, etc.
- `output/` : Contains QC results, collated data and database dump files
- `scripts/` : Contains all R, shell and MySQL scripts

## Scripts

1. `perform_qc.R` and `perform_qc.sh` - Run R script through shell script as a batch job on the CREATE HPC
   - Perform phenotype analysis data QC using the `IMPC_SOP.csv` file
   - Outputs `output/qc_results.csv`
2. `merge_data.R` and `merge_data.sh` - Run R script through shell script as a batch job on the CREATE HPC
   - Merge passed phenotype analysis data files into one data frame
   - Outputs `output/merged_data.csv`
3. `collate_metadata.R` - Run on RStudio from the CREATE HPC
   - Read in additional data files into `.csv` files
   - Outputs `metadata/{file_name}.csv` for each `metadata/{file_name}.txt`
4. `missing_values.R` - Run on RStudio from the CREATE HPC
   - Count and standardise any missing values in the collated data
   - Outputs corrected files under the same names
5. `data_cleaning.R` - Run on RStudio from the CREATE HPC
   - Further standardise fields in the merged phenotype analysis data
   - Outputs `merged_data_clean.csv`
6. `database_script.sql` and `database8_dump.sql` - Run on MySQL
   - Generate MySQL database either using original script or the dump backup file
   - Outputs `database8` MySQL database
7. `rshiny.app.R` - Run on RStudio
   - Generate RShiny dashboard with visualisations specified by the collaborator
