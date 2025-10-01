#' @title Initialize Branding Config
#' @description Initializes the branding by creating a config.yml file with the remote and local file paths, and a placeholder _brand.yml file.

#' @details This function is intended to be run once to set up the configuration for branding file management.
#' @param get_default_brand Logical. If TRUE, calls get_brand() to download the latest branding file after initialization. Default is TRUE.
#' @return No return value. Side effects: creates config.yml and _brand.yml.
#' @examples
#' brand_init(get_default_brand = FALSE)
#' # Cleanup
#' file.remove("config.yml", "_brand.yml")
#' @export
brand_init <- function(get_default_brand = TRUE) {

  config <- list(
    remote_host = "https://github.com/",
    remote_file = "https://raw.githubusercontent.com/EpiForeSITE/rbranding/main/_brand.yml",
    local_file = "_brand.yml"
  )

  # make a yml file with these keys
  yaml::write_yaml(config, "config.yml")

  fileConn<-file("_brand.yml")
  writeLines(c("this file needs to be updated with rbranding::get_brand()"), fileConn)
  close(fileConn)
  if (get_default_brand){
    get_brand()
  } else {
  }
  message("config.yml created with remote and local file paths.  Initial _brand.yml created.")
}
