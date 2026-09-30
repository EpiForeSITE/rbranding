# Load required libraries
library(rbranding)
library(ggplot2)

# Create a Bootstrap theme from _brand.yml (discovered automatically);
# it is passed to the page below so the UI uses the brand colors and fonts
theme <- bslib::bs_theme(version = 5, brand = TRUE)

# Extract the path of the discovered _brand.yml file
brand_info <- attr(theme, "brand")
brand_path <- brand_info$path

# Set up ggplot2 theme from brand configuration
brand_set_ggplot()

# k-means only works with numerical variables,
# so don't give the user the option to select
# a categorical variable
vars <- setdiff(names(iris), "Species")

fluidPage(
  theme = theme,
  lang = "en",
  titlePanel("Iris k-means clustering"),
  sidebarLayout(
    sidebarPanel(
      selectInput('xcol', 'X Variable', vars),
      selectInput('ycol', 'Y Variable', vars, selected = vars[[2]]),
      numericInput('clusters', 'Cluster count', 3, min = 1, max = 9)
    ),
    mainPanel(
      plotOutput('plot1')
    )
  )
)