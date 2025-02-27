#!/bin/bash
#SBATCH --job-name=bin_effect_sizes_v2
#SBATCH --output=logs/bin_effect_sizes_v2_%A_%a.out
#SBATCH --error=logs/bin_effect_sizes_v2_%A_%a.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:02:00
#SBATCH --account=uoa04097

# Load bedtools module
ml BEDTools/2.31.1-GCC-12.3.0

# Read the filename from the provided array task ID and add the correct directory prefix
FILENAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" per-bp-beta-beds-filenames.txt)

# Remove "-per-bp-betas.bed.gz" to create an output name
BASENAME=$(basename "$FILENAME" -per-bp-betas.bed.gz)

# Ensure the binned directory exists
mkdir -p binned-betas

# Define the final output file
OUTPUT="binned-betas/binned-${BASENAME}.txt"

# Write the header to the output file
echo -e "Chrom\tStart\tEnd\tMean_ES\tMedian_ES\tMax_ES\tMean_Abs_ES\tMedian_Abs_ES\tMax_Abs_ES\tMean_ES_Sq\tMedian_ES_Sq\tMax_ES_Sq\tMean_Pval\tMedian_Pval\tMax_Pval\tMean_AF\tMedian_AF\tMax_AF\tCount" > "$OUTPUT"

# Run bedtools map directly on the compressed and indexed BED file
# Mapping columns: 4 (es), 5 (abs_es), 6 (es_sq), 7 (pval), 8 (af)
bedtools map -a grch37_50kb_windows_nochr.bed -b <(zcat "$FILENAME") \
  -c 4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,4 \
  -o mean,median,max,mean,median,max,mean,median,max,mean,median,max,mean,median,max,count \
  >> "$OUTPUT"

echo "✅ Processing complete for $FILENAME. Output saved to $OUTPUT"