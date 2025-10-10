library(rbranding)

test_dir <- file.path(tempdir(), "test_get_brand_gha")
if (!dir.exists(test_dir)) {
    dir.create(test_dir, recursive = TRUE)
}

brand_filepath <- file.path(test_dir, "_brand.yml")

# Test Case 1: Public Repository
message("\nTesting get_brand_public()...")

tryCatch({

    get_brand_public(
        remote_file = "https://raw.githubusercontent.com/EpiForeSITE/rbranding/main/_brand.yml",
        local_file = brand_filepath,
        run_interactive = FALSE
    )

    # Check file was downloaded
    if (!file.exists(brand_filepath)) {
        stop("Failed to download brand file from public repository")
    }

    # Verify contents of downloaded brand file
    public_brand <- yaml::read_yaml(brand_filepath)
    if (public_brand$meta$name != "rbranding") {
        stop("Downloaded public brand file does not match expected content")
    }

    # Cleanup
    file.remove(brand_filepath)
    message("Public repository test passed successfully!")
}, error = function(e) {
    stop(paste("Public repository test failed:", e$message))
})

# Test Case 2: Private Repository
message("\nTesting get_brand_private_github()...")

tryCatch({

    get_brand_private_github(
        remote_file = "https://raw.githubusercontent.com/EpiForeSITE/test-private-gha/main/_brand.yml",
        local_file = brand_filepath,
        run_interactive = FALSE
    )

    # Check file was downloaded
    if (!file.exists(brand_filepath)) {
        stop("Failed to download brand file from private repository")
    }

    # Verify contents of downloaded brand file
    private_brand <- yaml::read_yaml(brand_filepath)

    if (private_brand$meta$name != "Private Test Brand File") {
        stop("Downloaded private brand file does not match expected content")
    }

    # Cleanup
    file.remove(brand_filepath)
    message("Private repository test passed successfully!")
}, error = function(e) {
    stop(paste("Private repository test failed:", e$message))
})

# Cleanup
unlink(test_dir, recursive = TRUE)
message("\nAll tests completed successfully!")
