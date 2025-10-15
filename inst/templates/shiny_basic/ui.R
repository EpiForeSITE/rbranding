# Example Shiny UI for rbranding demo app
# This file defines the user interface for the example app.
# It demonstrates how to use bslib themes and branding config values in the UI.

library(bslib)
library(yaml)

# Create a theme object with branding enabled
# This will automatically discover and use _brand.yml if present
theme <- bslib::bs_theme(brand = TRUE)

# Extract the path of the discovered _brand.yml file from the theme object
brand_info <- attr(theme, "brand")
brand_path <- brand_info$path

# Read _brand.yml file to get branding configuration
brand <- yaml.load_file(brand_path)
# We can use the brand_colors list to access colors defined in _brand.yml
brand_colors <- brand$color


# Define the UI layout using bslib's page_sidebar
ui <- bslib::page_sidebar(
    theme = bs_theme(), # Apply Bootstrap theme

  # Set lang="en" for accessibility
  tags$head(
    tags$script(HTML("document.documentElement.setAttribute('lang', 'en');"))
  ),

  title = tags$h1("Simple Shiny"), # Main app title

  sidebar = bslib::sidebar(
    tags$h2("Sidebar"), # Sidebar title
    numericInput(
      "num1",
      "Mean",
      value = 50,
      min = 1,
      max = 100
    ),
    card(
      title = "Card",
      # Set card background color using primary color from branding config
      style = paste("background-color:", brand_colors$primary),
      tags$h3("Card Title"),
      tags$p(brand_colors$primary))

    ),

  plotOutput("hist") # Main plot area
)