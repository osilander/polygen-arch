#!/bin/bash
#SBATCH --job-name=make_bed
#SBATCH --output=logs/make_bed_%A_%a.out
#SBATCH --error=logs/make_bed_%A_%a.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:12:00
#SBATCH --account=uoa04097

# Read the filename from the array task ID
FILENAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" per-bp-beta-filenames.txt)

# Ensure FILENAME is not empty
if [[ -z "$FILENAME" ]]; then
  echo "❌ No filename found for task ID ${SLURM_ARRAY_TASK_ID}"
  exit 1
fi

# Set the full path to the input file
FILE="$FILENAME"

# Remove "_per-bp-betas.txt" to create an output name
BASENAME=$(basename "$FILENAME" -per-bp-betas.txt)

# Ensure the BED directory exists
mkdir -p bedfiles

# Convert SNP position files to BED format (start = position, end = position + 1), then sort
BED_FILE="bedfiles/${BASENAME}.bed"
awk '{print $1, $2, $2+1, $3, $4}' OFS="\t" "$FILE" | sort -k1,1 -k2,2n > "$BED_FILE"

# Check if the BED file was created
if [[ -s "$BED_FILE" ]]; then
  echo "✅ BED file created: $BED_FILE"
else
  echo "❌ BED file is empty: $BED_FILE"
fi
