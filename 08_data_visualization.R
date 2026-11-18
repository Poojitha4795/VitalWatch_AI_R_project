# PHASE 8: DATA VISUALIZATION

# Load required package
library(ggplot2)
library(dplyr)

# Load prepared dataset
vital_clean <- readRDS("vital_clean.rds")

# Load feature-engineered dataset
vital_features <- readRDS("vital_features.rds")

# Load anomaly detection results
results_check <- readRDS("vital_anomaly_results.rds")

# Check datasets
cat("Clean dataset dimensions:\n")
print(dim(vital_clean))

cat("\nFeature dataset dimensions:\n")
print(dim(vital_features))

cat("\nAnomaly results dimensions:\n")
print(dim(results_check))





# GRAPH 1: HEART RATE TREND

# Select one patient
selected_patient <- vital_clean %>%
  filter(Patient_ID == 1) %>%
  arrange(Timestamp)

# Create heart rate trend graph
ggplot(selected_patient,
       aes(x = Timestamp, y = Heart_Rate)) +
  geom_line(color = "blue", linewidth = 0.5) +
  labs(
    title = "Heart Rate Trend Over Time - Patient 1",
    x = "Date and Time",
    y = "Heart Rate (BPM)"
  ) +
  theme_minimal()



# GRAPH 2: NORMAL VS ANOMALOUS READINGS

anomaly_counts <- vital_clean %>%
  mutate(
    Status = ifelse(Is_Anomaly == 1, "Anomalous", "Normal")
  ) %>%
  count(Status)

ggplot(anomaly_counts,
       aes(x = Status, y = n, fill = Status)) +
  geom_col() +
  labs(
    title = "Normal vs Anomalous Patient Readings",
    x = "Reading Status",
    y = "Number of Readings"
  ) +
  theme_minimal()






# GRAPH 3: ANOMALY SCORE DISTRIBUTION

ggplot(results_check, aes(x = Anomaly_Score)) +
  geom_histogram(
    bins = 50,
    fill = "skyblue",
    color = "black"
  ) +
  labs(
    title = "Distribution of Anomaly Scores",
    x = "Anomaly Score",
    y = "Frequency"
  ) +
  theme_minimal()






# GRAPH 4: ACTUAL VS PREDICTED ANOMALIES

prediction_comparison <- data.frame(
  Category = c(
    "Actual Normal",
    "Actual Anomalous",
    "Predicted Normal",
    "Predicted Anomalous"
  ),
  Count = c(
    sum(results_check$Is_Anomaly == 0),
    sum(results_check$Is_Anomaly == 1),
    sum(results_check$Model_Prediction == 0),
    sum(results_check$Model_Prediction == 1)
  )
)

ggplot(prediction_comparison,
       aes(x = Category, y = Count, fill = Category)) +
  geom_col() +
  labs(
    title = "Actual vs Predicted Anomaly Readings",
    x = "Category",
    y = "Number of Readings"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))








# GRAPH 5: MODEL PERFORMANCE COMPARISON

# Load Phase 7 performance results
performance_data <- read.csv(
  "model_performance_comparison.csv"
)

# Prepare data for visualization
performance_long <- rbind(
  data.frame(
    Method = performance_data$Method,
    Metric = "Accuracy",
    Value = performance_data$Accuracy
  ),
  data.frame(
    Method = performance_data$Method,
    Metric = "Precision",
    Value = performance_data$Precision
  ),
  data.frame(
    Method = performance_data$Method,
    Metric = "Recall",
    Value = performance_data$Recall
  ),
  data.frame(
    Method = performance_data$Method,
    Metric = "Specificity",
    Value = performance_data$Specificity
  ),
  data.frame(
    Method = performance_data$Method,
    Metric = "F1 Score",
    Value = performance_data$F1_Score
  )
)

# Create comparison graph
ggplot(
  performance_long,
  aes(x = Metric, y = Value, fill = Method)
) +
  geom_col(position = "dodge") +
  labs(
    title = "Raw Model vs Filtered Model Performance",
    x = "Evaluation Metrics",
    y = "Performance Score",
    fill = "Model"
  ) +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal()







