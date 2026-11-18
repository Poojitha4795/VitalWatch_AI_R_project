# VitaTrend-Anomaly-Engine

### Trend-Aware Multivariate Anomaly Detection for Patient Vital-Sign Monitoring with Reduced False Alerts

## 📌 Project Overview

VitaTrend-Anomaly-Engine is an R-based healthcare monitoring project that uses trend-aware multivariate anomaly detection to identify unusual patterns in patient vital signs.

The system analyzes multiple physiological measurements and their temporal trends to detect anomalous readings. It uses Mahalanobis Distance-based anomaly detection and evaluates a temporal filtering approach to study false-alert reduction.

An interactive dashboard built using R Shiny allows users to select patients and explore anomaly scores, predictions, and model performance.

> **Note:** This project uses a synthetic healthcare dataset and is developed for academic and research purposes. It is not a clinically validated diagnostic or medical alert system.

## 🎯 Project Objectives

- Analyze patient vital-sign measurements.
- Perform data preprocessing and missing-data analysis.
- Extract trend-aware features from physiological measurements.
- Apply multivariate anomaly detection.
- Evaluate model performance using standard classification metrics.
- Investigate temporal filtering for reducing false alerts.
- Develop an interactive patient monitoring dashboard using R Shiny.

## 📊 Dataset Description

**Dataset:** Synthetic Health Monitoring Dataset – 100 Patients

**Source:** [Kaggle Dataset](https://www.kaggle.com/datasets/shrishagrawal/synthetic-health-dataanomaly-100patients10-min)

The selected stratified dataset contains:

- 1,051,200 records
- 20 patients
- 22 columns
- 10-minute nominal sampling intervals
- Data covering January–December 2025

### Important Features

| Feature | Description |
|---|---|
| Patient_ID | Unique patient identifier |
| Timestamp | Measurement timestamp |
| Heart_Rate | Heart rate |
| BP_Systolic | Systolic blood pressure |
| BP_Diastolic | Diastolic blood pressure |
| SpO2 | Blood oxygen saturation |
| Respiration_Rate | Respiratory rate |
| Body_Temperature | Body temperature |
| Blood_Glucose | Blood glucose level |
| Is_Anomaly | Actual anomaly label |
| Anomaly_Type | Type of anomaly |

## ⚙️ Technologies Used

- **Programming Language:** R
- **IDE:** RStudio
- **Data Processing:** dplyr, tidyverse
- **Data Visualization:** ggplot2
- **Machine Learning:** Mahalanobis Distance
- **Dashboard:** Shiny
- **Deployment:** shinyapps.io
- **Version Control:** Git and GitHub

## 🔍 Project Methodology

### 1. Data Inspection and Exploratory Data Analysis

- Examined dataset structure and dimensions.
- Analyzed patient records and vital-sign distributions.
- Identified missing values and anomaly categories.

### 2. Data Preprocessing

- Removed records with invalid sensor quality flags.
- Excluded incomplete physiological measurements.
- Removed duplicate patient-timestamp records.
- Sorted observations chronologically.

### 3. Trend-Aware Feature Engineering

Created rolling mean and short-term change features for six vital signs.

**Rolling Mean:**

Calculates the average of the current observation and previous two observations.

**10-Minute Change:**

Calculates the difference between the current and previous observation.

A total of 14 trend-aware features were generated.

### 4. Multivariate Anomaly Detection

Applied Mahalanobis Distance to identify unusual combinations of vital-sign measurements and trend features.

- Used normal training observations.
- Standardized the features.
- Applied covariance regularization.
- Calculated patient-specific anomaly thresholds.
- Evaluated the model on later chronological observations.

### 5. False-Alert Reduction Experiment

A temporal filtering approach was evaluated using consecutive anomaly predictions.

The experiment did not improve the overall classification performance. The results are reported honestly as part of the model evaluation.

### 6. Model Evaluation

The model was evaluated using:

- Accuracy
- Precision
- Recall
- Specificity
- F1-Score
- Confusion Matrix

### 7. Interactive Dashboard

The R Shiny dashboard provides:

- Patient ID selection
- Anomaly summary
- Anomaly score visualization
- Actual versus predicted anomaly comparison
- Patient-wise performance metrics

## 📈 Model Performance

The raw anomaly detection model achieved the following results on the scored test dataset:

| Evaluation Metric | Result |
|---|---:|
| Accuracy | 98.32% |
| Precision | 82.51% |
| Recall | 85.67% |
| Specificity | 99.01% |
| F1-Score | 84.06% |

**Confusion Matrix – Raw Model**

| | Predicted Normal | Predicted Anomaly |
|---|---:|---:|
| Actual Normal | 259,429 | 2,590 |
| Actual Anomaly | 2,044 | 12,219 |

The temporal filtering experiment produced a lower F1-score of 40.80%, compared with 84.06% for the raw model.

These results demonstrate that the tested filtering rule did not improve detection performance.

## 📁 Project Structure

```text
VitaTrend-Anomaly-Engine/
│
├── app.R
├── 01_dataset_inspection.R
├── 02_exploratory_data_analysis.R
├── 03_missing_data_diagnostics.R
├── 04_data_preparation.R
├── 05_feature_engineering.R
├── 06_anomaly_detection.R
├── 07_false_alert_reduction.R
├── 08_data_visualization.R
├── 09_model_evaluation.R
│
├── vital_anomaly_results.rds
├── patient_wise_performance.csv
├── model_performance_comparison.csv
│
└── README.md
```

*The original dataset and large intermediate files are not included in the deployment bundle.*

## 🚀 How to Run the Project

### Step 1: Install R and RStudio

Install R and RStudio on your computer.

### Step 2: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/VitaTrend-Anomaly-Engine.git
```

### Step 3: Open the Project

Open the downloaded project folder in RStudio.

### Step 4: Install Required Packages

```r
install.packages(c(
  "shiny",
  "ggplot2",
  "dplyr",
  "rsconnect"
))
```

Install any additional packages required by the individual analysis scripts.

### Step 5: Run the Dashboard

```r
shiny::runApp()
```

## 🌐 Live Dashboard

**Deployment Platform:** shinyapps.io

**Dashboard URL:** <https://vitalwatchai.shinyapps.io/vitalwatch-ai/>
## 🔮 Future Enhancements

- Improve false-alert reduction using advanced temporal methods.
- Explore alternative anomaly detection algorithms.
- Add real-time vital-sign monitoring.
- Improve interactive visualizations.
- Investigate adaptive patient-specific thresholds.
- Evaluate the approach on suitable real-world datasets with appropriate ethical and clinical validation.

## ⚠️ Limitations

- The project uses synthetic patient data.
- The anomaly detection model is not clinically validated.
- The temporal filtering experiment did not improve performance.
- The system is intended for academic demonstration and research, not medical diagnosis or treatment decisions.

## 👩‍💻 Author

**P POOJITHA**

Department of Data Science  
Presidency University

## 📜 License

This project is available for educational and research purposes. Add an appropriate open-source license before permitting reuse or redistribution.

---

⭐ If you find this project interesting, consider starring the repository!