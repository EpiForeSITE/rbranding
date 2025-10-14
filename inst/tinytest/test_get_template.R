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

# Cleanup
unlink(tmpdir, recursive = TRUE)