
# ==========================================
# VITALWATCH AI
# PHASE 2: EXPLORATORY DATA ANALYSIS
# ==========================================

# Work on a separate copy of the original dataset
vital_eda <- vital_data

# 1. Convert Timestamp into date-time format
vital_eda$Timestamp <- as.POSIXct(
  vital_eda$Timestamp,
  format = "%Y-%m-%d %H:%M:%S",
  tz = "UTC"
)

cat("\n========== DATASET OVERVIEW ==========\n")

# 2. Dataset dimensions
cat("Total records:", nrow(vital_eda), "\n")
cat("Total columns:", ncol(vital_eda), "\n")

# 3. Number of unique patients
cat("Number of patients:",
    length(unique(vital_eda$Patient_ID)), "\n")

# 4. Date and time range
cat("\n========== TIMESTAMP DETAILS ==========\n")
print(range(vital_eda$Timestamp, na.rm = TRUE))

cat("Invalid timestamps:",
    sum(is.na(vital_eda$Timestamp)), "\n")

# 5. Check missing values
cat("\n========== MISSING VALUES ==========\n")
print(colSums(is.na(vital_eda)))

# 6. Check duplicate records
cat("\n========== DUPLICATE RECORDS ==========\n")
cat("Duplicate complete rows:",
    sum(duplicated(vital_eda)), "\n")

cat("Duplicate patient-time records:",
    sum(duplicated(
      vital_eda[c("Patient_ID", "Timestamp")]
    )), "\n")

# 7. Check anomaly distribution
cat("\n========== ANOMALY DISTRIBUTION ==========\n")
print(table(vital_eda$Is_Anomaly, useNA = "ifany"))

# 8. Check anomaly categories
cat("\n========== ANOMALY TYPES ==========\n")
print(table(vital_eda$Anomaly_Type, useNA = "ifany"))

# 9. Check data quality
cat("\n========== DATA QUALITY ==========\n")
print(table(vital_eda$Data_Quality_Flag,
            useNA = "ifany"))

# 10. Summary of vital signs
cat("\n========== VITAL SIGN SUMMARY ==========\n")

print(summary(vital_eda[, c(
  "Heart_Rate",
  "BP_Systolic",
  "BP_Diastolic",
  "SpO2",
  "Respiration_Rate",
  "Body_Temperature",
  "Blood_Glucose"
)]))

# 11. Check time interval between readings
cat("\n========== TIME INTERVAL CHECK ==========\n")

ordered_rows <- order(
  vital_eda$Patient_ID,
  vital_eda$Timestamp
)

patient_sorted <- vital_eda$Patient_ID[ordered_rows]
time_sorted <- vital_eda$Timestamp[ordered_rows]

same_patient <- patient_sorted[-1] ==
  patient_sorted[-length(patient_sorted)]

time_intervals <- as.numeric(
  difftime(
    time_sorted[-1][same_patient],
    time_sorted[-length(time_sorted)][same_patient],
    units = "mins"
  )
)

print(head(sort(table(time_intervals),
                decreasing = TRUE), 10))

# 12. Visualize anomaly distribution
barplot(
  table(vital_eda$Is_Anomaly, useNA = "ifany"),
  main = "Normal vs Anomalous Records",
  xlab = "Anomaly Label",
  ylab = "Number of Records"
)

# 13. Visualize heart rate distribution
hist(
  vital_eda$Heart_Rate,
  breaks = 50,
  main = "Heart Rate Distribution",
  xlab = "Heart Rate",
  ylab = "Frequency"
)

cat("\nEDA completed successfully!\n")
