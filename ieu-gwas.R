library(ieugwasr)

# Retrieve GWAS dataset info
datasets <- gwasinfo()
# Filter datasets
filtered_datasets <- subset(
  datasets,
  #!is.na(nsnp) &           # Remove rows with missing SNP count
  # nsnp >= 500000 &        # Minimum 500,000 SNPs
  #!is.na(sample_size) &    # Remove rows with missing sample size
  #sample_size >= 20000 &   # Minimum 20,000 samples
  ncase >= 2000 &		        # Minimum 2,000 cases
  !is.na(build) & grepl("HG19", build, ignore.case = TRUE) & # Restrict to HG19 build
  !is.na(trait) & !grepl("TEST", trait, ignore.case = TRUE) & # Exclude test datasets
  year >= 2018 & year <= 2024   # Year range

# View filtered datasets
head(filtered_datasets, 10)

write.table(filtered_datasets$id, file="./gwas_list.txt", quote=F, row.names=F)
