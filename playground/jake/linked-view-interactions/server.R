library(shiny)
library(leaflet)
library(DT)
library(dplyr)

server <- function(input, output, session) {

  # list of dummy wastewater sample locations in Utah, where each entry is a vector of latitude and longitude
  UT_city_locations <- list(
    c(40.93, -111.88), # Salt Lake City
    c(41.1, -112.02),  # Ogden
    c(40.79, -111.74), # Provo
    c(37.76, -111.6),  # St. George
    c(40.71, -111.9),  # Logan
    c(40.76, -111.88), # Park City
    c(40.78, -111.89), # Sandy
    c(40.67, -111.89), # Orem
    c(40.76, -111.89), # Draper
    c(40.76, -111.89)  # Lehi
  )

  num_rows <- length(UT_city_locations) # Number of dummy wastewater sample locations

  # Dummy Data for Wastewater Sample Locations
  # In a real app, this would come from a database, CSV, API, etc.
  # Crucially, each location has a unique 'id'.
  dummy_locations <- reactive({
    data.frame(
      id = paste0("WS_Loc_", 1:num_rows), # Unique Location ID
      name = paste("Treatment Plant", LETTERS[1:num_rows]),
      latitude = sapply(UT_city_locations, function(x) x[1]),
      longitude = sapply(UT_city_locations, function(x) x[2]),
      status = sample(c("Normal", "Elevated Risk", "Action Required"), num_rows, replace = TRUE),
      last_sample_value = round(runif(num_rows, 50, 500)),
      stringsAsFactors = FALSE
    )
  })

  # Reactive Value to Store the ID of the Currently Selected Location
  # This will be updated by map clicks or table row selections.
  selected_location_id <- reactiveVal(NULL)

  # Render the Leaflet Map
  output$wastewaterMap <- renderLeaflet({
    locations <- dummy_locations()
    leaflet(data = locations) %>%
      addTiles() %>% # Adds default OpenStreetMap tiles
      addMarkers(
        lng = ~longitude,
        lat = ~latitude,
        layerId = ~id # IMPORTANT: Assigns the location 'id' to each marker for click events
      )
  })

  # Render the Data Table
  output$wastewaterTable <- renderDT({
    locations <- dummy_locations()
    datatable(
      locations,
      selection = 'single', # Allow only single row selection
      rownames = FALSE,     # Don't show row numbers from R
      options = list(
        searching = FALSE, # Disable global search box for this simple table
        pageLength = 5     # Show 5 rows per page
      )
    )
  })

  # Observe Map Marker Clicks
  observeEvent(input$wastewaterMap_marker_click, {
    clicked_marker_id <- input$wastewaterMap_marker_click$id
    
    # If the clicked marker is already selected, deselect it (toggle)
    if (!is.null(selected_location_id()) && selected_location_id() == clicked_marker_id) {
      selected_location_id(NULL) # Deselect
    } else {
      selected_location_id(clicked_marker_id) # Select the new marker
    }
  })

  # Observe Table Row Selections
  observeEvent(input$wastewaterTable_rows_selected, {
    selected_row_index <- input$wastewaterTable_rows_selected
    locations <- dummy_locations()
    
    if (length(selected_row_index) > 0) { # If a row is actually selected
      # Get the ID of the location from the selected row
      id_from_table <- locations$id[selected_row_index]
      
      # If the table selection matches the current selected ID, do nothing (or deselect if desired)
      # If it's different, update the selected_location_id
      if (is.null(selected_location_id()) || selected_location_id() != id_from_table) {
        selected_location_id(id_from_table)
      }
    }
  })

  # Update Map Based on `selected_location_id`
  # This observer reacts when `selected_location_id()` changes.
  observe({
    current_id <- selected_location_id()
    locations <- dummy_locations()
    map_proxy <- leafletProxy("wastewaterMap", session) # Get a proxy to modify the map

    map_proxy %>% clearPopups() # Clear any existing popups

    if (!is.null(current_id)) {
      selected_data <- locations[locations$id == current_id, ]
      
      if (nrow(selected_data) > 0) {
        # Open a popup on the selected marker
        map_proxy %>% addPopups(
          lng = selected_data$longitude,
          lat = selected_data$latitude,
          popup = paste("<strong>",selected_data$name,"</strong>", "<br>",
                        "ID:", selected_data$id, "<br>",
                        "Status:", selected_data$status, "<br>",
                        "Value:", selected_data$last_sample_value)
        )

        map_proxy %>% flyTo(lng = selected_data$longitude, lat = selected_data$latitude, zoom = 12)
      }
    }
  })

  # Update Table Selection Based on `selected_location_id`
  # This observer reacts when `selected_location_id()` changes.
  observe({
    current_id <- selected_location_id()
    locations <- dummy_locations()
    table_proxy <- dataTableProxy("wastewaterTable", session)

    if (!is.null(current_id)) {
      selected_row_index <- which(locations$id == current_id)
      if (length(selected_row_index) > 0) {
        # Select the row in the table.
        # Note: This might re-trigger input$wastewaterTable_rows_selected if not handled carefully.
        # The conditional logic in observeEvent(input$wastewaterTable_rows_selected, ...) helps prevent infinite loops.
        selectRows(table_proxy, selected_row_index)
      }
    } else {
      selectRows(table_proxy, NULL) # Clear selection in the table
    }
  })

}
