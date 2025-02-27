#!/bin/bash
#SBATCH --job-name=window_analysis
#SBATCH --output=logs/window_analysis_%A_%a.out
#SBATCH --error=logs/window_analysis_%A_%a.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:02:00
#SBATCH --account=uoa04097

ml BEDTools/2.31.1-GCC-12.3.0

# Read the BED filename from the provided array task ID
BEDNAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" filtered_filenames.txt)
BASENAME=$(basename "$BEDNAME" _effect_sizes.txt)
BED_FILE="bedfiles/${BASENAME}.bed"

# Ensure the binned directory exists
mkdir -p binned

# Define the final output file
OUTPUT="binned/binned_${BASENAME}.txt"

# Write the header to the output file
echo -e "Chrom\tStart\tEnd\tMean_Effect\tMedian_Effect\tMax_Effect\tCount_Effect\tMean_Abs_Effect\tMedian_Abs_Effect\tMax_Abs_Effect\tCount_Abs_Effect" > "$OUTPUT"

# Run bedtools map on the BED file
bedtools map -a grch37_50kb_windows_nochr.bed -b "$BED_FILE" -c 4,4,4,4,5,5,5,5 -o mean,median,max,count,mean,median,max,count >> "$OUTPUT"

echo "✅ Windowed analysis complete for $BED_FILE. Output saved to $OUTPUT"