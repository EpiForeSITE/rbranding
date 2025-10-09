#' Copy template files into project
#'
#' `get_template` copies example files from the package's `examples`
#' directory into the user's current working directory or a
#' specified subdirectory.
#'
#' @param template_name Optional string. Name of the template to use.
#' Corresponds to a folder name `examples/`. If NULL (default) within an
#' interactive session, the function will list available examples and
#' prompt the user to select one.
#' @param install_to Optional string. Directory where the example files
#' should be copied. If NULL (default), the current working directory
#' will be used.
#'
#' @returns NULL. Called for its side effects: copying template files into
#' the user's project directory.
#' @export
#'
#' @examples
#' if (interactive()) {
#'   get_template() # prompts user to select an example
#' }
#'
#' tmpdir <- file.path(tempdir(), "wastewater_test")
#' get_template(template_name = "wastewater", install_to = tmpdir)
#'
#' # Cleanup
#' unlink(tmpdir, recursive = TRUE)
get_template <- function(template_name = NULL, install_to = NULL) {

  if (is.null(template_name)) {

    if (!interactive()) {
      stop("template_name must be provided in non-interactive sessions")
    }

    examples <- list.dirs(
      system.file("examples", package = "rbranding"),
      full.names = FALSE,
      recursive = FALSE
    )
    
    # Filter out excluded templates (hardcoded exclusion list)
    excluded_templates <- c("wastewater")
    examples <- examples[!examples %in% excluded_templates]

    message("Choose from the following templates:")
    for (i in seq_along(examples)) {
      message(i, ": ", examples[i])
    }
    message("Press enter: Abort")
    answer <- readline()

    answer <- as.integer(answer)

    if (is.na(answer) || answer < 1 || answer > length(examples)) {
      message("Template selection aborted")
      return(invisible())
    }

    template_name <- examples[answer]
  }

  # Find the source directory inside the package
  source_dir <- system.file("examples", template_name, package = "rbranding")
  if (source_dir == "") {
    stop(
      "Template '",
      template_name,
      "' not found in package. Please select a different template."
    )
  }

  # List all files in the source directory
  files <- list.files(source_dir, full.names = TRUE)
  if (length(files) == 0) {
    stop("No files found for template '", template_name, "'.")
  }

  # Target directory in user's project
  target_dir <- install_to %||% getwd()

  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE)
  }

  # Copy each file to the target directory
  for (f in files) {
    file.copy(f, file.path(target_dir, basename(f)), overwrite = TRUE)
    message("Copied ", basename(f), " to ", target_dir)
  }
}
