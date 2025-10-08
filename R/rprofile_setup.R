#' @title Install rbranding Auto-Update in .Rprofile
#' @description Adds code to .Rprofile that automatically checks and updates the _brand.yml file when R starts.
#' @details
#' This function modifies or creates an .Rprofile file in the specified project directory.
#' The added code will automatically check for updates to the _brand.yml file each time
#' R starts (unless --vanilla is used).
#'
#' The code block is wrapped with hash markers including a checksum for easy identification
#' and updates. All operations are wrapped in local() to avoid polluting the global environment
#' and in tryCatch() for safe error handling.
#'
#' @param project_path Character string specifying the project directory. Default is "." (current directory).
#' @return No return value. Side effects: creates or modifies .Rprofile in project_path.
#' @examples
#' \dontrun{
#' # Install in current directory
#' install_rbranding()
#'
#' # Install in a specific project
#' install_rbranding("~/my_project")
#' }
#' @export
install_rbranding <- function(project_path = ".") {
  tryCatch({
    # Normalize the path
    project_path <- normalizePath(project_path, mustWork = TRUE)
    rprofile_path <- file.path(project_path, ".Rprofile")

    # Generate the code to be inserted
    update_code <- .generate_update_code()
    code_hash <- .compute_code_hash(update_code)

    # Markers for the code block
    start_marker <- paste0("# >>> rbranding auto-update [", code_hash, "] >>>")
    end_marker <- "# <<< rbranding auto-update <<<"

    # Full code block with markers
    full_block <- c(
      start_marker,
      update_code,
      end_marker,
      ""
    )

    # Read existing .Rprofile or create empty
    if (file.exists(rprofile_path)) {
      existing_content <- readLines(rprofile_path, warn = FALSE)
    } else {
      existing_content <- character(0)
    }

    # Check if rbranding block already exists
    start_pattern <- "^# >>> rbranding auto-update \\[.*\\] >>>$"
    end_pattern <- "^# <<< rbranding auto-update <<<$"

    start_idx <- grep(start_pattern, existing_content)
    end_idx <- grep(end_pattern, existing_content)

    if (length(start_idx) > 0 && length(end_idx) > 0) {
      # Block exists - check if hash matches
      existing_hash <- sub("^# >>> rbranding auto-update \\[(.*)\\] >>>$", "\\1", existing_content[start_idx[1]])

      if (existing_hash == code_hash) {
        message("rbranding auto-update code is already up to date in .Rprofile")
        return(invisible(NULL))
      } else {
        # Hash doesn't match - replace the block
        message("Updating rbranding auto-update code in .Rprofile")
        new_content <- c(
          if (start_idx[1] > 1) existing_content[1:(start_idx[1] - 1)],
          full_block,
          if (end_idx[1] < length(existing_content)) existing_content[(end_idx[1] + 1):length(existing_content)]
        )
      }
    } else {
      # Block doesn't exist - append it
      message("Adding rbranding auto-update code to .Rprofile")
      new_content <- c(existing_content, "", full_block)
    }

    # Write to temporary file first
    temp_file <- tempfile()
    writeLines(new_content, temp_file)

    # Copy temp file to .Rprofile
    file.copy(temp_file, rprofile_path, overwrite = TRUE)
    file.remove(temp_file)

    message("Successfully configured .Rprofile for automatic branding updates")
  }, error = function(e) {
    message(paste("Failed to install/update .Rprofile:", e$message))
  })
}

#' @title Update rbranding Auto-Update Code in .Rprofile
#' @description Updates the rbranding auto-update code in .Rprofile if a new version is available.
#' @details This is a convenience wrapper around install_rbranding() that performs the same operation.
#' @param project_path Character string specifying the project directory. Default is "." (current directory).
#' @return No return value. Side effects: modifies .Rprofile in project_path if update is needed.
#' @examples
#' \dontrun{
#' # Update in current directory
#' update_rbranding()
#'
#' # Update in a specific project
#' update_rbranding("~/my_project")
#' }
#' @export
update_rbranding <- function(project_path = ".") {
  install_rbranding(project_path)
}

#' Generate the update code to be inserted into .Rprofile
#' @keywords internal
#' @noRd
.generate_update_code <- function() {
  c(
    "local({",
    "  tryCatch({",
    "    # Check if rbranding config exists",
    "    if (file.exists(\"config.yml\") && file.exists(\"_brand.yml\")) {",
    "      # Check for updates",
    "      if (requireNamespace(\"rbranding\", quietly = TRUE)) {",
    "        rbranding::update_brand_silent()",
    "      }",
    "    }",
    "  }, error = function(e) {",
    "    # Silently ignore errors to not disrupt R startup",
    "    invisible(NULL)",
    "  })",
    "})"
  )
}

#' Compute hash of code block
#' @keywords internal
#' @noRd
.compute_code_hash <- function(code) {
  # Use tools::md5sum on a temp file for hash computation
  temp <- tempfile()
  writeLines(code, temp)
  hash <- tools::md5sum(temp)
  unlink(temp)
  as.character(hash)
}

#' @title Silently Update Brand File
#' @description Non-interactive version of get_brand() for use in .Rprofile
#' @details
#' This function checks if the local _brand.yml file differs from the remote version
#' and automatically updates it if needed. It returns a message indicating the result
#' but does not prompt for user input.
#'
#' This function is primarily intended for internal use by the .Rprofile automation,
#' but is exported so it can be called from there.
#'
#' @return Character string with status message (invisible).
#' @export
update_brand_silent <- function() {
  tryCatch({
    # Check if config exists
    if (!file.exists("config.yml")) {
      message("No config.yml found - run brand_init() to set up branding")
      return(invisible("no_config"))
    }

    if (!file.exists("_brand.yml")) {
      message("No _brand.yml found - run brand_init() to set up branding")
      return(invisible("no_brand"))
    }

    # Read config
    config <- yaml::yaml.load_file("config.yml")
    remote_file <- config$remote_file
    local_file <- config$local_file

    # Download remote file to temp location
    temp_file <- tempfile()

    # Try download without authentication (for public repos)
    download_success <- tryCatch({
      download.file(remote_file, destfile = temp_file, quiet = TRUE, method = "auto")
      TRUE
    }, error = function(e) {
      FALSE
    })

    if (!download_success) {
      # Silently fail - couldn't download
      return(invisible("download_failed"))
    }

    # Compare hashes
    temp_hash <- tools::md5sum(temp_file)
    local_hash <- tools::md5sum(local_file)

    if (is.na(temp_hash)) {
      # Download didn't work properly
      return(invisible("download_failed"))
    }

    if (local_hash != temp_hash) {
      # Update needed
      file.copy(temp_file, local_file, overwrite = TRUE)
      message("_brand.yml updated to latest version")
      return(invisible("updated"))
    } else {
      message("_brand.yml is up to date")
      return(invisible("up_to_date"))
    }
  }, error = function(e) {
    # Silently handle errors
    return(invisible("error"))
  })
}
