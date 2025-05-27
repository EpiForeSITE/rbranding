library(shiny)
library(plotly)
library(DT)

server <- function(input, output, session) {

  # 1. Dummy Data
  dummy_locations <- reactive({
    data.frame(
      id = paste0("WS_Loc_", 1:5),
      name = paste("Treatment Plant", LETTERS[1:5]),
      latitude = c(40.93, 41.1, 40.79, 37.76, 40.71), # cities in Utah
      longitude = c(-111.88, -112.02, -111.74, -111.6, -111.9),
      status = sample(c("Normal", "Elevated Risk", "Action Required"), 5, replace = TRUE),
      last_sample_value = round(runif(5, 50, 500)),
      stringsAsFactors = FALSE
    )
  })

  # 2. Reactive Value for Selected ID
  selected_location_id <- reactiveVal(NULL)

  # 3. Render the Plotly Map
  output$wastewaterMapPlotly <- renderPlotly({
    locations <- dummy_locations()
    current_id <- selected_location_id()

    # Initialize colors and sizes with default values first
    locations$color <- "blue" # Default color for all points
    locations$size  <- 12     # Default size for all points

    # If a specific location is selected, update its color and size
    if (!is.null(current_id)) {
      selected_idx <- which(locations$id == current_id)
      if (length(selected_idx) > 0) { # Check if the selected ID exists in the locations
        locations$color[selected_idx] <- "orange"
        locations$size[selected_idx]  <- 20
      }
    }

    # Set map center and zoom level based on selection
    map_center <- list(lon = -98.5, lat = 39.8) # Default US center
    map_zoom <- 3

    if (!is.null(current_id)) {
      # Use a different variable name here to avoid potential confusion if 'selected_loc' was used elsewhere.
      selected_location_data <- locations[locations$id == current_id, ] 
      if(nrow(selected_location_data) > 0) {
        map_center <- list(lon = selected_location_data$longitude, lat = selected_location_data$latitude)
        map_zoom <- 9 # Zoom in on selected
      }
    }

    # Create the plot_mapbox
    # Note: Requires an internet connection. 'open-street-map' style doesn't need a token.
    # We use 'key = ~id' to pass the ID to click events.
    # 'source = "map_plotly"' is used to identify events from this specific plot.
    p <- plot_mapbox(data = locations, lat = ~latitude, lon = ~longitude,
                     key = ~id, source = "map_plotly", # Set key and source
                     mode = 'markers', type = 'scattermapbox',
                     text = ~paste("ID:", id, "<br>Name:", name, "<br>Status:", status), # Added status to hover
                     hoverinfo = 'text',
                     marker = list(size = ~size, color = ~color, opacity = 0.9)
                     ) %>%
         layout(
           title = 'Click a point to select',
           mapbox = list(
             style = 'open-street-map', # Using a free map style
             center = map_center,
             zoom = map_zoom
           ),
           showlegend = FALSE, # Hide legend if not needed
           margin = list(l = 10, r = 10, t = 40, b = 10) # Adjust margins
         )

    # Register the click event. This ensures Shiny listens for clicks on this plot.
    p %>% event_register("plotly_click")
  })

  # 4. Render the Data Table
  output$wastewaterTable <- renderDT({
    locations <- dummy_locations()
    datatable(
      locations,
      selection = 'single',
      rownames = FALSE,
      options = list(searching = FALSE, pageLength = 5)
    )
  })

  # 5. Observe Plotly Map Clicks
  observeEvent(event_data("plotly_click", source = "map_plotly"), {
    # Get click event data
    event <- event_data("plotly_click", source = "map_plotly")
    
    # Check if event data and 'key' (our ID) exist
    if (!is.null(event) && "key" %in% names(event) && length(event$key) > 0) { # Ensure key is not empty
      clicked_id <- event$key[1] # Extract the ID
      
      # Toggle selection logic
      if (!is.null(selected_location_id()) && selected_location_id() == clicked_id) {
        selected_location_id(NULL) # Deselect
      } else {
        selected_location_id(clicked_id) # Select
      }
    }
  })

  # 6. Observe Table Row Selections
  observeEvent(input$wastewaterTable_rows_selected, {
    selected_row_index <- input$wastewaterTable_rows_selected
    locations <- dummy_locations()
    
    if (length(selected_row_index) > 0) {
      id_from_table <- locations$id[selected_row_index]
      # Only update if the selection is different to avoid potential loops
      if (is.null(selected_location_id()) || selected_location_id() != id_from_table) {
          selected_location_id(id_from_table)
      }
    } 
    # If you want to deselect from map when table selection is cleared (e.g. clicking selected row again):
    # else {
    #   if (!is.null(selected_location_id())) {
    #      selected_location_id(NULL)
    #   }
    # }
  })

  # 7. Update Table Selection Based on `selected_location_id`
  # This observer reacts when `selected_location_id()` changes (from map or table).
  observe({
    current_id <- selected_location_id()
    locations <- dummy_locations()
    table_proxy <- dataTableProxy("wastewaterTable", session)

    if (!is.null(current_id)) {
      selected_row_index <- which(locations$id == current_id)
      # Check if the desired row is different from the currently selected row in the table
      if (length(selected_row_index) > 0 && 
          (is.null(input$wastewaterTable_rows_selected) || 
           length(input$wastewaterTable_rows_selected) == 0 || # Handle case where table selection is empty
           selected_row_index != input$wastewaterTable_rows_selected[1])) { # Compare with the first selected row if multiple are somehow selected
        selectRows(table_proxy, selected_row_index)
      }
    } else {
      # If current_id is NULL, clear the table selection
      if(!is.null(input$wastewaterTable_rows_selected) && length(input$wastewaterTable_rows_selected) > 0) {
         selectRows(table_proxy, NULL)
      }
    }
  })
}
