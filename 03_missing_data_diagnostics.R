
# ==========================================
# VITALWATCH AI
# PHASE 3: MISSING DATA INVESTIGATION
# ==========================================

# Vital-sign columns
vital_columns <- c(
  "Heart_Rate",
  "SpO2",
  "Respiration_Rate",
  "BP_Systolic",
  "BP_Diastolic",
  "Body_Temperature",
  "Blood_Glucose"
)

# 1. Count missing vital-sign values in each row
missing_count <- rowSums(
  is.na(vital_eda[, vital_columns])
)

cat("\n===== MISSING VALUES PER RECORD =====\n")
print(table(missing_count))

# 2. Check whether missing records are anomalous
cat("\n===== DATA QUALITY VS ANOMALY =====\n")
print(table(
  vital_eda$Data_Quality_Flag,
  vital_eda$Is_Anomaly,
  useNA = "ifany"
))

# 3. Check missing-data mechanisms
cat("\n===== MISSING MECHANISMS =====\n")
print(table(
  vital_eda$Missing_Mechanism,
  useNA = "ifany"
))

# 4. Check missing mechanisms only
# among records flagged as missing
missing_rows <- vital_eda[
  vital_eda$Data_Quality_Flag == "missing",
]

cat("\n===== MISSING RECORD DETAILS =====\n")
print(table(
  missing_rows$Missing_Mechanism,
  useNA = "ifany"
))

# 5. Check anomaly types among missing records
cat("\n===== ANOMALY TYPES IN MISSING RECORDS =====\n")
print(table(
  missing_rows$Anomaly_Type,
  useNA = "ifany"
))

# 6. Check sensor-error records
sensor_rows <- vital_eda[
  vital_eda$Data_Quality_Flag == "sensor_error",
]

cat("\n===== SENSOR ERROR DETAILS =====\n")
print(table(
  sensor_rows$Anomaly_Type,
  useNA = "ifany"
))

# 7. Check missing records for each patient
missing_by_patient <- aggregate(
  missing_count,
  by = list(Patient_ID = vital_eda$Patient_ID),
  FUN = sum
)

names(missing_by_patient)[2] <- "Missing_Values"

cat("\n===== PATIENTS WITH MOST MISSING VALUES =====\n")
print(
  head(
    missing_by_patient[
      order(-missing_by_patient$Missing_Values),
    ],
    10
  )
)

# 8. Display some missing records
cat("\n===== SAMPLE MISSING RECORDS =====\n")
print(
  head(
    vital_eda[
      missing_count > 0,
      c(
        "Patient_ID",
        "Timestamp",
        "Heart_Rate",
        "SpO2",
        "Respiration_Rate",
        "Is_Anomaly",
        "Anomaly_Type",
        "Data_Quality_Flag",
        "Missing_Mechanism"
      )
    ],
    10
  )
)

cat("\nMissing-data investigation completed!\n")
