
# ==========================================
# VITALWATCH AI
# PHASE 7: FALSE ALERT REDUCTION
# 2-OUT-OF-3 PERSISTENCE RULE
# ==========================================

# 1. Load anomaly detection results
test_data <- readRDS("vital_anomaly_results.rds")

# 2. Arrange data patient-wise and chronologically
test_data <- test_data[
  order(test_data$Patient_ID, test_data$Timestamp),
]

# 3. Create a new column for filtered predictions
test_data$Filtered_Prediction <- NA_integer_

# 4. Process each patient separately
patient_indices <- split(
  seq_len(nrow(test_data)),
  test_data$Patient_ID
)

for (pid in names(patient_indices)) {
  
  rows <- patient_indices[[pid]]
  
  # Identify gaps in the 10-minute readings
  times <- as.numeric(test_data$Timestamp[rows])
  
  new_segment <- c(TRUE, diff(times) != 600)
  
  segment_id <- cumsum(new_segment)
  
  segments <- split(rows, segment_id)
  
  # 5. Apply persistence rule within each segment
  for (segment_rows in segments) {
    
    predictions <- test_data$Model_Prediction[
      segment_rows
    ]
    
    filtered <- rep(NA_integer_, length(predictions))
    
    for (i in seq_along(predictions)) {
      
      # Use up to the current and previous 2 readings
      start_index <- max(1, i - 2)
      
      recent_predictions <- predictions[
        start_index:i
      ]
      
      # Do not calculate if any prediction is unavailable
      if (anyNA(recent_predictions)) {
        next
      }
      
      # At least 2 anomalous predictions are required
      filtered[i] <- as.integer(
        sum(recent_predictions == 1) >= 2
      )
    }
    
    test_data$Filtered_Prediction[
      segment_rows
    ] <- filtered
  }
}

# 6. Compare raw and filtered predictions
cat("\n===== RAW PREDICTIONS =====\n")
print(table(
  test_data$Model_Prediction,
  useNA = "ifany"
))

cat("\n===== FILTERED PREDICTIONS =====\n")
print(table(
  test_data$Filtered_Prediction,
  useNA = "ifany"
))

# 7. Calculate evaluation metrics
calculate_metrics <- function(actual, predicted) {
  
  valid <- !is.na(actual) & !is.na(predicted)
  
  actual <- actual[valid]
  predicted <- predicted[valid]
  
  TP <- sum(actual == 1 & predicted == 1)
  TN <- sum(actual == 0 & predicted == 0)
  FP <- sum(actual == 0 & predicted == 1)
  FN <- sum(actual == 1 & predicted == 0)
  
  precision <- ifelse(TP + FP == 0, 0,
                      TP / (TP + FP))
  
  recall <- ifelse(TP + FN == 0, 0,
                   TP / (TP + FN))
  
  specificity <- ifelse(TN + FP == 0, 0,
                        TN / (TN + FP))
  
  f1 <- ifelse(
    precision + recall == 0,
    0,
    2 * precision * recall /
      (precision + recall)
  )
  
  accuracy <- (TP + TN) /
    (TP + TN + FP + FN)
  
  data.frame(
    TP = TP,
    TN = TN,
    FP = FP,
    FN = FN,
    Accuracy = accuracy,
    Precision = precision,
    Recall = recall,
    Specificity = specificity,
    F1_Score = f1
  )
}

# 8. Evaluate raw predictions
raw_metrics <- calculate_metrics(
  test_data$Is_Anomaly,
  test_data$Model_Prediction
)

# 9. Evaluate filtered predictions
filtered_metrics <- calculate_metrics(
  test_data$Is_Anomaly,
  test_data$Filtered_Prediction
)

cat("\n===== RAW MODEL METRICS =====\n")
print(raw_metrics)

cat("\n===== FILTERED MODEL METRICS =====\n")
print(filtered_metrics)

# 10. Combine comparison
comparison <- rbind(
  cbind(Method = "Raw Model", raw_metrics),
  cbind(Method = "2-out-of-3 Filter", filtered_metrics)
)

cat("\n===== PERFORMANCE COMPARISON =====\n")
print(comparison)

# 11. Save results
saveRDS(
  test_data,
  file = "vital_filtered_results.rds"
)

write.csv(
  comparison,
  file = "model_performance_comparison.csv",
  row.names = FALSE
)

cat("\nFalse-alert reduction completed!\n")
cat("Results saved successfully!\n")


table(test_data$Model_Prediction, useNA = "ifany")
table(test_data$Filtered_Prediction, useNA = "ifany")
print(raw_metrics)
print(filtered_metrics)
print(comparison)
file.exists("vital_filtered_results.rds")
file.exists("model_performance_comparison.csv")



cat("\nRAW PREDICTIONS\n")
print(table(test_data$Model_Prediction, useNA = "ifany"))

cat("\nFILTERED PREDICTIONS\n")
print(table(test_data$Filtered_Prediction, useNA = "ifany"))

cat("\nRAW MODEL METRICS\n")
print(raw_metrics)

cat("\nFILTERED MODEL METRICS\n")
print(filtered_metrics)

cat("\nPERFORMANCE COMPARISON\n")
print(comparison)

cat("\nFILE VERIFICATION\n")
print(file.exists("vital_filtered_results.rds"))
print(file.exists("model_performance_comparison.csv"))



print(raw_metrics)
print(filtered_metrics)
print(comparison)




results_check <- readRDS("vital_anomaly_results.rds")

cat("Column names:\n")
print(names(results_check))

cat("\nFirst 6 records:\n")
print(head(results_check))




cat("RESULT COLUMNS:\n")
print(names(results_check))

cat("\nPATIENT THRESHOLD DETAILS:\n")
patient_thresholds <- readRDS("patient_thresholds.rds")
str(patient_thresholds)




cat("ANOMALY SCORE SUMMARY:\n")
print(summary(results_check$Anomaly_Score))

cat("\nPATIENT THRESHOLDS:\n")
print(patient_thresholds)

cat("\nMODEL PREDICTION COUNTS:\n")
print(table(results_check$Model_Prediction))












library(dplyr)

alert_check <- results_check %>%
  arrange(Patient_ID, Timestamp) %>%
  group_by(Patient_ID) %>%
  mutate(
    Previous_Prediction = lag(Model_Prediction),
    New_Alert = ifelse(
      Model_Prediction == 1 &
        (is.na(Previous_Prediction) | Previous_Prediction == 0),
      1, 0
    )
  ) %>%
  ungroup()

cat("Total anomaly predictions:\n")
print(sum(results_check$Model_Prediction == 1))

cat("\nNumber of separate alert episodes:\n")
print(sum(alert_check$New_Alert == 1))

cat("\nAlert episodes by patient:\n")
print(
  alert_check %>%
    group_by(Patient_ID) %>%
    summarise(Alert_Episodes = sum(New_Alert), .groups = "drop")
)










cat("Total anomaly predictions:\n")
print(sum(results_check$Model_Prediction == 1))

cat("\nNumber of separate alert episodes:\n")
print(sum(alert_check$New_Alert == 1))

cat("\nAlert episodes by patient:\n")
print(
  alert_check %>%
    group_by(Patient_ID) %>%
    summarise(
      Alert_Episodes = sum(New_Alert),
      .groups = "drop"
    )
)





sum(results_check$Model_Prediction == 1)
sum(alert_check$New_Alert == 1)



alert_check <- results_check %>%
  arrange(Patient_ID, Timestamp) %>%
  
  
  
  
  
  
  
  
  
  
  
  
  
  alert_check <- alert_check %>%
  group_by(Patient_ID) %>%
  mutate(
    Episode_Number = cumsum(New_Alert),
    Alert_Episode_ID = ifelse(
      Model_Prediction == 1,
      paste(Patient_ID, Episode_Number, sep = "_"),
      NA_character_
    )
  ) %>%
  ungroup()

alert_episodes <- alert_check %>%
  filter(Model_Prediction == 1) %>%
  group_by(Patient_ID, Alert_Episode_ID) %>%
  summarise(
    Start_Time = min(Timestamp),
    End_Time = max(Timestamp),
    Duration_Minutes = as.numeric(
      difftime(max(Timestamp), min(Timestamp), units = "mins")
    ),
    Anomaly_Readings = n(),
    Actual_Anomaly_Readings = sum(Is_Anomaly == 1, na.rm = TRUE),
    .groups = "drop"
  )

cat("Total alert episodes:\n")
print(nrow(alert_episodes))

cat("\nFirst 10 alert episodes:\n")
print(head(alert_episodes, 10))

cat("\nAverage episode duration:\n")
print(mean(alert_episodes$Duration_Minutes))

saveRDS(alert_episodes, "vital_alert_episodes.rds")

write.csv(
  alert_episodes,
  "vital_alert_episodes.csv",
  row.names = FALSE
)

cat("\nFiles saved:\n")
print(file.exists("vital_alert_episodes.rds"))
print(file.exists("vital_alert_episodes.csv"))
  group_by(Patient_ID) %>%
  mutate(
    Previous_Prediction = lag(Model_Prediction),
    Time_Gap = as.numeric(
      difftime(Timestamp, lag(Timestamp), units = "secs")
    ),
    New_Alert = ifelse(
      Model_Prediction == 1 &
        (
          is.na(Previous_Prediction) |
            Previous_Prediction == 0 |
            Time_Gap != 600
        ),
      1, 0
    )
  ) %>%
  ungroup()

cat("Original anomaly predictions:\n")
print(sum(results_check$Model_Prediction == 1))

cat("\nCorrected alert episodes:\n")
print(sum(alert_check$New_Alert == 1))



names(results_check)
names(alert_check)