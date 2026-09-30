tmpdir <- file.path(tempdir(), "shiny_example_test")

expect_message(get_template(
    template_name = "shiny_basic",
    install_to = tmpdir
    ),
    "Copied"
)

if (!interactive()) {
    expect_error(
        get_template(),
        "template_name must be provided in non-interactive sessions"
    )
}

expect_error(
    get_template(template_name = "nonexistent_template"),
    "Template 'nonexistent_template' not found in package."
)

# Subdirectories are copied too (e.g., shiny_complex/www)
tmpdir_complex <- file.path(tempdir(), "shiny_complex_test")
suppressMessages(get_template("shiny_complex", install_to = tmpdir_complex))
expect_true(file.exists(file.path(tmpdir_complex, "www", "oi--circle-check.png")))

# All R code shipped in the templates parses
template_r_files <- list.files(
  system.file("templates", package = "rbranding"),
  pattern = "[.]R$", recursive = TRUE, full.names = TRUE
)
for (f in template_r_files) {
  expect_silent(parse(f), info = basename(dirname(f)))
}

# Cleanup
unlink(tmpdir, recursive = TRUE)
unlink(tmpdir_complex, recursive = TRUE)