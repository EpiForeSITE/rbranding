# Test default parameters (except install path, to avoid cluttering working directory)
test_dir <- file.path(tempdir(), "brand_init_test")
expect_message(brand_init(install_path = test_dir), "Created files")

brand_filepath <- file.path(test_dir, "_brand.yml")
config_filepath <- file.path(test_dir, "rbranding_config.yml")

expect_true(file.exists(config_filepath))
expect_true(file.exists(brand_filepath))

expect_true(grepl("Update this file with rbranding::get_brand_public()", readLines(brand_filepath)))

unlink(test_dir, recursive = TRUE)


# Test alternate parameters
# - Install directory with several levels that don't exist yet
test_dir <- file.path(tempdir(), "brand_files/brand_init_test")
# - Host and remote file URLs that are different than defaults
test_host <- "https://example.com"
test_file <- "https://example.com/brand.yml"

suppressMessages(brand_init(
    brand_url = test_file,
    install_path = test_dir
    ))

expect_true(file.exists(file.path(test_dir, "rbranding_config.yml")))
expect_true(file.exists(file.path(test_dir, "_brand.yml")))

created_config <- yaml::read_yaml(file.path(test_dir, "rbranding_config.yml"))

expect_true(created_config$remote_file == test_file)
expect_true(created_config$local_file == file.path(test_dir, "_brand.yml"))
