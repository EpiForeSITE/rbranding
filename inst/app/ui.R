library(bslib)

ui <- bslib::page_sidebar(
  theme = bs_theme(),
  title = "simple shiny",

  sidebar = bslib::sidebar(
    numericInput(
      "num1",
      "Mean",
      value = 50,
      min = 1,
      max = 100
    ),
  ),

  plotOutput("hist")
)
