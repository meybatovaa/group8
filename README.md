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

## Schema design
The database schema was created as `impc_db`, comprising five key tables:

- `parameter_descriptions`: Stores phenotyping parameter details.  
- `procedure_descriptions`: Documents testing procedures.  
- `disease_associations`: Links genes and diseases with phenodigm scores.  
- `phenotype_analysis`: Holds experimental results, including p-values.  
- `parameter_groups`: Categories for organizing related phenotype test parameters

Primary and foreign keys were implemented to establish relationships between tables, ensuring data consistency and integrity.

## Data import
Data from CSV files were loaded into the tables. Fields were mapped, and constraints such as foreign key relationships were adhered to for accurate data integration.

## Parameter Grouping 
Parameters in `parameter_descriptions` ers were assigned into predefined groups based on their features:

-Weight: Parameters involving body and organ weights.
-Images: Parameters from imaging techniques.
-Brain: Parameters focused on brain functions and structures.
-Morphology: Parameters concerning anatomical features.
-Eye: Parameters related to the eye and vision.
-Blood: Parameters on hematology and composition.
-Housing: Parameters reflecting animal housing conditions.
-Conditions: Parameters tied to experimental contexts and cues.

A foreign key constraint was added between `parameter_descriptions` and `parameter_groups`, to allow relational mapping of parameters to their groups.

##Dump file
The database dump, containing all the structures and tables for the IMPC database was generated ans stored on HPC.
