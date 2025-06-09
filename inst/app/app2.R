library(shiny)
library(bslib)
library(ggplot2)
library(palmerpenguins)
library(thematic)
library(ragg)

options(shiny.useragg= TRUE)
thematic_shiny(font = "auto")

ui <- page_fluid(
  theme = bs_theme(),
  sliderInput(
    "slider",
    label = "Number of bins",
    min = 10,
    max = 60,
    value = 20
  ),
  plotOutput("plot")
)

server <- function(input, output) {
  output$plot <- renderPlot(
    {
      ggplot(data = penguins, aes(body_mass_g)) +
        geom_histogram(bins = input$slider)
    }
  )
}

shinyApp(ui = ui, server = server)
