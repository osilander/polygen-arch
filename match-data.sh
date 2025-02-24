#!/bin/bash

# Directories
input_dir="../gwas-downloads/gwas-GRCh37"
output_dir="./data/filtered-ieugwas-vcf"
study_list="./data/filtered-ieugwas-studies.txt"
unmatched_file="unmatched-studies.txt"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Initialize unmatched list
> "$unmatched_file"

# Loop through study names in the study list
while read -r study; do
  # Find matching file in input_dir
  matched_file=$(find "$input_dir" -type f -name "${study}.vcf.gz")
  
  if [[ -n "$matched_file" ]]; then
    # Move the matched file to the output directory
    mv "$matched_file" "$output_dir"
  else
    # Append unmatched study to unmatched_file
    echo "$study" >> "$unmatched_file"
  fi
done < "$study_list"

echo "Processing complete."
echo "Matched files moved to $output_dir."
echo "Unmatched studies listed in $unmatched_file."