# Copy template files into project

`get_template` copies example files from the package's `templates`
directory into the user's current working directory or a specified
subdirectory.

## Usage

``` r
get_template(template_name = NULL, install_to = NULL)
```

## Arguments

- template_name:

  Optional string. Name of the template to use. Corresponds to a folder
  name `templates/`. If NULL (default) within an interactive session,
  the function will list available templates and prompt the user to
  select one.

- install_to:

  Optional string. Directory where the example files should be copied.
  If NULL (default), the current working directory will be used.

## Value

NULL. Called for its side effects: copying template files into the
user's project directory.

## Examples

``` r
if (interactive()) {
  get_template() # prompts user to select an example
}

tmpdir <- file.path(tempdir(), "wastewater_test")
get_template(template_name = "shiny_wastewater", install_to = tmpdir)
#> Copied app.R to /tmp/Rtmp98QbCX/wastewater_test
#> Copied icon.png to /tmp/Rtmp98QbCX/wastewater_test
#> Copied logo.png to /tmp/Rtmp98QbCX/wastewater_test

# Cleanup
unlink(tmpdir, recursive = TRUE)
```
