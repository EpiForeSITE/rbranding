#
# DHHS R Shiny Template
#
# You can run the application by clicking the 'Run App' button above.
#


# Library & functions -----
library(shiny)
library(shinydashboard)
library(htmltools)
library(bslib)
library(shinyWidgets)
library(plotly)
library(leaflet)
library(janitor)
library(lubridate)
library(tidyverse)


# UI -----

## Create header -----

header <- dashboardHeader(title = "", #Replace with your title (displayed in the dashboard)
                          titleWidth = 200, #Can change to accommodate your title
                          tags$li(a(href = "https://posit-dev.github.io/brand-yml/",
                                    img(src = "oi--circle-check.png",
                                         title = "rbranding package"),
                                    style = "padding-top: 5px; padding-bottom: 5px;"),
                                  class = "dropdown"))


## Define UI -----

ui <- dashboardPage(
  
  # This sets the title in the browser tab
  title = "Shiny App Example 1",
  
  # Implement the header created above
  header,
  
  ## Navigation sidebar -----
  
  # More icons can be found at "fontawesome.com/icons" and "getbootstrap.com/docs/3.4/components/#glyphicons" 
  # Note that some may not work, so test first!
  
  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      ### 1st tab -----
      menuItem("Tab 1", tabname = "tab1", icon = icon("chart-line")),
      
      ### 2nd tab -----
      menuItem("Tab 2", tabname = "tab2", icon = icon("stats", lib = "glyphicon")),
      
      ### Slider -----
      uiOutput("slider")
    ) #Close sidebarMenu
  ), #Close dashboardSidebar
  
  ## Dashboard body -----
  dashboardBody(
    
    # Import CSS
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
      ),
    
    ### 1st tab -----
    tabItem(
      tabName = "Tab 1",
      
      #Tab 1 contents
      fluidRow(
        #Static infobox (there are also dynamic infoboxes that work similarly to valueboxes)
        infoBox("infobox1",
                34,
                icon = icon("list"),
                width = 2),
        
        #Dynamic valuebox
        valueBoxOutput("valuebox1", width = 2)
      )
    ), #Close Tab 1
    
    ### 2nd tab -----
    tabItem(
      tabName = "Tab 2",
      
      #Tab 2 contents
      fluidRow(
        box(title = "Old Faithful Geyser Data",
            plotOutput("distplot"))
      )
      
    ), #Close Tab 2
    
    ) #Close dashboardBody
  
) #close dashboardPage

# ui <- fluidPage(
#   
#   tags$head(
#     tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
#   ),
# 
#     # Application title
#     titlePanel("Old Faithful Geyser Data"),
# 
#     # Sidebar with a slider input for number of bins 
#     sidebarLayout(
#         sidebarPanel(
#             sliderInput("bins",
#                         "Number of bins:",
#                         min = 1,
#                         max = 50,
#                         value = 30)
#         ),
# 
#         # Show a plot of the generated distribution
#         mainPanel(
#            plotOutput("distPlot")
#         )
#     )
# )



# Server -----
server <- function(input, output) {
  
  output$slider <- renderUI({
    sliderInput("bins",
                "Number of bins:",
                min = 1,
                max = 50,
                value = 30)
  })

  ## 1st tab -----
  
  output$valuebox1 <- renderValueBox({
    valueBox(7 ^ 3,
             subtitle = "Valuebox 1",
             icon = icon("map-location-dot"),
             color = "orange")
  })
  
  ## 2nd tab -----
  
    output$distplot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
