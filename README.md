# 7BBG1003 Group Coursework

## Data Egress
Retrieved the `Group8.zip` file from CREATE HPC at `/scratch_tmp/grp/msc_appbio/7BBG1003/CW`

## Working Directory
Work from `/scratch_tmp/grp/msc_appbio/DCDM_group8/`. Contains all data and metadata unzipped from `Group8.zip`. All R and shell scripts are saved in `scripts` directory.

## QC using SOP
QC was conducted using the `IMPC_SOP.csv` file and results were stored in `outputs/qc_results.csv`. Checked for missing values and tested whether values were between the specified min and max values for each parameter. No missing values were found and only 1049 files contained p-values above the specified max and thus failed.

See `perform_qc.R` and `perform_qc.sh` files.

## Collating data
Data files were merged into one data frame and stored as `outputs/merged_data.csv`. Files which failed the QC were not added to the data frame.

See `merge_data.R` and `merge_data.sh` files.

From inspection of the data (see `data_inspection.R`):

- 210,551 different analyses (unique values in `analysis_id` field)
- 369 different parameters were investigated (unique values in `parameter_id`)
- 200 genes were investigated (unique values in `gene_accession_id`)
- 12 mouse strains were used (unique values in `mouse_strain`)
- 7 different mouse life stages (unique values in `mouse_life_stage`)

## Collating metadata
The metadata `.txt` files containing information on the parameters, procedures and diseases were collated into `.csv` files (`IMPC_parameter_description.csv`, `IMPC_procedure.csv`, and `Disease_information.csv`). 

See `collate_metadata.R`.

Missing values (`NA`) are only present in `IMPC_parameter_description.csv` and `IMPC_procedure.csv` in the `description` column, all other fields are populated (see `missing_values.R`)

## Databases
Databases can now be constructed using the collated data file (`outputs/merged_data.csv`) and the collated metadata files (`metadata/IMPC_parameter_description.csv`, `metadata/IMPC_procedure.csv`, and `metadata/Disease_information.csv`).
