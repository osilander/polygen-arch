library(ieugwasr)

# Retrieve GWAS dataset info
# 50,040 in total
datasets <- gwasinfo()
# Filter datasets
filtered_datasets <- subset(
  datasets,
  #!is.na(nsnp) &           # No longer remove rows with missing SNP count - many are NA
  # nsnp >= 500000 &        # Remove original limit on minimum 500,000 SNPs - many are NA
  #!is.na(sample_size) &    # stop filterin on rows with missing sample size - many are NA
  #sample_size >= 20000 &   # No need for minimum (20,000) samples - many are NA
  ncase >= 2000 &		        # Only keep a minimum on number of cases - many are NA
  !is.na(build) & grepl("HG19", build, ignore.case = TRUE) & # Restrict to HG19 build (all studies between 2014 and 2024 are on this build anyway)
  !is.na(trait) & !grepl("TEST", trait, ignore.case = TRUE) & # Exclude test datasets
  year >= 2014 & year <= 2024 & # Year range (186 studies total are 2006-2013; 8 are NA; 2014 alone has 485 although most by Shin et al.  
  population == "European" )
# Filter on European (44,923 total)
# View filtered datasets
head(filtered_datasets, 10)

write.table(filtered_datasets$id, file="./gwas_list.txt", quote=F, row.names=F)
