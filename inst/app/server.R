
library(shiny)




server <- function(input, output, session) {
  # Define the server logic for the app
  # This is where you can add your server-side code to handle user inputs and generate outputs

  # Example: Print a message when the app starts
  observe({
    print("App has started!")
  })

  output$hist <- renderPlot({
    title <- "100 random normal values"
    hist(rnorm(input$num1), main = title)
  })



}
