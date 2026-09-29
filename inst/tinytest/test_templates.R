# Shiny templates apply the brand from _brand.yml
# Each template is installed into a temporary directory together with the
# bundled ForeSITE _brand.yml, as a user would after brand_init() and
# get_brand_public(). Tests are skipped when a template's packages are missing.

setup_template <- function(template_name) {
  dir <- file.path(tempdir(), paste0("test_", template_name))
  unlink(dir, recursive = TRUE)
  suppressMessages(get_template(template_name, install_to = dir))
  brand_dir <- system.file("brand_files", package = "rbranding")
  file.copy(list.files(brand_dir, full.names = TRUE), dir,
            recursive = TRUE, overwrite = TRUE)
  dir
}

has_pkgs <- function(pkgs) {
  all(vapply(pkgs, requireNamespace, logical(1), quietly = TRUE))
}

brand_primary <- "#A60F2D" # ForeSITE crimson, the primary color in brand_files

# shiny_kmeans: the UI uses a Bootstrap 5 theme built from _brand.yml ---------
if (has_pkgs(c("shiny", "bslib", "sass", "ggplot2"))) {
  dir <- setup_template("shiny_kmeans")
  old_wd <- setwd(dir)

  ui <- suppressMessages(suppressWarnings(
    source("ui.R", local = new.env(parent = asNamespace("shiny")))$value
  ))
  rendered <- htmltools::renderTags(ui)
  bootstrap <- Filter(function(d) d$name == "bootstrap", rendered$dependencies)

  expect_equal(length(bootstrap), 1L)
  expect_true(startsWith(as.character(bootstrap[[1]]$version), "5"))

  # The compiled CSS includes the brand's primary color
  css_files <- file.path(
    bootstrap[[1]]$src$file,
    unlist(lapply(bootstrap[[1]]$stylesheet, function(x) if (is.list(x)) x$href else x))
  )
  css <- paste(unlist(lapply(css_files[file.exists(css_files)], readLines, warn = FALSE)),
               collapse = "\n")
  expect_true(grepl(brand_primary, css, ignore.case = TRUE))

  suppressMessages(brand_reset_ggplot())
  setwd(old_wd)
  unlink(dir, recursive = TRUE)
}

# shiny_complex: the value box uses the brand's primary color ------------------
complex_pkgs <- c("shiny", "shinydashboard", "htmltools", "bslib", "shinyWidgets",
                  "plotly", "leaflet", "janitor", "lubridate", "tidyverse", "yaml")
if (has_pkgs(complex_pkgs)) {
  dir <- setup_template("shiny_complex")
  old_wd <- setwd(dir)

  app_env <- new.env()
  suppressMessages(suppressWarnings(source("app.R", local = app_env)))
  valuebox_html <- NULL
  tryCatch(
    shiny::testServer(function(input, output, session) app_env$server(input, output), {
      valuebox_html <<- output$valuebox1$html
    }),
    error = function(e) NULL # reported by the expectations below
  )

  expect_true(!is.null(valuebox_html))
  expect_true(grepl("small-box", valuebox_html))
  expect_true(grepl(brand_primary, valuebox_html, ignore.case = TRUE))

  setwd(old_wd)
  unlink(dir, recursive = TRUE)
}
