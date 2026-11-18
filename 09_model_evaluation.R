# PHASE 9: MODEL EVALUATION

library(dplyr)

# Load anomaly detection results
results_eval <- readRDS("vital_anomaly_results.rds")

# Load filtered model results
filtered_results <- readRDS("vital_filtered_results.rds")

# Load performance comparison
performance_data <- read.csv(
  "model_performance_comparison.csv"
)

# Display dataset dimensions
cat("Raw model results:\n")
print(dim(results_eval))

cat("\nFiltered model results:\n")
print(dim(filtered_results))

cat("\nPerformance comparison:\n")
print(performance_data)







# DISPLAY MODEL PERFORMANCE

cat("\nRAW MODEL PERFORMANCE:\n")
print(performance_data[performance_data$Method == "Raw Model", ])

cat("\nFILTERED MODEL PERFORMANCE:\n")
print(performance_data[performance_data$Method == "2-out-of-3 Filter", ])

cat("\nRAW MODEL PREDICTION DISTRIBUTION:\n")
print(table(results_eval$Model_Prediction))

cat("\nACTUAL ANOMALY DISTRIBUTION:\n")
print(table(results_eval$Is_Anomaly))







# STEP 3: CONFUSION MATRIX

# Function to calculate confusion matrix
calculate_confusion <- function(actual, predicted) {
  
  valid <- !is.na(actual) & !is.na(predicted)
  
  actual <- actual[valid]
  predicted <- predicted[valid]
  
  matrix_result <- table(
    Actual = factor(actual, levels = c(0, 1)),
    Predicted = factor(predicted, levels = c(0, 1))
  )
  
  return(matrix_result)
}

# Raw model confusion matrix
raw_confusion <- calculate_confusion(
  results_eval$Is_Anomaly,
  results_eval$Model_Prediction
)

# Filtered model confusion matrix
filtered_confusion <- calculate_confusion(
  filtered_results$Is_Anomaly,
  filtered_results$Filtered_Prediction
)

cat("\nRAW MODEL CONFUSION MATRIX:\n")
print(raw_confusion)

cat("\nFILTERED MODEL CONFUSION MATRIX:\n")
print(filtered_confusion)




print(raw_confusion)
print(filtered_confusion)







# STEP 4: PATIENT-WISE MODEL EVALUATION

patient_performance <- results_eval %>%
  group_by(Patient_ID) %>%
  summarise(
    Total_Readings = n(),
    
    Actual_Anomalies = sum(Is_Anomaly == 1),
    
    Predicted_Anomalies = sum(Model_Prediction == 1),
    
    True_Positives = sum(
      Is_Anomaly == 1 & Model_Prediction == 1
    ),
    
    False_Positives = sum(
      Is_Anomaly == 0 & Model_Prediction == 1
    ),
    
    False_Negatives = sum(
      Is_Anomaly == 1 & Model_Prediction == 0
    ),
    
    .groups = "drop"
  )

cat("PATIENT-WISE MODEL PERFORMANCE:\n")
print(patient_performance)

# Save patient-wise results
write.csv(
  patient_performance,
  "patient_wise_performance.csv",
  row.names = FALSE
)

cat("\nFile saved successfully:\n")
print(file.exists("patient_wise_performance.csv"))





print(patient_performance)

cat("\nNumber of patients evaluated:\n")
print(nrow(patient_performance))

cat("\nSaved file verification:\n")
print(file.exists("patient_wise_performance.csv"))





head(patient_performance, 20)
nrow(patient_performance)
file.exists("patient_wise_performance.csv")



print(patient_performance)








# STEP 5: PATIENT-WISE EVALUATION METRICS

patient_performance <- patient_performance %>%
  mutate(
    True_Negatives = Total_Readings -
      True_Positives -
      False_Positives -
      False_Negatives,
    
    Precision = ifelse(
      True_Positives + False_Positives > 0,
      True_Positives /
        (True_Positives + False_Positives),
      0
    ),
    
    Recall = ifelse(
      True_Positives + False_Negatives > 0,
      True_Positives /
        (True_Positives + False_Negatives),
      0
    ),
    
    Specificity = ifelse(
      True_Negatives + False_Positives > 0,
      True_Negatives /
        (True_Negatives + False_Positives),
      0
    ),
    
    F1_Score = ifelse(
      Precision + Recall > 0,
      2 * Precision * Recall /
        (Precision + Recall),
      0
    )
  )

cat("PATIENT-WISE EVALUATION METRICS:\n")
print(patient_performance, width = Inf)

# Save updated evaluation
write.csv(
  patient_performance,
  "patient_wise_performance.csv",
  row.names = FALSE
)








print(
  patient_performance %>%
    select(
      Patient_ID,
      Precision,
      Recall,
      Specificity,
      F1_Score
    ),
  n = 20
)

cat("\nUpdated file verification:\n")
print(file.exists("patient_wise_performance.csv"))







