library(shiny)
library(bslib)
library(plotly)  # Using plotly for maps now
library(DT)      # For interactive data tables

ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "cerulean"),
  titlePanel("Wastewater Dashboard: Plotly Map & Table Interaction"),

  layout_sidebar(
    sidebar = sidebar(
      title = "Controls & Info",
      width = 300, # Adjust sidebar width as needed
      p("This demo shows how clicking on the Plotly map can select a row in the table, and selecting a row in the table can highlight a location on the map."),
      p("A shared 'Location ID' is used to link the views.")
    ),
    # Main content area
    fluidRow(
      column(width = 7, # Column for the map
             h4("Sample Locations Map (Plotly)"),
             plotlyOutput("wastewaterMapPlotly", height = "600px") # Plotly map output
      ),
      column(width = 5, # Column for the data table
             h4("Sample Details Table"),
             DTOutput("wastewaterTable") # DT table output remains the same
      )
    )
  )
)
