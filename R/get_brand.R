#' Helper function for downloading the branding file
#'
#' @param remote_file URL of the remote branding file
#' @param auth_token Authentication token for accessing private repositories
#'
#' @returns Path to the temporary file where the remote branding file is downloaded
#'
#' @importFrom utils download.file
#'
#' @keywords internal
#' @noRd
download_branding_file <- function(remote_file, auth_token = NULL) {
  tmp_file <- tempfile()

  headers <- NULL

  if (!is.null(auth_token)) {
    headers <- c(
      Authorization = paste("Bearer", auth_token),
      Accept = "application/vnd.github.raw"
    )
  }

  tryCatch({
    message("Checking remote version... ")
    utils::download.file(
      remote_file,
      destfile = tmp_file,
      quiet = TRUE,
      headers = headers
    )
  }, error = function(e) {
    message(paste("Error downloading file:", e))
  })

  tmp_file
}


#' Helper function to update or create the local branding file
#'
#' `update_branding_file` checks if the local branding file exists and whether it is
#' different from the remote branding file. If the local file does not exist, it is
#' created from the remote file.
#' If the files are different and the function is running interactively, the user is
#' prompted to choose whether to overwrite the local file and whether or not to create
#' a backup.
#' If not running interactively, the local file is overwritten and a backup is created
#' according to the given parameters.
#'
#' @param local_file Path to the local branding file
#' @param remote_file Path to the remote branding file
#' @param run_interactive Logical indicating whether to run interactively. Defaults to TRUE.
#' @param backup Logical indicating whether to create a backup of the local file if it is
#' different from the remote file. Defaults to FALSE.
#' @param backup_folder Folder where the backup file should be saved. Defaults to current working
#' directory.
#'
#' @returns NULL. Called for its side effects: updating the local branding file and possibly
#' creating a backup file
#'
#' @keywords internal
#' @noRd
update_branding_file <- function(
  local_file,
  remote_file,
  run_interactive = TRUE,
  backup = FALSE,
  backup_folder = "."
  ) {

  if (!file.exists(local_file)) {
    # If local file does not exist, copy the temp file to local file
    file.copy(remote_file, local_file, overwrite = TRUE)
    message("Local branding file created from remote file.")

  } else if (compare_branding_files(local_file, remote_file)) {
    # If files are the same, do nothing
    message("The local file is the same as the remote file. No action taken.")

  } else if (run_interactive & interactive()) {
    # If files are different and running interactively, prompt user for action

    message(
      "The local branding file is different from the remote file. Select an option:\n\n",
      "1: Overwrite the local file\n",
      "2: Overwrite the local file and save a backup to bak_brand.yml\n\n",
      "Type your selection or hit 'Enter' to do nothing:"
    )

    answer <- readline()

    switch(answer,
      "1" = overwrite_local_brand_file(local_file, remote_file, backup = FALSE),
      "2" = overwrite_local_brand_file(local_file, remote_file, backup = TRUE, backup_folder = backup_folder),
      { message("No action taken.") }
    )

  } else {
    # If files are different and not running interactively, overwrite and create backup according to given parameteres
    overwrite_local_brand_file(local_file, remote_file, backup = backup, backup_folder = backup_folder)

  }
}


#' Download the latest branding file from a public source
#'
#' `get_brand_public` downloads the latest `_brand.yml` file from the remote
#' URL specified in `rbranding_config.yml` or provided as function arguments.
#' The remote file is assumed to be publicly accessible (no authentication), such as a
#' website or public GitHub repository.
#' If the local `_brand.yml` file does not exist, it will be created. If the local file is
#' different from the remote file, the function will save the contents to `bak_brand.yml`
#' (as backup) and overwrite the local file with the contents of the remote file. When the function
#' is run interactively (e.g., in RStudio console), the user is instead prompted to choose
#' whether to overwrite the file and whether or not to create the backup.
#'
#' @param remote_brand_file Optional URL. Points to the remote brand file. If `NULL`, the value
#' in the configuration file will be used.
#' @param local_file Optional string. Path to the local branding file. If `NULL`,
#' the value in the configuration file will be used.
#' @param config_file Path to the configuration file. Default is `rbranding_config.yml`.
#' @param run_interactive Logical indicating whether to run interactively. Defaults to TRUE.
#' @param backup Logical indicating whether to create a backup of the local file if it is
#' different from the remote file. Ignored if run interactively. Defaults to FALSE.
#' @param backup_folder Folder where the backup file should be saved, if needed.
#' Defaults to current working directory.
#'
#' @returns NULL. Called for its side effects: updating `_brand.yml` and possibly creating `bak_brand.yml`
#' @export
#'
#' @examples
#' # Interactive example
#' if (interactive()) {
#'   tmpdir <- file.path(tempdir(), "brand_files")
#'
#'   # Initialize config and local brand file
#'   brand_init(install_path = tmpdir)
#'
#'   # Update local brand file if needed
#'   get_brand_public()
#'
#'   # Cleanup
#'   unlink(tmpdir, recursive = TRUE)
#' } else {
#'   # Non-interactive example
#'   tmpdir <- file.path(tempdir(), "brand_files")
#'   brand_init(install_path = tmpdir)
#'
#'   get_brand_public(
#'    config_file = file.path(tmpdir, "rbranding_config.yml"),
#'    run_interactive = FALSE,
#'    backup = TRUE,
#'    backup_folder = tmpdir
#'   )
#'
#'   # Cleanup
#'   unlink(tmpdir, recursive = TRUE)
#' }
get_brand_public <- function(
  remote_brand_file = NULL,
  local_file = NULL,
  config_file = "rbranding_config.yml",
  run_interactive = TRUE,
  backup = FALSE,
  backup_folder = "."
) {

  # Read config
  config <- get_config(
    config_file = config_file,
    remote_file = remote_brand_file,
    local_file = local_file
  )

  # Download the remote branding file and store in temp file
  tmp_remote_file <- download_public_branding_file(remote_file = config$remote_file)

  # Update or create local branding file
  update_branding_file(
    local_file = config$local_file,
    remote_file = tmp_remote_file,
    run_interactive = run_interactive,
    backup = backup,
    backup_folder = backup_folder
  )

}

# get_brand_private_repo <- function() {

# }

#' Download the latest branding file
#'
#' `get_brand` downloads the latest `_brand.yml` file from the remote host
#' and URL specified in `rbranding_config.yml`. If the local `_brand.yml`
#' file does not exist, it will be created. If the local file is different
#' from the remote file, the function will save the contents to
#' `bak_brand.yml` (as backup) and overwrite the local file with the contents
#' of the remote file. When the function is run interactively (e.g., in
#' RStudio console), the user is instead prompted to choose whether to
#' overwrite the file and whether or not to create the backup.
#'
#' @param brand_url Optional URL. Points to the remote brand file. If `NULL`, the value
#' in the configuration file will be used.
#' @param host_url Optional URL. Points to the remote host. If `NULL`, the value
#' in the configuration file will be used.
#' @param local_file Optional string. Path to the local branding file. If `NULL`,
#' the value in the configuration file will be used.
#' @param config_file Path to the configuration file. Default is `rbranding_config.yml`.
#' @param backup_folder Folder where the backup file should be saved, if needed.
#' Defaults to current working directory.
#'
#' @returns NULL. Called for its side effects: updating `_brand.yml` and possibly creating `bak_brand.yml`
#' @export
#'
#' @importFrom utils download.file
#' @importFrom yaml read_yaml
#' @importFrom credentials git_credential_ask
#'
#' @examples
#' if (interactive()) {
#'  # Initialize config and local brand file
#'  brand_init()
#'
#'  # Update local brand file if needed
#'  get_brand()
#'
#'  # Cleanup
#'  file.remove("rbranding_config.yml", "_brand.yml", "bak_brand.yml")
#' }
get_brand <- function(
  brand_url = NULL,
  host_url = NULL,
  local_file = NULL,
  config_file = "rbranding_config.yml",
  backup_folder = ".") {

  # Read the configuration file
  config <- if(file.exists(config_file)) { yaml::read_yaml(config_file) } else { list() }

  # Set parameters from function arguments or config file
  remote_file <- brand_url %||% config$remote_file
  remote_host <- host_url %||% "https://github.com/"
  local_file <- local_file %||% config$local_file

  if (is.null(remote_file) | is.null(local_file)) {
    if (!file.exists(config_file)) {
      stop(
        "Configuration file '", config_file, "' does not exist and not all parameters were provided.\n",
        "Please provide all parameters directly or create a configuration file with brand_init()"
        )
    } else {
      stop(
        "Missing parameters. Please provide all parameters directly or through a configuration file created with brand_init()"
      )
    }
  }

  # Get authentication token (needed if accessing private repo)
  # - Check for GITHUB_TOKEN, otherwise, check the git credential store for the provided host
  auth_token <- if (Sys.getenv("GITHUB_TOKEN", "FALSE") != "FALSE") {
    Sys.getenv("GITHUB_TOKEN")
  } else {
    credentials::git_credential_ask(remote_host)$password
  }

  # Download the remote branding file and store in temp file
  tmp_file <- download_branding_file(remote_file, auth_token)

  # If local file does not exist, copy the temp file to local file
  if (!file.exists(local_file)) {
    file.copy(tmp_file, local_file, overwrite = TRUE)

    message(local_file, "created from remote repository.")

    return(invisible())
  }

  # Otherwise, check if the files are different
  if (compare_branding_files(local_file, tmp_file)) {
    message("The local file is the same as the remote file. No action taken.")
  } else if (interactive()) {

    message(
      "The local file is different from the remote file. Select an option:\n\n",
      "1: Overwrite the local file with the remote file\n",
      "2: Overwrite the local file with the remote file and save a backup to bak_brand.yml\n\n",
      "Type your selection or hit 'Enter' to do nothing:"
    )

    answer <- readline()

    switch(answer,
      "1" = overwrite_local_brand_file(local_file, tmp_file, backup = FALSE),
      "2" = overwrite_local_brand_file(local_file, tmp_file, backup = TRUE, backup_folder = backup_folder),
      { message("No action taken.") }
    )
  } else {
    overwrite_local_brand_file(local_file, tmp_file, backup = TRUE, backup_folder = backup_folder)
  }
}
