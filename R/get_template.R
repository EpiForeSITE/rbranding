#' Copy Example App File to User Directory
#'
#' This function creates the folders `inst/app` in the user's working directory and copies the example file `link_plots.R` into that folder.
#' @export
get_template2 <- function() {
  target_dir <- file.path(getwd(), "inst", "app")
  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE)
  }
  example_file <- system.file("examples/shiny2", "app.R", package = "rbranding")
  if (example_file == "") {
    stop("Example file not found in the package.")
  }
  file.copy(example_file, file.path(target_dir, "app.R"), overwrite = TRUE)
  message("Example file copied to ", file.path(target_dir, "link_plots.R"))

  # Repeat for server.R
  example_file_server <- system.file("examples/shiny2", "server.R", package = "rbranding")
  if (example_file_server == "") {
    stop("server.R file not found in the package.")
  }
  file.copy(example_file_server, file.path(target_dir, "server.R"), overwrite = TRUE)
  message("server.R file copied to ", file.path(target_dir, "server.R"))



  # Repeat for server.R
  example_file_server <- system.file("examples/shiny2", "ui.R", package = "rbranding")
  if (example_file_server == "") {
    stop("ui.R file not found in the package.")
  }
  file.copy(example_file_server, file.path(target_dir, "ui.R"), overwrite = TRUE)
  message("server.R file copied to ", file.path(target_dir, "server.R"))
}

#' Copy Example App Files from inst/examples to inst/app
#'
#' @param example_name Name of the example folder under inst/examples
#' @export
get_example <- function(example_name) {
  # Find the source directory inside the package
  source_dir <- system.file("examples", example_name, package = "rbranding")
  if (source_dir == "") {
    stop(paste0("Example folder '", example_name, "' not found in the package under inst/examples."))
  }
  # Target directory in user's project
  target_dir <- file.path(getwd(), "inst", "app")
  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE)
  }
  # List all files in the source directory
  files <- list.files(source_dir, full.names = TRUE)
  if (length(files) == 0) {
    stop(paste0("No files found in example folder '", example_name, "'."))
  }
  # Copy each file to the target directory
  for (f in files) {
    file.copy(f, file.path(target_dir, basename(f)), overwrite = TRUE)
    message("Copied ", basename(f), " to ", target_dir)
  }
}


