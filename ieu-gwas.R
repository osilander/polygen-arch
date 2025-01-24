library(ieugwasr)

setwd("~/Documents/Lab_Notebook/schizo/gwas-clumping")
# Retrieve GWAS dataset info
# only do ONCE!!
# datasets <- gwasinfo()
datasets <- read.delim(
  file = "./data/ieu-gwas-original.txt",
  header = TRUE,
  sep = "\t",
  quote = "",
  comment.char = ""
)
#read.table(file="./datasets/gwas_datasets.txt", sep="\t", header=T)

# Filter datasets
filtered_datasets <- subset(
  datasets, 
  # !is.na(nsnp) &                                # Remove rows with missing SNP count
  # nsnp >= 500000 &                              # Minimum 500,000 SNPs
  # !is.na(sample_size) &                         # Remove rows with missing sample size
  # sample_size >= 20000 &                       # Minimum 20,000 samples
  # ncase >= 2000 &                       		# Minimum 5,000 cases
  #!is.na(build) & grepl("HG19", build, ignore.case = TRUE) & # No strong reason to estrict to HG19 build
  !is.na(trait) & !grepl("TEST", trait, ignore.case = TRUE) # Exclude test datasets
  # year >= 2012 & year <= 2024                   # Year range
)

# View filtered datasets
head(filtered_datasets, 10)

write.table(filtered_datasets, file="./ieu-gwas-original.txt", quote=F, row.names=F)