
# ==========================================
# VITALWATCH AI
# PHASE 4: DATA PREPARATION
# ==========================================

# 1. Define vital-sign columns
vital_columns <- c(
  "Heart_Rate",
  "BP_Systolic",
  "BP_Diastolic",
  "SpO2",
  "Respiration_Rate",
  "Body_Temperature",
  "Blood_Glucose"
)

# 2. Keep only records marked as valid
vital_clean <- vital_eda[
  vital_eda$Data_Quality_Flag == "valid",
]

cat("\n===== VALID RECORDS =====\n")
cat("Records before filtering:",
    nrow(vital_eda), "\n")

cat("Valid records:",
    nrow(vital_clean), "\n")

# 3. Check missing values in vital signs
cat("\n===== MISSING VALUES CHECK =====\n")
print(colSums(is.na(
  vital_clean[, vital_columns]
)))

# 4. Remove any remaining records
# with missing vital-sign measurements
complete_rows <- complete.cases(
  vital_clean[, vital_columns]
)

vital_clean <- vital_clean[complete_rows, ]

cat("\nRecords after completeness check:",
    nrow(vital_clean), "\n")

# 5. Arrange records by patient and timestamp
vital_clean <- vital_clean[
  order(
    vital_clean$Patient_ID,
    vital_clean$Timestamp
  ),
]

# 6. Check duplicate patient-time records
duplicate_count <- sum(
  duplicated(
    vital_clean[, c("Patient_ID", "Timestamp")]
  )
)

cat("\n===== DUPLICATE CHECK =====\n")
cat("Duplicate patient-time records:",
    duplicate_count, "\n")

# 7. Check anomaly distribution
cat("\n===== ANOMALY DISTRIBUTION =====\n")
print(table(vital_clean$Is_Anomaly))

# 8. Check anomaly categories
cat("\n===== ANOMALY TYPES =====\n")
print(table(vital_clean$Anomaly_Type))

# 9. Check patient count
cat("\n===== PATIENT COUNT =====\n")
cat(
  "Number of patients:",
  length(unique(vital_clean$Patient_ID)),
  "\n"
)

# 10. Check dataset structure
cat("\n===== CLEAN DATASET STRUCTURE =====\n")
str(vital_clean)

# 11. Save the prepared dataset
saveRDS(
  vital_clean,
  file = "vital_clean.rds"
)

cat("\nClean dataset saved as vital_clean.rds\n")
cat("DATA PREPARATION COMPLETED!\n")
