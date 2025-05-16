
library(shiny)
library(bslib)



server <- function(input, output, session) {
  # Define the server logic for the app
  # This is where you can add your server-side code to handle user inputs and generate outputs

  # Example: Print a message when the app starts
  observe({
    print("App has started!")
    # Create a theme object
    theme <- bs_theme(brand = TRUE)

    # Extract the path of the discovered _brand.yml file
    brand_info <- attr(theme, "brand")
    brand_path <- brand_info$path

    print(brand_path)


  })

  output$hist <- renderPlot({
    title <- "100 random normal values"
    hist(rnorm(input$num1), main = title)
  })



}
