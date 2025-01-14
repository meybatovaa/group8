#!/bin/bash

# Set the path to your data directory
DATA_DIR="../data"

# Set the path to your SOP file
SOP_FILE="../metadata/IMPC_SOP.csv"

# Set the output directory
OUT_DIR="../output/"

module load r/4.3.0-gcc-13.2.0-withx-rmath-standalone-python-3.11.6

# Run the R script
Rscript perform_qc.R $DATA_DIR $SOP_FILE $OUT_DIR
