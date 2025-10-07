tmpdir <- file.path(tempdir(), "shiny1_test")

expect_message(get_template(
    template_name = "shiny1",
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