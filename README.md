# 7BBG1003 Group Coursework

## Data Egress
Retrieved the `Group8.zip` file from CREATE HPC at `/scratch_tmp/grp/msc_appbio/7BBG1003/CW`

## Working Directory
Work from `/scratch_tmp/grp/msc_appbio/DCDM_group8/`. Contains all data and metadata unzipped from `Group8.zip`.

## QC using SOP
QC was conducted using the `IMPC_SOP.csv` file and results were stored in `outputs/qc_results.csv`. Checked for missing values and tested whether values were between the specified min and max values for each parameter. No missing values were found and only 1049 files contained p-values above the specified max and thus failed.

## Merging data
Data files were merged into one data frame and stored as `outputs/merged_data.csv`. Files which failed the QC were not added to the data frame.
