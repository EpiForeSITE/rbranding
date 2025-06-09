# branding-package

Facilitate the creation of Shiny apps for CFA projects that conform to STLTs’ branding and design standards, and automatically provide as much accessibility to ForeSITE Shiny apps as possible.

<!-- badges: start -->
  [![R-CMD-check](https://github.com/EpiForeSITE/branding-package/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EpiForeSITE/branding-package/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

## Overview

The `branding-package` helps R developers quickly build Shiny applications that are visually consistent, accessible, and easy to maintain. It provides tools to manage branding assets, apply organization-wide themes, and streamline the setup of new projects.

## Features
- **Branding File Management:** Download, update, and validate branding YAML files for consistent theming.
- **Shiny App Templates:** Quickly scaffold Shiny apps that follow best practices for branding and accessibility.
- **Accessibility:** Built-in support for accessible color palettes and UI components.
- **Integration:** Easily integrates with [bslib](https://rstudio.github.io/bslib/), [thematic](https://rstudio.github.io/thematic/), and other modern R packages.

## Installation

```r
# Install from GitHub (if not on CRAN)
remotes::install_github("EpiForeSITE/branding-package")

# Initialize branding config (run in the R console)
library(rbranding)
brand_init()
# You may edit the generated config.yml file if necessary.

# Update or fetch the latest branding file (run in the R console)
get_brand()

```

> **Note:** `brand_init()` and `get_brand()` are intended to be run interactively from the R console, not inside scripts.

3. **Use in your Shiny app:**
   - Load the branding YAML and apply the theme in your UI/server code.

## Example

```r
library(shiny)
library(bslib)
library(rbranding)

# Initialize or update branding (run these in the R console)
brand_init()
get_brand()

ui <- fluidPage(
  theme = bs_theme(),
  # ... your UI ...
)

server <- function(input, output, session) {
  # ... your server logic ...
}

shinyApp(ui, server)
```

## Documentation
- Function documentation is available via `?get_brand` and `?brand_init` after loading the package.
- See the [pkgdown site](https://EpiForeSITE.github.io/branding-package/) for full reference and vignettes.

## Contributing
Pull requests and issues are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License
MIT
