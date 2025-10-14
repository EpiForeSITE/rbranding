
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rbranding

<!-- badges: start -->

[![ForeSITE
Group](https://github.com/EpiForeSITE/software/raw/e82ed88f75e0fe5c0a1a3b38c2b94509f122019c/docs/assets/foresite-software-badge.svg)](https://github.com/EpiForeSITE)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/EpiForeSITE/rbranding/blob/master/LICENSE.md)
[![R-CMD-check](https://github.com/EpiForeSITE/rbranding/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/EpiForeSITE/rbranding/actions/workflows/R-CMD-check.yaml)
[![pkgdown](https://github.com/EpiForeSITE/rbranding/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/EpiForeSITE/rbranding/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

The rbranding package is a tool for building projects that are visually
consistent, accessible, and easy to maintain. It provides functions for
managing branding assets, applying organization-wide themes using
’\_brand.yml’, and setting up new projects with accessibility features
and correct branding. It supports ‘Quarto’, ‘Shiny’, and ‘RMarkdown’
projects, and integrates with other packages such as ‘ggplot2’ for
producing branded graphics and visualizations.

## Package Features

- **Branding File Management:** Download, update, and validate branding
  YAML files for consistent theming
- **Project Templates:** Quickly scaffold Shiny apps or Quarto websites
  that follow best practices for branding and accessibility
- **Accessibility:** Built-in support for accessible color palettes and
  UI components
- **Integration:** Easily integrates with
  [`ggplot2`](https://ggplot2.tidyverse.org)
  [`bslib`](https://rstudio.github.io/bslib/),
  [`thematic`](https://rstudio.github.io/thematic/), and other modern R
  packages

## Installation

You can install the stable version of rbranding from CRAN with:

``` r
install.packages("rbranding")
```

To get a bug fix or to use a feature from the development version, you
can install the development version of rbranding from
[GitHub](https://github.com/EpiForeSITE/rbranding) with:

``` r
# install.packages("remotes")
remotes::install_github("EpiForeSITE/rbranding")
```

Alternatively, the development version of rbranding is also available
from the R-universe project at <https://epiforesite.r-universe.dev/>
with:

``` r
install.packages('rbranding', repos = c('https://epiforesite.r-universe.dev', 'https://cloud.r-project.org'))
```

## Usage

Use `brand_init()` to initialize the branding setup. This function
generates the `rbranding_config.yml` and `_brand.yml` files.

``` r
brand_init()
```

The generated `_brand.yml` file contains placeholder text. You will need
to edit the config file with the URL of your brand file, then download
that file using `get_brand_public()` or `get_brand_private_github()`,
depending on whether your brand file is hosted publicly or in a private
GitHub repository.

These same `get_brand_*()` functions will also update the local
`_brand.yml` file, if it already exists.

## Use in Shiny Apps

Load the branding YAML and apply the theme in your UI/server code.

## Project Documentation

The full documentation for the package, including reference manuals and
vignettes, is available at <https://epiforesite.github.io/rbranding/>.

## Getting Help

If you encounter a clear bug, please file an issue with a minimal
reproducible example on
[GitHub](https://github.com/EpiForeSITE/rbranding/issues).

## Code of Conduct

Please note that the rbranding project is released with a [Contributor
Code of
Conduct](https://epiforesite.github.io/rbranding/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## Acknowledgements

This project was made possible by cooperative agreement
CDC-RFA-FT-23-0069 from the CDC’s Center for Forecasting and Outbreak
Analytics. Its contents are solely the responsibility of the authors and
do not necessarily represent the official views of the Centers for
Disease Control and Prevention.
