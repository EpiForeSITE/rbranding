
# Example Shiny app launcher for rbranding package
# This file provides a function to run the main demonstration app
# included with the rbranding package. The app showcases branding
# features and UI components.

#' Launch the rbranding demo Shiny app
#'
#' This function starts the Shiny app located in the 'app/' directory
#' of the installed rbranding package. Use this to preview branding
#' and UI integration features.
#' @export
run_model <- function() {
  shinyAppDir(
    system.file("app/", package = "rbranding") # Finds the app directory in the installed package
  )
}
