#' Initialize branding configuration
#'
#' `brand_init` initializes the branding configuration by creating two files:
#' - `rbranding_config.yml`: contains remote and local file paths to brand files
#' - `_brand.yml`: a placeholder branding file
#' It is intended to be run once. Use `get_brand()` to download/update the brand
#' file.
#'
#' @param brand_url Optional URL. Points to the remote brand file. If `NULL`, defaults to
#' rbranding's brand file on GitHub.
#' @param host_url Optional URL. Points to the remote host. If `NULL`, defaults to GitHub.
#' @param install_path Optional string. Directory where the files should be created.
#' Defaults to the current working directory.
#'
#' @returns NULL. Called for its side effects: creating `rbranding_config.yml`
#' and `_brand.yml`
#' @export
#'
#' @importFrom yaml write_yaml
#'
#' @examples
#' tmpdir <- file.path(tempdir(), "brand_files")
#'
#' brand_init(install_path = tmpdir)
#'
#' # Clean up
#' unlink(tmpdir, recursive = TRUE)
brand_init <- function(brand_url = NULL, host_url = NULL, install_path = ".") {

  # Create install directory if it doesn't already exist
  if (!dir.exists(install_path)) {
    dir.create(install_path, recursive = TRUE)
  }

  # Define file paths
  brand_filename <- file.path(install_path, "_brand.yml")
  config_filename <- file.path(install_path, "rbranding_config.yml")

  # Define config content
  config <- list(
    remote_file = brand_url %||% "https://raw.githubusercontent.com/EpiForeSITE/rbranding/main/_brand.yml",
    remote_host = host_url %||% "https://github.com/",
    local_file = brand_filename
  )

  # Create config file
  yaml::write_yaml(config, config_filename)

  # Create placeholder brand file
  fileConn <- file(brand_filename)
  writeLines(c("Update this file with rbranding::get_brand()"), fileConn)
  close(fileConn)

  message(
    "Created files '", config_filename,
    "' and placeholder '_brand.yml' in ",
    ifelse(install_path == ".", "current working directory", install_path)
  )
}
