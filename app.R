
library(shiny)
library(ggplot2)
library(dplyr)

# Load project data
results <- readRDS("vital_anomaly_results.rds")
patient_performance <- read.csv("patient_wise_performance.csv")
performance <- read.csv("model_performance_comparison.csv")

# Dashboard User Interface
ui <- fluidPage(
  
  titlePanel("VitalWatch AI - Patient Vital Sign Monitoring"),
  
  sidebarLayout(
    
    sidebarPanel(
      
      h4("Patient Selection"),
      
      selectInput(
        "patient",
        "Select Patient ID:",
        choices = sort(unique(results$Patient_ID))
      ),
      
      hr(),
      
      h4("Project Information"),
      
      p("Trend-Aware Multivariate Anomaly Detection"),
      
      p("Synthetic Patient Monitoring Dataset"),
      
      p("Model: Mahalanobis Distance")
    ),
    
    mainPanel(
      
      h3("Patient Monitoring Dashboard"),
      
      h4("Anomaly Summary"),
      
      tableOutput("summary"),
      
      hr(),
      
      h4("Anomaly Score Over Time"),
      
      plotOutput("anomaly_plot"),
      
      hr(),
      
      h4("Actual vs Predicted Anomalies"),
      
      plotOutput("prediction_plot"),
      
      hr(),
      
      h4("Patient Performance"),
      
      tableOutput("patient_metrics")
    )
  )
)

# Dashboard Server
server <- function(input, output) {
  
  selected_data <- reactive({
    
    results %>%
      filter(Patient_ID == as.numeric(input$patient)) %>%
      arrange(Timestamp)
  })
  
  output$summary <- renderTable({
    
    data <- selected_data()
    
    data.frame(
      Total_Readings = nrow(data),
      Actual_Anomalies = sum(data$Is_Anomaly == 1),
      Predicted_Anomalies = sum(data$Model_Prediction == 1),
      Detection_Rate = round(
        mean(data$Model_Prediction == 1) * 100, 2
      )
    )
    
  })
  
  output$anomaly_plot <- renderPlot({
    
    data <- selected_data()
    
    ggplot(data, aes(x = Timestamp, y = Anomaly_Score)) +
      geom_line(color = "blue") +
      labs(
        title = "Anomaly Score Over Time",
        x = "Timestamp",
        y = "Anomaly Score"
      ) +
      theme_minimal()
    
  })
  
  output$prediction_plot <- renderPlot({
    
    data <- selected_data()
    
    plot_data <- data.frame(
      Category = c("Actual Anomalies", "Predicted Anomalies"),
      Count = c(
        sum(data$Is_Anomaly == 1),
        sum(data$Model_Prediction == 1)
      )
    )
    
    ggplot(plot_data, aes(x = Category, y = Count, fill = Category)) +
      geom_col() +
      labs(
        title = "Actual vs Predicted Anomalies",
        x = "",
        y = "Number of Readings"
      ) +
      theme_minimal() +
      theme(legend.position = "none")
    
  })
  
  output$patient_metrics <- renderTable({
    
    patient_performance %>%
      filter(Patient_ID == as.numeric(input$patient)) %>%
      select(
        Patient_ID,
        Precision,
        Recall,
        Specificity,
        F1_Score
      )
    
  })
  
}

# Run Dashboard
shinyApp(ui = ui, server = server)
