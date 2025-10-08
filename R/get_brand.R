#' Helper function for downloading the branding file
#'
#' @param remote_file URL of the remote branding file
#' @param auth_token Authentication token for accessing private repositories
#'
#' @returns Path to the temporary file where the remote branding file is downloaded
#'
#' @importFrom utils download.file
download_branding_file <- function(remote_file, auth_token) {
  tmp_file <- tempfile()

  tryCatch({
    message("Checking remote version... ")
    utils::download.file(
      remote_file,
      destfile = tmp_file,
      quiet = TRUE,
      headers = c(
        Authorization = paste("Bearer", auth_token),
        Accept = "application/vnd.github.raw"
      )
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
compare_branding_files <- function(local_file, remote_file) {
  local_hash <- tools::md5sum(local_file)
  remote_hash <- tools::md5sum(remote_file)

  return(local_hash == remote_hash)
}

#' Helper function to update the local branding file
#'
#' @param local_file Path to the local branding file
#' @param remote_file Path to the remote branding file
#' @param backup Logical indicating whether to create a
#' backup of the local file (default: FALSE)
#'
#' @returns NULL. Called for its side effects: updating the local branding file and possibly
#' creating a backup file
update_branding_file <- function(local_file, remote_file, backup = FALSE) {
  if (backup) {
    file.copy(local_file, "bak_brand.yml", overwrite = TRUE)
    message("Backup of local file saved to 'bak_brand.yml'")
  }
  file.copy(remote_file, local_file, overwrite = TRUE)
  message("Local file overwritten with remote file")
}

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
#' @param config_file Path to the configuration file. Default is `rbranding_config.yml`.
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
get_brand <- function(config_file = "rbranding_config.yml") {

  # Read the configuration file
  config <- yaml::read_yaml(config_file)

  remote_file <- config$remote_file
  local_file <- config$local_file
  remote_host <- config$remote_host

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
      "1" = update_branding_file(local_file, tmp_file, backup = FALSE),
      "2" = update_branding_file(local_file, tmp_file, backup = TRUE),
      { message("No action taken.") }
    )
  } else {
    update_branding_file(local_file, tmp_file, backup = TRUE)
  }
}
