library(bslib)

ui <- bslib::page_sidebar(
    theme = bs_theme(brand = TRUE),
  # theme = bs_theme(brand = "brand/_ap_brand.yml"),
  # theme = bs_theme(brand = "brand/_gvy_brand.yml"),
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
