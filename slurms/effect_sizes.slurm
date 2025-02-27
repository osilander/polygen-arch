#!/bin/bash
#SBATCH --job-name=bcftools_query
#SBATCH --output=logs/bcftools_query_%A_%a.out
#SBATCH --error=logs/bcftools_query_%A_%a.err
#SBATCH --array=1-408
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=00:06:00
#SBATCH --account=uoa04097

# Load bcftools module (if needed)
ml BCFtools/1.19-GCC-11.3.0
ml BEDTools/2.31.1-GCC-12.3.0
ml HTSlib/1.19-GCC-12.3.0

mkdir -p per-bp-beta-beds

# Get the VCF file for this array task
VCF=$(sed -n "${SLURM_ARRAY_TASK_ID}p" clean-vcf-filenames.txt)

# Extract file name
filename=$(basename "$VCF" .vcf.gz)

# Run bcftools query, format into BED, sort, and compress
bcftools query -f '%CHROM\t%POS\t[%ES]\t[%LP]\t[%AF]\n' "$VCF" | \
awk '{
    chrom=$1;
    pos=$2;
    es=$3;
    abs_es=(es < 0) ? -es : es;
    es_sq=es^2;
    pval=$4;
    af=$5;
    print chrom, pos, pos+1, es, abs_es, es_sq, pval, af
}' OFS="\t" | \
bedtools sort -i - | \
bgzip > "per-bp-beta-beds/${filename}-per-bp-betas.bed.gz"

# Index the compressed and sorted BED file
tabix -p bed "per-bp-beta-beds/${filename}-per-bp-betas.bed.gz"

echo "✅ Sorted and compressed BED file ready: per-bp-betas-beds/${filename}-per-bp-betas.bed.gz"
