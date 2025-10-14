# Load required libraries
library(rbranding)
library(ggplot2)

# Initialize rbranding and set up theme from _brand.yml
theme <- bslib::bs_theme(brand = TRUE)

# Extract the path of the discovered _brand.yml file
brand_info <- attr(theme, "brand")
brand_path <- brand_info$path

# Set up ggplot2 theme from brand configuration
brand_set_ggplot()

# k-means only works with numerical variables,
# so don't give the user the option to select
# a categorical variable
vars <- setdiff(names(iris), "Species")

pageWithSidebar(
  headerPanel(
    tagList(
      tags$script(HTML("document.documentElement.setAttribute('lang', 'en');")),
      'Iris k-means clustering'
    )
  ),
  sidebarPanel(
    selectInput('xcol', 'X Variable', vars),
    selectInput('ycol', 'Y Variable', vars, selected = vars[[2]]),
    numericInput('clusters', 'Cluster count', 3, min = 1, max = 9)
  ),
  mainPanel(
    plotOutput('plot1')
  )
)