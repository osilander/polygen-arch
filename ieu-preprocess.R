#setwd("~/Documents/Lab_Notebook/schizo/gwas-clumping/")

ieu <- read.delim(file = "gwas-datasets.txt", 
                  sep = "\t", 
                  header = TRUE, 
                  fill = TRUE,    # Allows rows with missing fields
                  quote = "",     # Avoids issues with quoted fields
                  comment.char = "")  # Ignores comment lines starting with #

# Define patterns to exclude based on study ID
exclude_studies <- c("met-a", "met-c", "met-b", "met-d", "prot-a", "prot-b", "prot-c", "ubm-b", "ukb-d", "finn-", "ubm-a", "eqtl", "ebi")

include_pops <- c("European")

include_sex <- c("Males and Females")

# Define patterns to exclude based on phenotype names
exclude_phenos <- c("Treatment/medication code", "father", "mother", "IgG levels", "Vitamin and mineral supplements",
                    "Operative procedures", "Operation code", "Operative code", "(left)", "Current employment status", 
                    "Destinations on discharge from hospital", "Diagnoses - secondary ICD10","Attendance/disability/mobility allowance",
                    "Average weekly", "Blood sample #, note contents: Poor venous access/flow", "Why reduced smoking",
                    "Vitamin and/or mineral supplement use", "Types of spreads/sauces consumed", "Types of transport used",
                    "Types of spread used on bread/crackers", "Types of physical activity in last 4 weeks", "Type of fat/oil used in cooking",
                    "How are people in household related to participant", "Illness, injury, bereavement, stress in last 2 years",
                    "Illnesses of siblings", "How are people in household related", "Intended management of patient", "Leisure/social activities",
                    "Main speciality of consultant", "Distance between home and job workplace", "Duration of", "Ever had", "External causes",
                    "Fractured bone site", "Frequency of", "Gas or solid-fuel cooking/heating", "Illness  injury  bereavement  stress",
                    "Medication for cholesterol", "Medication for pain relief", "Methods of admission to hospital", "Methods of discharge from hospital",
                    "Mineral and other dietary supplements", "Never eat eggs, dairy, wheat, sugar", "Number of",
                    "Pain type(s) experienced in last month", "PCT responsible for patient data", "PCT where patients GP was registered",
                    "Reason for glasses/contact lenses", "Size of red wine glass drunk", "Sources of admission to hospital", "Thickness of butter/margarine",
                    "Treatment speciality of consultant", "Transport type for commuting", "None of the above", "Mouth/teeth dental problems",
                    "medication", "Age", "Adopted", "Answered sexual history questions", "Aide-memoire completed",
                    "Bread", "Breakfast", "Breastfed", "Caffeine", "Bring up phlegm", "Cheese", "Chest pain due to walking ceases when standing still",
                    "Chest pain or discomfort walking normally", "Close to major road", "Copper", "Delivery methods", "Dessert", "Egg consumers",
                    "Ever depressed for a whole week", "Ever highly irritable", "Falls in the last year", "Fat removed from meat", "Family relationship satisfaction",
                    "Fed-up feelings", "Financial situation satisfaction", "Fish", "Had menopause", "Heating type(s) in home", "Home area population density",
                    "Ingredients in", "Invitation to complete online 24-hour recall dietary questionnaire", "Job involves",
                    "Length of working week for main job", "Light smokers", "Liquid used", "Maternal smoking around birth", "Menstruating today",
                    "Meat consumers", "Most recent bowel cancer screening", "Neck/shoulder pain", "Noisy workplace", "self-reported",
                    "Other non-alcoholic drinks", "Reason for not eating", "Reason for reducing amount of alcohol", "Savoury snack consumers",
                    "Size of white wine glass drunk", "Soup consumers", "Starchy food consumers", "Sweet snack consumers", "Time from waking to first cigarette",
                    "Tinnitus", "Type of baguette eaten", "Vegetable consumers", "Vitamin supplement user", "Was blood sampling attempted", 
                    "Why stopped smoking", "Yogurt/ice-cream consumers")

# Study categories to filter (extraneous or environmental or duplicated or close-to-dupe or age or economic)
alcohol_studies <- c("ukb-a-226", "ukb-a-227", "ukb-a-25", "ukb-a-32", "ukb-b-16878")
arm_fat <- c("ukb-a-282", "ukb-a-284", "ukb-a-285")
blood_clot <- c("ukb-a-446", "ukb-a-443", "ukb-a-445", "ukb-a-444", "ukb-a-447")
carer_support <- c("ukb-b-5855", "ukb-b-67")
exp_taken <- c("ukb-b-9509", "ukb-b-18674", "ukb-b-18541", "ukb-a-19", "ukb-a-20")
forced_exp <- c("ukb-a-231", "ukb-a-234", "ukb-a-235", "ukb-a-232")
type_of <- c("ukb-b-13896", "ukb-b-16523", "ukb-b-9927", "ukb-b-12863", "ukb-b-6992", "ukb-b-14640", "ukb-b-6448", 
             "ukb-b-8061", "ukb-b-18611", "ukb-b-12780", "ukb-b-8902", "ukb-b-11189", "ukb-b-15768", "ukb-b-14108", "ukb-b-11679", 
             "ukb-a-327", "ukb-b-8659", "ukb-b-12936")
time_spent <- c("ukb-a-7", "ukb-a-6", "ukb-a-5")
pulse_rate <- c("ukb-a-3", "ukb-a-250", "ukb-a-365", "ukb-a-364")
hearing <- "ukb-b-18275"
leg_pain <- c("ukb-b-9054", "ukb-b-10387", "ukb-b-3665", "ukb-b-17291", "ukb-b-12864", "ukb-b-3196")

miscellaneous <- c(
  "ukb-a-362", "ukb-a-239", "ukb-a-252", "ukb-a-387", "ukb-a-237", "ukb-a-292", "ukb-a-293", "ukb-b-7759", 
  "ieu-a-1186", "ukb-b-13183", "ieu-a-801", "ukb-b-15531", "ukb-b-10923", "ieu-b-4819", "ukb-a-31", "ieu-a-45", 
  "ieu-a-806", "ukb-a-318", "ieu-b-40", "ukb-a-248", "ieu-b-35", "ieu-b-25", "ukb-b-266", "ukb-b-7660", "ukb-b-471", 
  "ukb-b-7793", "ieu-b-39", "ukb-a-344", "ukb-a-8", "ukb-a-322", "ukb-a-324", "ieu-a-85", "ieu-b-106", "ukb-a-337", 
  "ieu-b-44", "ukb-b-17554", "ukb-b-15378", "ieu-b-103", "ukb-b-19060", "ukb-a-261", "ukb-b-17469", "ukb-b-4184", 
  "ieu-a-1029", "ukb-b-14649", "ieu-a-1171", "ukb-a-277", "ieu-b-4974", "ieu-a-805", "ieu-a-1025", "ukb-a-230", 
  "ukb-b-19722", "ieu-b-4827", "ieu-b-86", "ukb-a-238", "ukb-b-5954", "ieu-b-4977", "ieu-b-4978", "ieu-a-832", 
  "ukb-a-247", "ukb-a-246", "ukb-b-6991", "ieu-b-69", "ieu-b-4981", "ieu-a-1070", "ukb-b-5863", "ukb-b-2557", 
  "ukb-a-18", "ukb-b-16066", "ieu-b-38", "ukb-a-360", "ieu-a-1051", "ieu-b-111", "ukb-b-11188", "ukb-b-14425", 
  "ukb-a-266", "ukb-a-267", "ukb-b-10857","ukb-a-366","ukb-a-403","ukb-a-510","ukb-b-13799"
)

other_exclusions <- c(alcohol_studies, arm_fat, blood_clot, carer_support, exp_taken, forced_exp, type_of, time_spent, pulse_rate, hearing, leg_pain, miscellaneous)

# Step 1: Exclude studies matching the exclude_studies patterns
ieu_met_prot_filtered <- subset(ieu, 
                    !grepl(paste0("^", exclude_studies, collapse = "|"), id))
                    
# Filter igG
ieu_igg_filtered <- subset(ieu_met_prot_filtered, 
                                 !grepl("IgG levels", trait, ignore.case = TRUE))

# Filter pops
pop_filtered <- subset(ieu_igg_filtered, population %in% include_pops)

# Filter sex
sex_filtered <- subset(pop_filtered, sex %in% include_sex)

# Apply the filtering logic to the remaining data
ieu_filtered <- subset(sex_filtered, 
                       (
                         # Include all priority 0
                         priority == 0
                       ) | (
                         # Include priority 1 only if they satisfy all conditions
                         priority == 1 & 
                         !grepl("IgG", trait, ignore.case = TRUE) &
                         !grepl(paste(exclude_phenos, collapse = "|"), trait, ignore.case = TRUE) &
                         !grepl("Diagnoses - main ICD10: [^FG]", trait) &
                         !(id %in% other_exclusions) &
                         year > 2011
                       )
)
                       
# Exclude rows where 'ukb-b' is in the ID but no cases are listed
ieu_filtered <- subset(ieu_filtered, !(grepl("ukb-b", id) & is.na(ncase)))

# Handle duplicate traits
ieu_filtered <- ieu_filtered[with(ieu_filtered, order(trait, -year, -priority)), ]  # Sort by trait, descending year, descending priority
ieu_filtered <- ieu_filtered[!duplicated(ieu_filtered$trait), ]  # Remove duplicates

# Save to file
write.table(ieu_filtered, file = "filtered_ieugwas_traits.txt", sep = "\t", row.names = FALSE, quote = FALSE)

# for ICD10 keep only:
# F00-F99: Mental and behavioural disorders
# G00-G99: Diseases of the nervous system

# keep all priority 0 studies
# exclude all priority 2+ studies
# exclude year before 2012
# remove 2+ spaces from phrases

# exclude ieu-a-1186	Anorexia Nervosa
# ukb-b-13183	Adopted as a child
# ieu-a-801	Bipolar disorder
# ukb-b-15531	Other non-alcoholic drinks