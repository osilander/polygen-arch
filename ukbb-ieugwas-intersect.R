setwd("~/Documents/Lab_Notebook/schizo/gwas-clumping/ukbb-analysis")

source("./ieu-preprocess.r", chdir = TRUE)
source("./ukbb-preprocess.r", chdir = TRUE)

ukbb_h2_filtered$description_clean <- tolower(trimws(ukbb_h2_filtered$description))
ieu_filtered$description_clean <- tolower(trimws(ieu_filtered$trait))

# Find rows in ukbb_manifest that do NOT have matches in ieugwas_list
ukbb_ieu_intersect <- ukbb_h2_filtered[! ukbb_h2_filtered$description_clean %in% ieu_filtered$description_clean, ]

write.table(ukbb_ieu_intersect, file = "ukbb_ieu_intersect.txt", sep = "\t", row.names = FALSE, quote = FALSE)