#' @title Get Shiny Templates
#' Copy Example App Files from inst/examples to inst/app
#'
#' @param example_name Optional string. Name of the example folder under inst/examples. If NULL, the function will list available examples and prompt the user to select one.
#' @param install_to Directory where the example files should be copied. Defaults to the current working directory.
#'
#' @returns NULL (called for side effects)
#' @export
#'
#' @examples
#' if (interactive()) {
#'   get_template() # prompts user to select an example
#' }
get_template <- function(example_name = NULL, install_to = "") {

  if (is.null(example_name)) {

    examples <- list.dirs(system.file("examples", package = "rbranding"), full.names = FALSE, recursive = FALSE)

    message("Choose from the following templates:")
    for (i in 1:length(examples)) {
      message(i, ": ", examples[i])
    }
    message("Press enter: Abort")
    answer <- readline()

    answer <- as.integer(answer)

    if (is.na(answer) || answer < 1 || answer > length(examples)) {
      message("Template selection aborted")
      return(invisible())
    }

    example_name <- examples[answer]
  }

  # Find the source directory inside the package
  source_dir <- system.file("examples", example_name, package = "rbranding")
  if (source_dir == "") {
    stop(paste0("Example folder '", example_name, "' not found in the package under inst/examples."))
  }
  # Target directory in user's project
  target_dir <- file.path(getwd(), install_to)
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
    file.copy(f, file.path(target_dir, basename(f)), overwrite = TRUE, recursive = TRUE)
    message("Copied ", basename(f), " to ", target_dir)
  }
}
