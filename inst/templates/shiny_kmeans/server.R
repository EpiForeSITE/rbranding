# Example Shiny server logic for k-means clustering demo
# This file defines the server-side behavior for the k-means example app.
# It demonstrates dynamic clustering, branded ggplot output, and logo integration.

function(input, output, session) {

  # Combine the selected variables into a new data frame
  # reactive means this function will auto-update when inputs change
  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)] # Select columns based on user input
  })

  # Perform k-means clustering on the selected data
  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })

  # Render the main plot output
  output$plot1 <- renderPlot({
    # Create data frame for ggplot
    plot_data <- selectedData()
    plot_data$cluster <- factor(clusters()$cluster)
    
    # Create centers data frame for cluster centers
    centers_data <- as.data.frame(clusters()$centers)
    centers_data$cluster <- factor(seq_len(nrow(centers_data)))
    
    # Create ggplot with branded theme
    p <- ggplot(plot_data, aes_string(x = input$xcol, y = input$ycol, color = "cluster")) +
      geom_point(size = 3, alpha = 0.8) +
      geom_point(data = centers_data, 
                 aes_string(x = input$xcol, y = input$ycol, color = "cluster"),
                 shape = 4, size = 6, stroke = 2, show.legend = FALSE) +
      labs(
        title = "Iris K-means Clustering",
        subtitle = paste("Clustered into", input$clusters, "groups"),
        x = tools::toTitleCase(gsub("\\.", " ", input$xcol)),
        y = tools::toTitleCase(gsub("\\.", " ", input$ycol)),
        color = "Cluster"
      ) +
      theme(
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 12),
        legend.position = "bottom"
      )
    
    # Add logo from brand configuration if available
    tryCatch({
      p <- p + brand_add_logo(x = 0.95, y = 0.95, size = 0.08)
    }, error = function(e) {
      # If logo fails, continue without it
      message("Logo not added: ", e$message)
    })
    
    print(p)
  })

}