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
#' get_template(template_name = "shiny_wastewater", install_to = tmpdir)
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
    # excluded_templates <- c("shiny_wastewater") # Add any templates to exclude here
    # examples <- examples[!examples %in% excluded_templates]

    message("Choose from the following templates (for details, see the package documentation: https://epiforesite.github.io/rbranding/):")
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
  target_dir <- if (is.null(install_to)) getwd() else install_to

  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE)
  }

  # Copy each file to the target directory
  for (f in files) {
    file.copy(f, file.path(target_dir, basename(f)), overwrite = TRUE)
    message("Copied ", basename(f), " to ", target_dir)
  }

  # Copy the icon and logo files into the target directory
  icon_file <- system.file("template_resources", "icon.png", package = "rbranding")
  logo_file <- system.file("template_resources", "logo.png", package = "rbranding")

  # Don't overwrite existing icon/logo files
  if (file.copy(icon_file, target_dir)) {
    message("Copied icon.png to ", target_dir)
  }

  if (file.copy(logo_file, target_dir)) {
    message("Copied logo.png to ", target_dir)
  }
}
