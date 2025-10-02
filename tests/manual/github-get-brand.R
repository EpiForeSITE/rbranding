library(rbranding)
library(yaml)

# Set GHA_TEST mode
Sys.setenv(GHA_TEST = TRUE)

# Function to run get_brand() with simulated user input
run_get_brand_with_input <- function() {
    # Save the original stdin connection
    old_stdin <- stdin()

    # Create a temporary connection that returns "1" for the menu choice
    temp_conn <- textConnection("1")

    # Redirect stdin to our temporary connection
    options(stdin = temp_conn)

    # Restore original stdin when we exit this function
    on.exit({
        close(temp_conn)
        options(stdin = old_stdin)
    })

    # Run get_brand()
    get_brand()
}

# Test Case 1: Public Repository
message("\nTesting get_brand() with public repository...")
file.copy("tests/manual/config-public.yml", "rbranding_config.yml", overwrite = TRUE)
tryCatch({
    run_get_brand_with_input()
    if (!file.exists("_brand.yml")) {
        stop("Failed to download brand file from public repository")
    }
    message("Public repository test passed successfully!")
}, error = function(e) {
    stop(paste("Public repository test failed:", e$message))
})

# Test Case 2: Private Repository
message("\nTesting get_brand() with private repository...")
file.copy("tests/manual/config-private.yml", "rbranding_config.yml", overwrite = TRUE)

tryCatch({
    run_get_brand_with_input()
    if (!file.exists("_brand.yml")) {
        stop("Failed to download brand file from private repository")
    }
    message("Private repository test passed successfully!")
}, error = function(e) {
    stop(paste("Private repository test failed:", e$message))
})

message("\nAll tests completed successfully!")
