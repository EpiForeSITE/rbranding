# Example Shiny server logic for rbranding demo app
# This file defines the server-side behavior for the example app.
# It demonstrates how to use bslib themes and interact with branding config files.

library(shiny)
library(bslib)

# Main server function for the Shiny app
server <- function(input, output, session) {
  # This is where you add server-side code to handle user inputs and generate outputs

  observe({
    print("App has started!")
    # Create a Bootstrap theme object with branding enabled
    theme <- bs_theme(brand = TRUE)

    # Extract the path of the discovered _brand.yml file from the theme object
    brand_info <- attr(theme, "brand")
    brand_path <- brand_info$path

    
  })

  # Example output: Render a histogram of random normal values
  output$hist <- renderPlot({
    title <- "100 random normal values"
    hist(rnorm(input$num1), main = title)
  })

}