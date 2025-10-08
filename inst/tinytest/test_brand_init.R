# Test default parameters
expect_message(brand_init(), "Created files")

expect_true(file.exists("rbranding_config.yml"))
expect_true(file.exists("_brand.yml"))

expect_true(grepl("Update file with rbranding::get_brand()", readLines("_brand.yml")))

file.remove("rbranding_config.yml", "_brand.yml")

