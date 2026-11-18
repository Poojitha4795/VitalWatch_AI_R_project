
# ==========================================
# VITALWATCH AI
# PHASE 6: MULTIVARIATE ANOMALY DETECTION
# Algorithm: Mahalanobis Distance
# ==========================================

# 1. Load feature-engineered dataset
vital_features <- readRDS("vital_features.rds")

# 2. Define the 14 trend features
feature_columns <- c(
  "Heart_Rate_RollingMean3",
  "Heart_Rate_Change10m",
  "BP_Systolic_RollingMean3",
  "BP_Systolic_Change10m",
  "BP_Diastolic_RollingMean3",
  "BP_Diastolic_Change10m",
  "SpO2_RollingMean3",
  "SpO2_Change10m",
  "Respiration_Rate_RollingMean3",
  "Respiration_Rate_Change10m",
  "Body_Temperature_RollingMean3",
  "Body_Temperature_Change10m",
  "Blood_Glucose_RollingMean3",
  "Blood_Glucose_Change10m"
)

# 3. Keep records with complete features
complete_rows <- complete.cases(
  vital_features[, feature_columns]
)

model_data <- vital_features[
  complete_rows,
  c(
    "Patient_ID",
    "Timestamp",
    "Is_Anomaly",
    "Anomaly_Type",
    feature_columns
  )
]

# 4. Arrange records chronologically
model_data <- model_data[
  order(
    model_data$Timestamp,
    model_data$Patient_ID
  ),
]

cat("\n===== MODEL DATASET =====\n")
cat("Total usable records:", nrow(model_data), "\n")
cat("Number of patients:",
    length(unique(model_data$Patient_ID)), "\n")

# 5. Chronological 70:30 split
unique_times <- sort(unique(model_data$Timestamp))

cutoff_index <- floor(
  length(unique_times) * 0.70
)

cutoff_time <- unique_times[cutoff_index]

cat("\n===== CHRONOLOGICAL SPLIT =====\n")
cat("Training cutoff:", as.character(cutoff_time), "\n")

train_all <- model_data[
  model_data$Timestamp <= cutoff_time,
]

test_data <- model_data[
  model_data$Timestamp > cutoff_time,
]

cat("Training-period records:", nrow(train_all), "\n")
cat("Testing-period records:", nrow(test_data), "\n")

# 6. Initialize model output columns
test_data$Anomaly_Score <- NA_real_
test_data$Model_Prediction <- NA_integer_

# Store patient-specific thresholds
patient_thresholds <- data.frame(
  Patient_ID = integer(),
  Threshold = numeric(),
  Features_Used = integer()
)

# 7. Train one model for each patient
patients <- unique(model_data$Patient_ID)

cat("\n===== MODEL TRAINING STARTED =====\n")

for (pid in patients) {
  
  # Normal training records for this patient
  train_patient <- train_all[
    train_all$Patient_ID == pid &
      train_all$Is_Anomaly == 0,
  ]
  
  # Testing records for this patient
  test_indices <- which(
    test_data$Patient_ID == pid
  )
  
  if (nrow(train_patient) < 100 ||
      length(test_indices) == 0) {
    cat("Skipping patient:", pid, "\n")
    next
  }
  
  # Extract training features
  x_train <- as.matrix(
    train_patient[, feature_columns]
  )
  
  # Calculate training mean and standard deviation
  feature_mean <- colMeans(x_train)
  feature_sd <- apply(x_train, 2, sd)
  
  # Remove constant or invalid features
  usable <- is.finite(feature_mean) &
    is.finite(feature_sd) &
    feature_sd > 1e-8
  
  if (sum(usable) < 2) {
    cat("Insufficient variable features for patient:",
        pid, "\n")
    next
  }
  
  x_train <- x_train[, usable, drop = FALSE]
  
  feature_mean <- feature_mean[usable]
  feature_sd <- feature_sd[usable]
  
  # Standardize training features
  train_scaled <- sweep(
    x_train,
    2,
    feature_mean,
    "-"
  )
  
  train_scaled <- sweep(
    train_scaled,
    2,
    feature_sd,
    "/"
  )
  
  # Calculate covariance matrix
  covariance_matrix <- cov(train_scaled)
  
  # Regularize covariance matrix
  regularized_covariance <-
    covariance_matrix +
    diag(0.05, ncol(train_scaled))
  
  # Calculate Mahalanobis distance for training data
  training_scores <- mahalanobis(
    train_scaled,
    center = colMeans(train_scaled),
    cov = regularized_covariance
  )
  
  # Determine 99th percentile threshold
  threshold <- as.numeric(
    quantile(training_scores, 0.99)
  )
  
  # Extract test features
  x_test <- as.matrix(
    test_data[test_indices, feature_columns]
  )
  
  x_test <- x_test[, usable, drop = FALSE]
  
  # Standardize test data using training parameters
  test_scaled <- sweep(
    x_test,
    2,
    feature_mean,
    "-"
  )
  
  test_scaled <- sweep(
    test_scaled,
    2,
    feature_sd,
    "/"
  )
  
  # Calculate test Mahalanobis distances
  test_scores <- mahalanobis(
    test_scaled,
    center = colMeans(train_scaled),
    cov = regularized_covariance
  )
  
  # Store anomaly scores
  test_data$Anomaly_Score[test_indices] <-
    test_scores
  
  # Predict anomalies
  test_data$Model_Prediction[test_indices] <-
    as.integer(test_scores > threshold)
  
  # Store patient threshold
  patient_thresholds <- rbind(
    patient_thresholds,
    data.frame(
      Patient_ID = pid,
      Threshold = threshold,
      Features_Used = sum(usable)
    )
  )
}

# 8. Check model results
cat("\n===== MODEL RESULTS =====\n")

cat("Test records scored:",
    sum(!is.na(test_data$Anomaly_Score)), "\n")

cat("Unscored test records:",
    sum(is.na(test_data$Anomaly_Score)), "\n")

cat("\n===== PATIENT THRESHOLDS =====\n")
print(patient_thresholds)

cat("\n===== PREDICTED ANOMALIES =====\n")
print(
  table(
    test_data$Model_Prediction,
    useNA = "ifany"
  )
)

# 9. Save model results
saveRDS(
  test_data,
  file = "vital_anomaly_results.rds"
)

saveRDS(
  patient_thresholds,
  file = "patient_thresholds.rds"
)

cat("\nANOMALY DETECTION COMPLETED!\n")


nrow(train_all)
nrow(test_data)
sum(!is.na(test_data$Anomaly_Score))
table(test_data$Model_Prediction, useNA = "ifany")
print(patient_thresholds)
file.exists("vital_anomaly_results.rds")



cat("Model completed:", file.exists("vital_anomaly_results.rds"), "\n")

cat("Test records:", nrow(test_data), "\n")

cat("Records scored:",
    sum(!is.na(test_data$Anomaly_Score)), "\n")

cat("Predicted anomalies:\n")
print(table(test_data$Model_Prediction, useNA = "ifany"))

table(test_data$Model_Prediction, useNA = "ifany")