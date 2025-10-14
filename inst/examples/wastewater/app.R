# Load required libraries
library(shiny)
library(leaflet)
library(DT)
library(dplyr)
library(here)
library(bslib)
library(rbranding)
library(linkeR)

# Initialize rbranding and set up theme from _brand.yml
theme <- bs_theme(brand = TRUE)

# Extract the path of the discovered _brand.yml file
brand_info <- attr(theme, "brand")
brand_path <- brand_info$path

ui <- fluidPage(
  lang = "en",
  theme = theme,
  titlePanel("Wastewater Sample Dashboard: Map-Table Interaction"),

  layout_sidebar(
    sidebar = sidebar(
      title = "Controls & Info",
      width = 300,
      p("This demo shows bidirectional linking between a leaflet map and data table using linkeR."),
      p("Features:"),
      tags$ul(
        tags$li("Click map markers to select table rows"),
        tags$li("Click table rows to highlight map locations"),
        tags$li("Custom popup and zoom behavior"),
        tags$li("Shared location ID enables linking")
      )
    ),
    
    # Main content area: map and table side-by-side
    fluidRow(
      column(
        width = 7,
        h4("Sample Locations Map"),
        leafletOutput("wastewaterMap", height = "550px")
      ),
      column(
        width = 5,
        h4("Sample Details Table"),
        DTOutput("wastewaterTable")
      )
    )
  ),

  # Full-width detail panel below map and table
  fluidRow(
    column(
      width = 12,
      uiOutput("selectedDataPanel")
    )
  )
)

server <- function(input, output, session) {
  
  # === DATA SETUP ===
  
  # Utah city coordinates for sample locations
  UT_city_locations <- list(
    c(40.93, -111.88), # Salt Lake City area
    c(41.1, -112.02),  # Ogden area
    c(40.79, -111.74), # Millcreek/Holladay area
    c(37.76, -111.6),  # Remote area
    c(40.71, -111.9),  # West Valley City/Taylorsville area
    c(40.76, -111.88), # Park City area
    c(40.78, -111.89), # Sandy area
    c(40.67, -111.89), # Orem area
    c(40.76, -111.89), # Draper area
    c(40.76, -111.89)  # Lehi area
  )
  
  num_rows <- length(UT_city_locations)

  # Generate dummy wastewater sample data
  dummy_locations <- reactive({
    data.frame(
      location_id = paste0("WS_Loc_", 1:num_rows),
      name = paste("Treatment Plant", LETTERS[1:num_rows]),
      latitude = sapply(UT_city_locations, function(x) x[1]),
      longitude = sapply(UT_city_locations, function(x) x[2]),
      status = sample(c("Normal", "Elevated Risk", "Action Required"), num_rows, replace = TRUE),
      last_sample_value = round(runif(num_rows, 50, 500)),
      stringsAsFactors = FALSE
    )
  })

  # Debug: print location IDs on startup
  isolate(message(paste(dummy_locations()$location_id, collapse = ", ")))

  # === REACTIVE VALUES ===
  
  reactive_selected_id <- reactiveVal(NULL) # Track currently selected location ID

  # === CUSTOM CLICK HANDLER ===
  
  # Define custom behavior for leaflet marker clicks
  leaflet_click_handler <- function(map_proxy, selected_data, session) {
    # Clear any existing popups
    map_proxy %>% clearPopups()
    
    if (!is.null(selected_data)) {
      # Create rich HTML popup content
      popup_content <- paste0(
        "<div style='min-width: 200px; padding: 10px;'>",
        "<h4 style='color: #2c3e50; margin-top: 0;'>", selected_data$name, "</h4>",
        "<p><strong>ID:</strong> ", selected_data$location_id, "</p>",
        "<p><strong>Status:</strong> ", selected_data$status, "</p>",
        "<p><strong>Sample Value:</strong> ", selected_data$last_sample_value, "</p>",
        "</div>"
      )
      
      # Apply visual feedback: highlight, zoom, and popup
      map_proxy %>%
        # Clear any existing highlights
        clearGroup("highlight") %>%
        # Add highlighted circle marker
        addCircleMarkers(
          lng = selected_data$longitude,
          lat = selected_data$latitude,
          radius = 15,
          color = "red",
          fillColor = "red",
          fillOpacity = 0.3,
          stroke = TRUE,
          weight = 3,
          group = "highlight"
        ) %>%
        # Zoom to the selected location
        flyTo(
          lng = selected_data$longitude,
          lat = selected_data$latitude,
          zoom = 12
        ) %>%
        # Add detailed popup
        addPopups(
          lng = selected_data$longitude,
          lat = selected_data$latitude,
          popup = popup_content,
          layerId = paste0("detailed_popup_", selected_data$location_id)
        )
    } else {
      # Handle deselection - clear all visual feedback
      map_proxy %>% 
        clearGroup("highlight") %>%
        clearPopups()
    }
  }
  
  # === COMPONENT LINKING ===
  
  # Link the map and table using linkeR with custom click handler
  linkeR::link_plots(
    session = session,
    wastewaterMap = dummy_locations,
    wastewaterTable = dummy_locations,
    shared_id_column = "location_id",
    leaflet_click_handler = leaflet_click_handler,
    on_selection_change = function(selected_id, selected_data, source_id, session) {
      reactive_selected_id(selected_id)
    }
  )

  # === OUTPUT RENDERERS ===
  
  # Render the interactive leaflet map
  output$wastewaterMap <- renderLeaflet({
    locations <- dummy_locations()
    leaflet(data = locations) %>%
      addTiles() %>%
      addMarkers(
        lng = ~longitude,
        lat = ~latitude,
        layerId = ~location_id # CRITICAL: layerId enables linking
      )
  })

  # Render the data table
  output$wastewaterTable <- renderDT({
    locations <- dummy_locations()
    datatable(
      locations,
      selection = "single", # Single row selection for better UX
      rownames = FALSE,
      options = list(
        searching = FALSE,
        pageLength = 5
      )
    )
  })

  # === DETAIL PANEL ===
  
  # Render detailed information panel for selected location
  output$selectedDataPanel <- renderUI({
    current_id <- reactive_selected_id()

    if (!is.null(current_id)) {
      locations <- dummy_locations()
      selected_data <- locations[locations$location_id == current_id, ]
      
      if (nrow(selected_data) > 0) {
        # Create styled detail panel
        div(
          style = "background-color: #e0f2f7; padding: 15px; margin-top: 20px; border-radius: 8px; border: 1px solid #b3cde0;",
          tags$h5(
            style = "margin-top:0; color: #005662;", 
            paste("Details for:", selected_data$name)
          ),
          tags$p(
            tags$strong("ID: "), 
            tags$span(current_id) 
          ),
          tags$hr(style = "border-top: 1px solid #b3cde0;"),
          tags$p(
            tags$strong("Sample Value: "),
            tags$span(
              style = "font-weight:bold; color: #007bff;", 
              selected_data$last_sample_value
            )
          ),
          tags$p(
            tags$strong("Status: "),
            tags$span(selected_data$status)
          )
        )
      } else {
        # Error state (shouldn't normally happen)
        div(
          style = "background-color: #f8d7da; padding: 15px; margin-top: 20px; border-radius: 5px; text-align: center; color: #721c24;",
          tags$em("Error: Selected location not found")
        )
      }
    } else {
      # Default state - no selection
      div(
        style = "background-color: #f8f9fa; padding: 15px; margin-top: 20px; border-radius: 5px; text-align: center; color: #6c757d;",
        tags$em("Select a location on the map or table to see details here.")
      )
    }
  })
}

shinyApp(ui = ui, server = server)
