#!/bin/bash

download_file() {
    local GWAS_ID=$1
    local OUTPUT_FILE="${OUTPUT_DIR}/${GWAS_ID}.vcf.gz"

    # Log the file paths and URLs for debugging
    echo "Processing GWAS ID: $GWAS_ID"
    echo "Output file path: $OUTPUT_FILE"

    # Skip if the file already exists
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo "$GWAS_ID already exists. Skipping..."
        return 0
    fi

    # Construct the URL
    FILE_URL="https://gwas.mrcieu.ac.uk/files/${GWAS_ID}/${GWAS_ID}.vcf.gz"
    echo "Downloading from: $FILE_URL"

    # Download the file
    wget -O "$OUTPUT_FILE" "$FILE_URL"

    # Verify the download was successful
    if [[ $? -ne 0 ]]; then
        echo "Error: Download failed for $GWAS_ID."
        echo "$GWAS_ID,download error" >> missing_datasets.log
        return 1
    fi

    # Check if the file is empty
    if [[ ! -s "$OUTPUT_FILE" ]]; then
        echo "Error: File is empty or missing for $GWAS_ID."
        echo "$GWAS_ID,empty file" >> missing_datasets.log
        rm -f "$OUTPUT_FILE"
        return 1
    fi

    echo "Successfully downloaded $GWAS_ID."
    return 0
}

source config.sh

PART_FILE=$1

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Loop through each line in the PART_FILE
while IFS= read -r GWAS_ID; do
    # Skip empty lines
    if [[ -z "$GWAS_ID" ]]; then
        continue
    fi

    # Call the download_file function with the GWAS_ID
    download_file "$GWAS_ID"
done < "$PART_FILE"