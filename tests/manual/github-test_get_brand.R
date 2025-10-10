library(rbranding)

# Test Case 1: Public Repository
message("\nTesting get_brand_public()...")
file.copy("tests/manual/config-public.yml", "rbranding_config.yml", overwrite = TRUE)
tryCatch({
    get_brand_public(run_interactive = FALSE)
    if (!file.exists("_brand.yml")) {
        stop("Failed to download brand file from public repository")
    }
    file.remove("_brand.yml")
    message("Public repository test passed successfully!")
}, error = function(e) {
    stop(paste("Public repository test failed:", e$message))
})

# Test Case 2: Private Repository
message("\nTesting get_brand_private_github()...")
file.copy("tests/manual/config-private.yml", "rbranding_config.yml", overwrite = TRUE)

tryCatch({
    get_brand_private_github(run_interactive = FALSE)
    if (!file.exists("_brand.yml")) {
        stop("Failed to download brand file from private repository")
    }
    file.remove("_brand.yml")
    message("Private repository test passed successfully!")
}, error = function(e) {
    stop(paste("Private repository test failed:", e$message))
})

message("\nAll tests completed successfully!")
