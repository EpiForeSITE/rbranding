function(input, output, session) {

  # Combine the selected variables into a new data frame
  selectedData <- reactive({
    iris[, c(input$xcol, input$ycol)]
  })

  clusters <- reactive({
    kmeans(selectedData(), input$clusters)
  })

  output$plot1 <- renderPlot({
    # Create data frame for ggplot
    plot_data <- selectedData()
    plot_data$cluster <- factor(clusters()$cluster)
    
    # Create centers data frame
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