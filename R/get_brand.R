#' Download the latest branding file from a public source
#'
#' `get_brand_public` downloads the latest `_brand.yml` file from the remote
#' URL specified in `rbranding_config.yml` or provided as function arguments.
#' The remote file is assumed to be publicly accessible (no authentication),
#' such as a website or public GitHub repository.
#' If the local `_brand.yml` file does not exist, it will be created.
#' If the local file is different from the remote file, the function will save
#' the contents to `bak_brand.yml` (as backup) and overwrite the local file with
#' the contents of the remote file.
#' When the function is run interactively (e.g.,in RStudio console), the user is
#' instead prompted to choose whether to overwrite the file and whether or not
#' to create the backup.
#'
#' @inheritParams get_brand_private_github
#'
#' @returns NULL. Called for its side effects: updating `_brand.yml` and
#' possibly creating `bak_brand.yml`
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
#'   get_brand_public(
#'     config_file = file.path(tmpdir, "rbranding_config.yml")
#'   )
#'
#'   # Cleanup
#'   unlink(tmpdir, recursive = TRUE)
#' }
#'
#' # Non-interactive example
#' tmpdir <- file.path(tempdir(), "brand_files")
#' brand_init(install_path = tmpdir)
#'
#' get_brand_public(
#'  config_file = file.path(tmpdir, "rbranding_config.yml"),
#'  run_interactive = FALSE,
#'  backup = TRUE,
#'  backup_folder = tmpdir
#' )
#'
#' # Cleanup
#' unlink(tmpdir, recursive = TRUE)
get_brand_public <- function(
  remote_file = NULL,
  local_file = NULL,
  config_file = "rbranding_config.yml",
  run_interactive = TRUE,
  backup = FALSE,
  backup_folder = "."
) {

  # Read config
  config <- get_config(
    config_file = config_file,
    remote_file = remote_file,
    local_file = local_file
  )

  # Download the remote branding file and store in temp file
  tmp_remote_file <- download_public_branding_file(
    remote_file = config$remote_file
  )

  # Update or create local branding file
  update_branding_file(
    local_file = config$local_file,
    remote_file = tmp_remote_file,
    run_interactive = run_interactive,
    backup = backup,
    backup_folder = backup_folder
  )

}


#' Download the latest branding file from a private GitHub repository
#'
#' `get_brand_private_github` downloads the latest `_brand.yml` file from the
#' remote URL specified in `rbranding_config.yml` or provided as function
#' arguments.
#' The remote file is assumed to be in a private GitHub repository and requires
#' authentication.
#' If the local `_brand.yml` file does not exist, it will be created.
#' If the local file is different from the remote file, the function will save
#' the contents to `bak_brand.yml` (as backup) and overwrite the local file with
#' the contents of the remote file.
#' When the function is run interactively (e.g., in RStudio console), the user
#' is instead prompted to choose whether to overwrite the file and whether or
#' not to create the backup.
#'
#' @param remote_file Optional URL. Points to the remote brand file.
#' If `NULL`, the value in the configuration file will be used.
#' @param local_file Optional string. Path to the local branding file.
#' If `NULL`, the value in the configuration file will be used.
#' @param auth_token Optional authentication token for accessing the private
#' GitHub repository. If `NULL`, the function will attempt to retrieve the token
#' from the `GITHUB_TOKEN` environment variable or the git credential store.
#' @param config_file Path to the configuration file.
#' Default is `rbranding_config.yml`.
#' @param run_interactive Logical indicating whether to run interactively.
#' Defaults to TRUE.
#' @param backup Logical indicating whether to create a backup of the local file
#' if it is different from the remote file. Ignored if run interactively.
#' Defaults to FALSE.
#' @param backup_folder Folder where the backup file should be saved, if needed.
#' Defaults to current working directory.
#'
#' @returns NULL. Called for its side effects: updating `_brand.yml` and
#' possibly creating `bak_brand.yml`
#' @export
#'
#' @importFrom credentials git_credential_ask
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
#'   get_brand_private_github(
#'     config_file = file.path(tmpdir, "rbranding_config.yml")
#'   )
#'
#'   # Cleanup
#'   unlink(tmpdir, recursive = TRUE)
#' }
#'
#' \dontrun{
#'   # Example not run because it requires a GitHub
#'   # personal access token with repo access
#'
#'   tmpdir <- file.path(tempdir(), "brand_files")
#'   brand_init(install_path = tmpdir)
#'
#'   get_brand_private_github(
#'    config_file = file.path(tmpdir, "rbranding_config.yml"),
#'    auth_token = "your_github_token_here",
#'    run_interactive = FALSE,
#'    backup = TRUE,
#'    backup_folder = tmpdir
#'   )
#'
#'   # Cleanup
#'   unlink(tmpdir, recursive = TRUE)
#' }
get_brand_private_github <- function(
  remote_file = NULL,
  local_file = NULL,
  auth_token = NULL,
  config_file = "rbranding_config.yml",
  run_interactive = TRUE,
  backup = FALSE,
  backup_folder = "."
) {

  # Read config
  config <- get_config(
    config_file = config_file,
    remote_file = remote_file,
    local_file = local_file
  )

  # If no auth_token provided, try to get it from env or git credentials
  if (is.null(auth_token)) {
    # Check for the GITHUB_TOKEN environment variable
    auth_token <- if (Sys.getenv("GITHUB_TOKEN", "FALSE") != "FALSE") {
      Sys.getenv("GITHUB_TOKEN")
    } else {
      # Check the git credential store for GitHub credentials
      credentials::git_credential_ask("https://github.com/")$password
    }

    # If still no auth_token, stop with error
    if (is.null(auth_token)) {
      stop(
        "Unable to retrieve the branding file from the specified GitHub repo: ",
        "No authentication token.",
        "Please provide a token through one of the following methods:\n\n",
        "\t- Passing the `auth_token` parameter\n",
        "\t- Setting the `GITHUB_TOKEN` environment variable\n",
        "\t- Saving to the local git credential store\n\n",
        "For more information, visit:\n",
        "\t- https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token \n",
        "\t- https://docs.github.com/en/get-started/git-basics/caching-your-github-credentials-in-git \n"
      )
    }
  }

  # Download the remote branding file and store in temp file
  tmp_remote_file <- download_private_branding_file_gh(
    remote_file = config$remote_file,
    auth_token = auth_token
  )

  # Update or create local branding file
  update_branding_file(
    local_file = config$local_file,
    remote_file = tmp_remote_file,
    run_interactive = run_interactive,
    backup = backup,
    backup_folder = backup_folder
  )

}
