
# ==========================================
# VITALWATCH AI - DATASET INSPECTION
# ==========================================

# Select the downloaded CSV dataset
vital_data <- read.csv(
  file.choose(),
  stringsAsFactors = FALSE
)

# Display first 6 records
head(vital_data)

# Display dataset structure
str(vital_data)

# Display column names
colnames(vital_data)

# Display number of rows and columns
dim(vital_data)

# Display summary
summary(vital_data)

# Check missing values
colSums(is.na(vital_data))

# Check duplicate records
sum(duplicated(vital_data))

# Display dataset in table format
View(vital_data)
