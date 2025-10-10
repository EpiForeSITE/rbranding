#' Helper function to read and validate the configuration file
#'
#' @param config_file Named list. Config containing `remote_file` and `local_file`
#'
#' @returns NULL. Called for its side effects: throws an error if the config is invalid
#'
#' @keywords internal
#' @noRd
validate_config <- function(config) {
  if (is.null(config$remote_file) | !is.character(config$remote_file)) {
    stop(
      "In the provided configuration file, 'remote_file' is either missing or invalid.",
      "Use brand_init() to create a valid config file."
    )
  }

  if (is.null(config$local_file) | !is.character(config$local_file)) {
    stop(
      "In the provided configuration file, 'local_file' is either missing or invalid.",
      "Use brand_init() to create a valid config file."
    )
  }
}


#' Helper function to setup config
#'
#' `get_config` reads the configuration file if it exists, otherwise it
#' uses the provided parameters to create a config list. If both the config file
#' and parameters are provided, the parameters will override the config file values.
#' If neither the config file nor the parameters are provided, an error is thrown.
#'
#' @param config_file Path to the configuration file. Default is `rbranding_config.yml`.
#' @param remote_file Optional URL. Points to the remote brand file. If `NULL`, the value
#' in the configuration file will be used.
#' @param local_file Optional string. Path to the local branding file. If `NULL`,
#' the value in the configuration file will be used.
#'
#' @returns Named list. Config containing `remote_file` and `local_file`
#'
#' @importFrom yaml read_yaml
#'
#' @keywords internal
#' @noRd
get_config <- function(
  config_file = "rbranding_config.yml",
  remote_file = NULL,
  local_file = NULL
  ) {

  # Create empty config
  config <- list()

  if (file.exists(config_file)) {

    config <- yaml::read_yaml(config_file)

    validate_config(config)

  } else if (is.null(remote_file) | is.null(local_file)) {
    stop(
      "Configuration file '", config_file, "' doesn't exist and parameters `remote_file` and `local_file` are missing.",
      "Please provide the parameters or create a config with brand_init()"
      )
  }

  # Override config values with function arguments, if provided
  if (!is.null(remote_file)) {
    config$remote_file <- remote_file
  }

  if (!is.null(local_file)) {
    config$local_file <- local_file
  }

  # Return final config list
  config
}


#' Helper function for downloading the branding file from public source
#'
#' @param remote_file URL of the remote branding file
#'
#' @returns Path to the temporary file where the remote branding file is downloaded
#'
#' @importFrom utils download.file
#'
#' @keywords internal
#' @noRd
download_public_branding_file <- function(remote_file) {
  tmp_file <- tempfile()

  tryCatch({
    message("Checking remote version... ")
    utils::download.file(
      remote_file,
      destfile = tmp_file,
      quiet = TRUE
    )
  }, error = function(e) {
    message(paste("Error downloading file:", e))
  })

  tmp_file
}


#' Helper function to compare local and remote branding files using MD5 hashes
#'
#' @param local_file Path to the local branding file
#' @param remote_file Path to the remote branding file
#'
#' @returns TRUE if files are identical, FALSE otherwise
#'
#' @importFrom tools md5sum
#'
#' @keywords internal
#' @noRd
compare_branding_files <- function(local_file, remote_file) {
  local_hash <- tools::md5sum(local_file)
  remote_hash <- tools::md5sum(remote_file)

  return(local_hash == remote_hash)
}


#' Helper function to backup the local branding file
#'
#' `backup_branding_file` creates a backup copy of the local branding file
#' named `bak_brand.yml` in the specified backup folder.
#'
#' @param local_file Path to the local branding file
#' @param backup_folder Folder where the backup file should be saved. Defaults to
#' current working directory.
#'
#' @returns NULL. Called for its side effects: creating a backup file
#'
#' @keywords internal
#' @noRd
backup_branding_file <- function(local_file, backup_folder = ".") {
  # Create backup folder if it doesn't already exist
  if (!dir.exists(backup_folder)) {
    dir.create(backup_folder, recursive = TRUE)
  }

  backup_filepath <- file.path(backup_folder, "bak_brand.yml")

  # Copy the local file to the backup location
  file.copy(local_file, backup_filepath, overwrite = TRUE)

  message(
    "Backup of local branding file saved to '",
    backup_filepath,
    "'"
  )
}


#' Helper function to overwrite the local branding file with the remote file
#'
#' @param local_file Path to the local branding file
#' @param remote_file Path to the remote branding file
#' @param backup Logical indicating whether to create a
#' backup of the local file. Defaults to FALSE
#' @param backup_folder Folder where the backup file should be saved. Defaults to current working directory
#'
#' @returns NULL. Called for its side effects: updating the local branding file and possibly
#' creating a backup file
#'
#' @keywords internal
#' @noRd
overwrite_local_brand_file <- function(local_file, remote_file, backup = FALSE, backup_folder = ".") {

  if (backup) {
    backup_branding_file(local_file, backup_folder)
  }

  file.copy(remote_file, local_file, overwrite = TRUE)
  message("Local branding file overwritten with remote file")
}
