#' @title Get the Latest Branding File
#' @description Downloads the latest _brand.yml file from the repository and compares it with the local _brand.yml file. If they are different, prompts the user to overwrite the local file. If the local file does not exist, it will be created.
#' @details Reads configuration from config.yml. Handles download errors and file comparison using MD5 hashes. Prompts user for action if files differ.
#' @return No return value. Side effects: may overwrite _brand.yml and create bak_brand.yml.
#' @examples
#' # Initialize config and local brand file
#' brand_init()
#' # Update local brand file if needed
#' get_brand()
#' @importFrom utils download.file
#' @export
get_brand <- function() {
  # This function downloads the latest _brand.yml file from the repository
  # and compares it with the local _brand.yml file.
  # If they are different, it prompts the user to overwrite the local file.
  # If the local file does not exist, it will be created.

  # load the config file
  # if you want to use a different config file, you can uncomment the line below
  # and provide the path to your config file.

  # read a yaml file with the remote and local file paths
  read_yaml <- function(file) {
    if (!file.exists(file)) {
      stop(paste("File not found:", file))
    }
    yaml::yaml.load_file(file)
  }
  config <- read_yaml("config.yml")
  remote_file <- config$remote_file
  local_file <- config$local_file




  tempfile_name <- tempfile()
  # add exception handling if the download fails
  tryCatch(
    {
      message("Checking remote version... ")
      download.file(
        remote_file,
        destfile = tempfile_name,
        quiet = TRUE
      )
    },
    error = function(e) {
      message(paste("Error downloading file:", e))
    }
  )


  temp_hash <- tools::md5sum(tempfile_name)
  local_hash <- tools::md5sum(local_file)



  # prompt user to overwrite if the hashes are not equal.
  # add exception handling is the file is not found
  if (local_hash != temp_hash) {
    message("The local file is different from the remote file.")
    message("1: Overwrite the local file with the remote file")
    message("2: Overwrite the local file with the remote file and save a backup to bak_brand.yml")
    message("3: Do nothing")
    message("\nPlease Select an option: (1/2/3): ")
    answer <- readline()
    if (answer == "1") {
      file.copy(tempfile_name, "_brand.yml", overwrite = TRUE)
      message("_brand.yml replaced with latest from repository.")
    }
    if (answer == "2") {
      file.copy("_brand.yml", "bak_brand.yml", overwrite = TRUE)
      file.copy(tempfile_name, "_brand.yml", overwrite = TRUE)
      message("_brand.yml replaced with latest from repository.")
      message("backup saved to bak_brand.yml")
    }
    if (answer == "3") {
      message("No action taken.")
    }
    # add validation that answer is in 1,2,3
  } else {
    message("The local file is the same as the remote file. No action taken.")
  }
}


#' @title Initialize Branding Config
#' @description Initializes the branding by creating a config.yml file with the remote and local file paths, and a placeholder _brand.yml file.

#' @details This function is intended to be run once to set up the configuration for branding file management.
#' @return No return value. Side effects: creates config.yml and _brand.yml.
#' @examples
#' brand_init()
#' @export
#' @param get_default_brand Logical. If TRUE, downloads and writes the default _brand.yml from the remote repository. If FALSE, creates a placeholder _brand.yml file.
brand_init <- function(get_default_brand = TRUE) {

  config <- list(
    remote_file = "https://raw.githubusercontent.com/EpiForeSITE/branding-package/main/_brand.yml",
    local_file = "_brand.yml"
  )

  # make a yml file with these keys
  yaml::write_yaml(config, "config.yml")

  if (get_default_brand){

  } else {
  fileConn<-file("_brand.yml")
  writeLines(c("this file needs to be updated with rbrand::get_brand()"), fileConn)
  close(fileConn)
  }
}
