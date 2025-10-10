# Test get_brand_public()

test_dir <- file.path(tempdir(), "test_get_brand_public")

suppressMessages(brand_init(install_path = test_dir))

# Test with standard parameters
# - Use `run_interactive = FALSE` to avoid prompts during testing
expect_message(get_brand_public(
    config_file = file.path(test_dir, "rbranding_config.yml"),
    run_interactive = FALSE
), "Local branding file overwritten with remote file")

brand_contents_1 <- yaml::read_yaml(file.path(test_dir, "_brand.yml"))
expect_equal("rbranding", brand_contents_1$meta$name)

# Test with non-existing local file
expect_message(get_brand_public(
    local_file = file.path(test_dir, "non_existing_brand.yml"),
    config_file = file.path(test_dir, "rbranding_config.yml"),
    run_interactive = FALSE
), "Local branding file created from remote file")

expect_true(file.exists(file.path(test_dir, "non_existing_brand.yml")))

brand_contents_2 <- yaml::read_yaml(file.path(test_dir, "_brand.yml"))
expect_identical(brand_contents_1, brand_contents_2)

# Test when no change to the brand file
expect_message(get_brand_public(
    config_file = file.path(test_dir, "rbranding_config.yml"),
    run_interactive = FALSE
), "The local file is the same as the remote file")

# Clean up directory to ensure files are different for next tests
unlink(test_dir, recursive = TRUE)

test_dir <- file.path(tempdir(), "test_get_brand_public")
suppressMessages(brand_init(install_path = test_dir))

# Test backup file creation
expect_message(get_brand_public(
    config_file = file.path(test_dir, "rbranding_config.yml"),
    run_interactive = FALSE,
    backup = TRUE,
    backup_folder = test_dir
), "Backup of local branding file saved")

bak_contents <- yaml::read_yaml(file.path(test_dir, "bak_brand.yml"))
expect_identical(bak_contents, "Update this file with rbranding::get_brand()")

# Cleanup
unlink(test_dir, recursive = TRUE)


# Test get_brand_private_github()
# - Run tests at home because a GitHub access token is required
# - Our CI (not CRAN) runs a separate test with the `GITHUB_TOKEN` environment variable
#    - See .github/workflows/test-get-brand.yaml
if (at_home()) {
    test_dir <- file.path(tempdir(), "test_get_brand_private_github")

    suppressMessages(brand_init(install_path = test_dir))

    # Test with auth token from git credential store
    expect_message(get_brand_private_github(
        config_file = file.path(test_dir, "rbranding_config.yml"),
        run_interactive = FALSE,
    ), "Local branding file overwritten with remote file")

    # Verify contents of downloaded brand file
    expect_identical(
        brand_contents_1,
        yaml::read_yaml(file.path(test_dir, "_brand.yml"))
    )

    # Test with invalid auth token
    expect_warning(get_brand_private_github(
        config_file = file.path(test_dir, "rbranding_config.yml"),
        auth_token = "invalid_token",
        run_interactive = FALSE,
    ), "404 Not Found")

    # Cleanup
    unlink(test_dir, recursive = TRUE)
}