#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
library(shiny)
library(shinydashboard)
library(ggplot2)
library(plotly)
library(dplyr)
library(RJDBC) 
library(rJava) 
library(DBI)

#drv = JDBC("org.apache.hive.jdbc.HiveDriver" , 
#           "C:\\Users\\marwa\\Documents\\WorkSpace\\NoSql\\vagrant-projects\\OracleDatabase\\21.3.0\\projetTpa\\normalisation\\HiveJdbcDriver\\hive-jdbc-4.0.0-alpha-1-standalone.jar")
#conn = dbConnect(drv
#                 , "jdbc:hive2://localhost:10000/default" , "vagrant","vagrant")

data_client <- dbGetQuery(conn, "select * from clients12_mongo_ext_updated ")
data_immatriculation <-dbGetQuery(conn, "select * from immatriculations_mongo_ext_updated ")

# Load the data from the CSV files (delete it )
#data_immatriculation <- read.csv("C:/Users/marwa/Documents/WorkSpace/NoSql/vagrant-projects/OracleDatabase/21.3.0/projetTpa/normalisation/Immatriculations_updated.csv",nrows = 100000, header = TRUE)
#data_client <- read.csv("C:/Users/marwa/Documents/WorkSpace/NoSql/vagrant-projects/OracleDatabase/21.3.0/projetTpa/normalisation/Clients_12_updated.csv", header = TRUE)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Data Visualizations"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Immatriculation", tabName = "imm", icon = icon("car")),
      menuItem("Client", tabName = "client", icon = icon("users")),
      menuItem("Client & Immatriculation", tabName = "client_imm", icon = icon("exchange"))
    )
  ),
  
  dashboardBody(

    tabItems(
      tabItem(tabName = "imm",
              plotlyOutput("plot1"),
              plotlyOutput("plot2"),
              plotlyOutput("plot3"),
              plotlyOutput("plot4"),
              plotlyOutput("plot6")
      ),
      tabItem(tabName = "client",
              plotlyOutput("plot_age_distribution"),
              plotlyOutput("plot_taux_distribution"),
              plotlyOutput("plot_family_situation"),
      ),
      tabItem(tabName = "client_imm",
              plotlyOutput("relation_plot_1"),
              plotlyOutput("relation_plot_2"),
              plotlyOutput("relation_plot_3"),
              plotlyOutput("relation_plot_4"),
              plotlyOutput("relation_plot_7"),
              plotlyOutput("relation_plot_8"),
      )
      
    )
  )
)

# Define server logic
server <- function(input, output) {
  # 'Immatriculation' tab plots...
  merged_data <- reactive({
    merge(data_client, data_immatriculation, by = "immatriculation", all.x = TRUE)
  })
  # All 'Immatriculation' tab
  # First plot: The distribution of prices
  output$plot1 <- renderPlotly({
    ggplot(data_immatriculation, aes(x = prix)) +
      geom_histogram(binwidth = 5000, fill = 'blue') +
      labs(title = "Price Distribution", x = "Price", y = "Count")
  })
  
  # Second plot: Bar chart of car brands with each bar colored differently
  output$plot2 <- renderPlotly({
    ggplot(data_immatriculation, aes(x = marque, fill = marque)) +
      geom_bar() +
      labs(title = "Number of Cars by Brand", x = "Brand", y = "Count") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_fill_manual(values = rainbow(length(unique(data_immatriculation$marque))))
  })
  
  
  # Third plot: Boxplot of power by occasion
  output$plot3 <- renderPlotly({
    ggplot(data_immatriculation, aes(x = as.factor(occasion), y = puissance)) +
      geom_boxplot() +
      labs(title = "Car Power by Occasion", x = "Occasion", y = "Power")
  })
  
  # Fourth plot: Scatterplot of power versus price
  output$plot4 <- renderPlotly({
    ggplot(data_immatriculation, aes(x = puissance, y = prix)) +
      geom_point() +
      geom_smooth(method = "lm", color = "red") +
      labs(title = "Power vs. Price", x = "Power", y = "Price")
  })
  
 
 
  # 'Client' tab plots...
  output$plot_age_distribution <- renderPlotly({
    ggplotly(
      ggplot(data_client, aes(age)) + 
        geom_histogram(binwidth = 5, fill = "blue") +
        labs(title = "Age Distribution", x = "Age", y = "Count") +
        theme_minimal()
    )
  })
  
  output$plot_taux_distribution <- renderPlotly({
    ggplotly(
      ggplot(data_client, aes(taux)) + 
        geom_histogram(binwidth = 50, fill = "green") +
        labs(title = "Taux Distribution", x = "Taux", y = "Count") +
        theme_minimal()
    )
  })
  
  output$plot_family_situation <- renderPlotly({
    ggplotly(
      ggplot(data_client, aes(situationFamiliale, fill = sexe)) + 
        geom_bar(position = "dodge") +
        labs(title = "Count by Family Situation", x = "Family Situation", y = "Count", fill = "Sexe") +
        theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
    )
  })
  

  
  # 'Client & Immatriculation' tab plots...
  # This is inside the server function of your Shiny app after you've loaded your data.
  # Example Plot 1: Age vs Price for each Sexe
  output$relation_plot_1 <- renderPlotly({
    data <- merged_data()
    p <- ggplot(data, aes(x = age, y = prix, color = sexe)) + 
      geom_point() +
      labs(title = "Price vs Age by Gender", x = "Age", y = "Price (€)") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Example Plot 2: Average Price by 'marque' split by new ('occasion'==0) vs used ('occasion'==1)
  output$relation_plot_2 <- renderPlotly({
    data <- merged_data()
    p <- ggplot(data, aes(x = marque, y = prix, fill = as.factor(occasion))) + 
      geom_bar(stat = "summary", fun.y = "mean") +
      labs(title = "Average Price by Brand and Occasion", x = "Brand", y = "Average Price (€)") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Example Plot 3: 'taux' distribution by 'situationFamiliale'
  output$relation_plot_3 <- renderPlotly({
    data <- merged_data()
    p <- ggplot(data, aes(x = situationFamiliale, y = taux)) + 
      geom_boxplot() +
      labs(title = "capacité d'endettement by Family Situation", x = "Family Situation", y = "capacité d'endettement") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Example Plot 4: Density plot of 'puissance', faceted by 'sexe'
  output$relation_plot_4 <- renderPlotly({
    data <- merged_data()
    p <- ggplot(data, aes(x = puissance, fill = sexe)) + 
      geom_density(alpha = 0.7) + 
      facet_wrap(~sexe) + 
      labs(title = "Power Density by Gender", x = "Power", y = "Density") +
      theme_minimal()
    ggplotly(p)
  })
  
  
  # Example Plot 7: Number of Cars by Color split by New vs Used Status
  output$relation_plot_7 <- renderPlotly({
    data <- merged_data()
    p <- ggplot(data, aes(x = couleur, fill = as.factor(occasion))) + 
      geom_bar(position = "fill") +
      scale_fill_manual(values = c("0" = "blue", "1" = "red"), labels = c("New", "Used")) +
      labs(title = "Car Color Distribution by New vs Used Status", x = "Car Color", y = "Proportion") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Example Plot 8: Scatter Plot of 'nbPortes' vs 'puissance' by 'situationFamiliale'
  output$relation_plot_8 <- renderPlotly({
    data <- merged_data()
    p <- ggplot(data, aes(x = nbPortes, y = puissance, color = situationFamiliale)) + 
      geom_point() +
      labs(title = "Number of Doors vs Power by Family Situation", x = "Number of Doors", y = "Power") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Make sure you already have merged_data as a reactive dataset within the server function
  
  
  

  
  
  }
  
  


# Run the application 
shinyApp(ui, server)
