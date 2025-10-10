library(rbranding)

test_dir <- tempdir()
config_filepath <- file.path(test_dir, "rbranding_config.yml")
brand_filepath <- file.path(test_dir, "_brand.yml")

# Test Case 1: Public Repository
message("\nTesting get_brand_public()...")

file.copy(
    "tests/manual/config-public.yml",
    config_filepath,
    overwrite = TRUE
)

tryCatch({

    get_brand_public(
        config_file = config_filepath,
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

file.copy(
    "tests/manual/config-private.yml",
    config_filepath,
    overwrite = TRUE
)

tryCatch({

    get_brand_private_github(
        config_file = config_filepath,
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
