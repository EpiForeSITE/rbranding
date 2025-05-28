library(shiny)
library(bslib)
library(leaflet) # For interactive maps
library(DT)      # For interactive data tables

ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "cerulean"),
  titlePanel("Wastewater Sample Dashboard: Map-Table Interaction"),

  layout_sidebar(
    sidebar = sidebar(
      title = "Controls & Info",
      width = 300, # Adjust sidebar width as needed
      p("This demo shows how clicking on the map can select a row in the table, and selecting a row in the table can highlight a location on the map."),
      p("A shared 'Location ID' is used to link the views.")
    ),
    # Main content area for map and table
    fluidRow(
      column(width = 7, # Column for the map
             h4("Sample Locations Map"),
             leafletOutput("wastewaterMap", height = "550px") # Slightly reduced height to make space
      ),
      column(width = 5, # Column for the data table
             h4("Sample Details Table"),
             DTOutput("wastewaterTable") # DT table output
      )
    )
  ), # End of layout_sidebar

  # New fluidRow for the selected data panel
  fluidRow(
    column(width = 12, # Full width column
           # This uiOutput will be rendered by the server
           uiOutput("selectedDataPanel")
    )
  )
)
