#' @title Get Shiny Templates
#' Copy Example App Files from inst/examples to inst/app
#'
#' @param example_name Name of the example folder under inst/examples
#' @export
get_template <- function(example_name) {
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


