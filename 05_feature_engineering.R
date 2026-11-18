
# ==========================================
# VITALWATCH AI
# PHASE 5: TREND-AWARE FEATURE ENGINEERING
# ==========================================

# Load clean data if it is not already in memory
if (!exists("vital_clean")) {
  vital_clean <- readRDS("vital_clean.rds")
}

# 1. Define the vital-sign columns
vital_columns <- c(
  "Heart_Rate",
  "BP_Systolic",
  "BP_Diastolic",
  "SpO2",
  "Respiration_Rate",
  "Body_Temperature",
  "Blood_Glucose"
)

# 2. Arrange data chronologically for each patient
vital_clean <- vital_clean[
  order(
    vital_clean$Patient_ID,
    vital_clean$Timestamp
  ),
]

# 3. Create names for the new features
feature_columns <- unlist(
  lapply(vital_columns, function(v) {
    c(
      paste0(v, "_RollingMean3"),
      paste0(v, "_Change10m")
    )
  })
)

# Initialize new feature columns
for (feature in feature_columns) {
  vital_clean[[feature]] <- NA_real_
}

# 4. Divide the dataset patient-wise
patient_indices <- split(
  seq_len(nrow(vital_clean)),
  vital_clean$Patient_ID
)

cat("\n===== FEATURE ENGINEERING STARTED =====\n")

# 5. Process each patient separately
for (patient_id in names(patient_indices)) {
  
  patient_rows <- patient_indices[[patient_id]]
  
  # Detect gaps in 10-minute readings
  time_values <- as.numeric(
    vital_clean$Timestamp[patient_rows]
  )
  
  new_segment <- c(
    TRUE,
    diff(time_values) != 600
  )
  
  # Create separate continuous time segments
  segment_id <- cumsum(new_segment)
  
  segments <- split(
    patient_rows,
    segment_id
  )
  
  # 6. Calculate features within each continuous segment
  for (segment_rows in segments) {
    
    for (v in vital_columns) {
      
      x <- vital_clean[[v]][segment_rows]
      
      n <- length(x)
      
      # Rolling mean of current and previous 2 readings
      rolling_mean <- rep(NA_real_, n)
      
      if (n >= 3) {
        
        cumulative_sum <- c(0, cumsum(x))
        
        rolling_mean[3:n] <- (
          cumulative_sum[4:(n + 1)] -
            cumulative_sum[1:(n - 2)]
        ) / 3
      }
      
      # Change from previous 10-minute reading
      change_10m <- c(NA_real_, diff(x))
      
      # Store the new features
      vital_clean[
        segment_rows,
        paste0(v, "_RollingMean3")
      ] <- rolling_mean
      
      vital_clean[
        segment_rows,
        paste0(v, "_Change10m")
      ] <- change_10m
    }
  }
}

# 7. Check the newly created features
cat("\n===== NEW FEATURE COLUMNS =====\n")
print(feature_columns)

# 8. Count complete feature records
complete_feature_rows <- complete.cases(
  vital_clean[, feature_columns]
)

cat("\n===== FEATURE COMPLETENESS =====\n")

cat(
  "Total records:",
  nrow(vital_clean),
  "\n"
)

cat(
  "Records with complete features:",
  sum(complete_feature_rows),
  "\n"
)

cat(
  "Records without complete features:",
  sum(!complete_feature_rows),
  "\n"
)

# 9. Display sample feature values
cat("\n===== SAMPLE FEATURE VALUES =====\n")

print(
  head(
    vital_clean[
      ,
      c(
        "Patient_ID",
        "Timestamp",
        "Heart_Rate",
        "Heart_Rate_RollingMean3",
        "Heart_Rate_Change10m",
        "SpO2",
        "SpO2_RollingMean3",
        "SpO2_Change10m"
      )
    ],
    10
  )
)

# 10. Save the feature-engineered dataset
saveRDS(
  vital_clean,
  file = "vital_features.rds"
)

cat("\nFeature-engineered dataset saved successfully!\n")
cat("FEATURE ENGINEERING COMPLETED!\n")


print(feature_columns)
sum(complete_feature_rows)
sum(!complete_feature_rows)
length(unique(vital_clean$Patient_ID))
file.exists("vital_features.rds")