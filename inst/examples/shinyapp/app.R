#
# Intermediate Shiny Template
# Provides a more complex Shiny app with multiple tabs,
# allowing users to interactively adjust parameters and
# view results in different formats.
#
# To run this application:
#   in R Studio, You can run the application by clicking
#   the 'Run App' button above.
#   Alternatively, you can run the application by executing:
#   shiny::runApp("app.R") in the R console from the directory
#   containing this file.


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

# Example: Read a color from _brand.yml in this folder
library(yaml)
brand <- yaml::read_yaml("_brand.yml")
primary_name <- brand$color$primary
primary_hex <- brand$color$palette[[primary_name]]
# Now primary_hex contains the hex code for the primary color
library(yaml) # for reading _brand.yml


# UI -----

## Create header -----
# This creates the header for the dashboard that can be
# used across multiple apps if desired.



header <- dashboardHeader(
  title = "RBranding Intermediate Shiny Example", # Replace with your title (displayed in the dashboard)
  titleWidth = 200, # Can change to accommodate your title
  tags$li(
    a(
      href = "https://epiforesite.github.io/rbranding/",
      img(
        src = "oi--circle-check.png",
        title = "rbranding package",
        alt = "rbranding icon",
        width = "40px",
        height = "40px"
      ),
      style = "padding-top: 5px; padding-bottom: 5px;"
    ),
    class = "dropdown"
  )
)


## Define UI -----

ui <- dashboardPage(

  # This sets the title in the browser tab
  title = "Shiny App Example 1",

  # Implement the header created above
  header,

  ## Navigation sidebar -----

  # More icons can be found at "fontawesome.com/icons" and
  # "getbootstrap.com/docs/3.4/components/#glyphicons"
  # Note that some may not work, so test first!

  dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      ### 1st tab add or remove tabs as needed.  Add elements within 
      ### the tabItem() sections in the dashboardBody() below.
      menuItem("Tab 1", tabname = "tab1", icon = icon("chart-line")),

      ### 2nd tab -----
      menuItem(
        "Tab 2",
        tabname = "tab2",
        icon = icon("stats", lib = "glyphicon")
      ),

      ### Slider -----
      uiOutput("slider")
    ) # end of sidebarMenu
  ), # end of dashboardSidebar

  ## Dashboard body -----
  dashboardBody(
    # Import CSS
    # the HTML setAttribute('lang', 'en'); ensures accessibilty.  It's a
    # small thing, but it helps screen readers interpret the content correctly.
    tags$head(
      tags$script(
        HTML("document.documentElement.setAttribute('lang', 'en');")
      ),
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),

    ### 1st tab -----
    tabItem(
      tabName = "Tab 1",

      # Tab 1 contents
      fluidRow(
        # Static infobox (there are also dynamic infoboxes that work
        # similarly to valueboxes)
        infoBox(
          "infobox1",
          34,
          icon = icon("list"),
          width = 2
        ),

        # Dynamic valuebox
        valueBoxOutput("valuebox1", width = 2)
      )
    ), # end Tab 1

    ### 2nd tab -----
    tabItem(
      tabName = "Tab 2",

      # Tab 2 contents
      fluidRow(
        box(
          title = "Old Faithful Geyser Data",
          plotOutput("distplot")
        )
      )
    ) # end Tab 2
  ) # end dashboardBody
) # end dashboardPage

# Server -----
server <- function(input, output) {
  # Reactive slider input.  Maps to the uiOutput("slider") 
  # above.
  output$slider <- renderUI({
    sliderInput(
      "bins",
      "Number of bins:",
      min = 1,
      max = 50,
      value = 30
    )
  })

  ## 1st value box (card) above the histogram
  ## the icon("map-location-dot") is a Font Awesome icon.
  ## More icons can be found at "fontawesome.com/icons"
  ## valuebox doesn't allow taking colors as names from _brand.yml

  output$valuebox1 <- renderValueBox({
      # here we use primary_hex for the color, this has been read 
      # from _brand.yml
      valueBox(
        7^3,
        subtitle = "Valuebox 1",
        icon = icon("map-location-dot"),
        color = primary_hex
      )
  })

  ## 2nd tab This generates the histogram based on the slider input

  output$distplot <- renderPlot({
    # generate bins based on input$bins from ui.R
    x <- faithful[, 2]
    nbins <- if (is.null(input$bins)) 30 else input$bins
    bins <- seq(min(x), max(x), length.out = nbins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = "darkgray", border = "white")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
