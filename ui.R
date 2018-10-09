#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  # Application title
  tags$div( class="pageTitle",
  titlePanel("New York Air Quality Measurements"),
  h4("Daily air quality measurements in New York, May to September 1973"),
  div(class="doc",a("Documentation", href="help.html", 
                    title="Click here for documentation"))
  ),

  div(
    id = "loading-content",
    h2("Loading...")
  ),
  
  tags$div(
    class="content",
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      class="side",
      #Choose month
      selectInput("month", "Select Month : ", choices=c("May"=5, "Jun"=6, "Jul"=7, "Aug"=8, "Sep"=9),
                  multiple=FALSE, selected = "Jun"),
      
      #Choose week
       sliderInput("week", "Weeks :", min = 1, max = 5, value = c(2,4)),
      
      #
      checkboxGroupInput("checkGroup", label = h3("Plot"), choices = list("Ozone" = 1, 
           "Solar Radiation" = 2, "Weekly Wind Speed Comparison" = 3, "Ozone - Temperature" = 4), selected = c(1,2,3,4))
    ),
    

    # Show a plot of the generated distribution
    
    mainPanel(class="main", 
              fluidRow(
                column(width = 3, class="tile", htmlOutput("tempAvg")),
                column(width = 3, class="tile", htmlOutput("windAvg")),
                column(width = 3, class="tile", htmlOutput("solarAvg")),
                column(width = 3, class="tile", htmlOutput("ozoneAvg"))
              ),
              plotOutput("distPlot")
      )
  )
  )
))
