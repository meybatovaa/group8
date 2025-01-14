#!/bin/bash

# Set the path to your data directory
DATA_DIR="../data"

# Set the path to your SOP file
QC_FILE="../output/qc_results.csv"

# Set the output directory
OUT_DIR="../output/"

# Activate conda environment with dplyr
eval "$(conda shell.bash hook)"
conda activate DCDM

# Run the R script
Rscript merge_data.R $DATA_DIR $QC_FILE $OUT_DIR
