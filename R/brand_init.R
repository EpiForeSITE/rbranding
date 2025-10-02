#' Initialize branding configuration
#'
#' `brand_init` initializes the branding configuration by creating two files:
#' - `rbranding_config.yml`: contains remote and local file paths to brand files
#' - `_brand.yml`: a placeholder branding file
#' It is intended to be run once. Use `get_brand()` to download/update the brand
#' file.
#'
#' @returns NULL. Called for its side effects: creating `rbranding_config.yml` and `_brand.yml`
#' @export
#'
#' @importFrom yaml write_yaml
#'
#' @examples
#' brand_init()
#'
#' # Clean up
#' file.remove("rbranding_config.yml", "_brand.yml")
brand_init <- function() {

  brand_filename <- "_brand.yml"
  config_filename <- "rbranding_config.yml"

  config <- list(
    remote_file = "https://raw.githubusercontent.com/EpiForeSITE/rbranding/main/_brand.yml",
    remote_host = "https://github.com/",
    local_file = brand_filename
  )

  # make a yml file with these keys
  yaml::write_yaml(config, config_filename)

  fileConn <- file(brand_filename)
  writeLines(c("Update file with rbranding::get_brand()"), fileConn)
  close(fileConn)

  message(
    "Created files '", config_filename,
    "' and placeholder '_brand.yml' in current working directory."
  )
}
