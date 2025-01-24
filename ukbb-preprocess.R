library(dplyr)
library(stringr)

# Load the UKBB data
ukbb_h2 <- read.delim(
  file = "ukb31063_h2_topline.02Oct2019.tsv",
  header = TRUE,
  sep = "\t",
  quote = "",
  comment.char = ""
)

# Corrected filter_descripts vector
filter_descripts <- c(
  "^(3mm|6mm) .+ \\((left|right)\\)$", "Age", "Arm", "Activities undertaken", "Ankle",
  "Attendance/disability/mobility", "Average weekly", "Bread", "Cereal", "Current employment",
  "Diagnoses - main ICD10", "fruit", "Frequency of", "Gas or", "Hands-free", "Hearing difficulty",
  "Heel", "father", "mother", "Illnesses of siblings", "\\(left\\)", "Job involves", 
  "Leisure/social activities", "Leg predicted", "last 5 years", "Medication for", "Milk type",
  "Mouth/teeth", "Never eat", "Nitrogen dioxide", "Number of", "Own or rent", "Particulate matter",
  "Recent", "prescription", "medication", "Time spent", "physical activity in last 4 weeks",
  "Types of transport", "mobile phone use", "duration", "drive faster", "Ever had", "Illness, injury, bereavement",
  "dietary supplements", "non-butter", "Reason for reducing amount of alcohol", "Salad", "Salt added", "Spread type",
  "Transport type", "Vitamin and mineral supplement"
)

# Corrected filter_studies vector
filter_studies <- c(
  "20117_1", "1558", "1628", "1618", "1369", "20521", "21001_irnt", "2784", 
  "20487", "20498", "3063_irnt", "20150_irnt", "20153_irnt", "20154_irnt", 
  "20151_irnt", "20491", "20403", "2129", "ICDMAIN_ANY_ENTRY", "20495", 
  "30220_irnt", "1408", "1508_1", "1508_3", "1508_2", "41248_1000", 
  "30210_irnt", "4598", "2724", "22704_irnt", "20075_irnt", "41231_1", 
  "6141_1", "XIX_INJURY_POISON", "110001", "is_female", "1379", "699_irnt", 
  "767_irnt", "1787", "1339", "709", "1329", "6159_100", "20488", 
  "129_irnt", "2237", "1389", "1359", "1349", "1259", "XVIII_MISCFINDINGS", 
  "1120"
)

# Apply the filters
ukbb_h2_filtered <- ukbb_h2 %>%
  filter(
    !str_detect(
      notes, 
      "isLowNeff|isMidNeff|isHighSE|isExtremeSE|isBadPower|isSexBias"
    ), # Exclude if notes contain any of these patterns
    h2_p < 1e-6, # Only include rows where h2_p < 1e-6
    !str_detect(description, paste(filter_descripts, collapse = "|")), # Exclude based on descriptions
    !phenotype %in% filter_studies # Exclude based on specific study IDs
  )

# Write the filtered data to a file
write.table(
  ukbb_h2_filtered, 
  file = "filtered_ukbb_traits.txt", 
  sep = "\t", 
  row.names = FALSE, 
  quote = FALSE
)
