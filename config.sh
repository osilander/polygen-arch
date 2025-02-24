#!/bin/bash

# Directory to store outputs and logs
OUTPUT_DIR="./data/2025-02-21-filtered-ieugwas-vcf"
LOG_FILE="./data/2025-02-21-ieu-gwas-download.log"

# Retry and delay parameters
MAX_RETRIES=3
DELAY_BETWEEN_DOWNLOADS=5
REQUIRED_SPACE_MB=5000  # Minimum disk space in MB

# Path to the file containing GWAS IDs (one per line)
GWAS_FILE="./remaining-ukbb-studies-for-download.txt"

