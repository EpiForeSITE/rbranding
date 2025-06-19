#' Copy Example App File to User Directory
#'
#' This function creates the folders `inst/app` in the user's working directory and copies the example file `link_plots.R` into that folder.
#' @export
get_shiny_example1 <- function() {
  target_dir <- file.path(getwd(), "inst", "app")
  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE)
  }
  example_file <- system.file("examples", "link_plots.R", package = "rbranding")
  if (example_file == "") {
    stop("Example file not found in the package.")
  }
  file.copy(example_file, file.path(target_dir, "link_plots.R"), overwrite = TRUE)
  message("Example file copied to ", file.path(target_dir, "link_plots.R"))

  # Repeat for server.R
  example_file_server <- system.file("examples", "server.R", package = "rbranding")
  if (example_file_server == "") {
    stop("server.R file not found in the package.")
  }
  file.copy(example_file_server, file.path(target_dir, "server.R"), overwrite = TRUE)
  message("server.R file copied to ", file.path(target_dir, "server.R"))
}
