# Changelog

## rbranding (development version)

- README and vignettes are now built with Quarto (`README.qmd`,
  `vignettes/*.qmd`, `VignetteBuilder: quarto`). Building the vignettes
  requires the Quarto CLI.
- Added CRAN, download, and R-universe badges to the README.
- New `foresite_themes/` folder with the official ForeSITE `_brand.yml`,
  logos, and themes for pkgdown sites and Quarto reports (HTML and PDF).
  The package website now uses the ForeSITE pkgdown theme.
- The ForeSITE brand is bundled in `inst/brand_files/` and used by the
  ggplot2 vignette, which no longer needs network access and has larger,
  clearer figures.
- [`brand_add_logo()`](https://epiforesite.github.io/rbranding/reference/brand_add_logo.md)
  now keeps the logo’s aspect ratio; `size` sets its height.
- [`get_template()`](https://epiforesite.github.io/rbranding/reference/get_template.md)
  now copies template subdirectories (e.g., `shiny_complex/www/`).
- The `shiny_complex` template no longer errors with hex brand colors in
  `valueBox()` (newer shinydashboard versions reject them).
- The `shiny_kmeans` template now applies the `_brand.yml` theme to its
  UI (it was created but never used) and no longer uses the deprecated
  [`ggplot2::aes_string()`](https://ggplot2.tidyverse.org/reference/aes_.html).
- New tests cover template installation (including subdirectories), the
  Shiny templates’ brand theming, and
  [`brand_add_logo()`](https://epiforesite.github.io/rbranding/reference/brand_add_logo.md)
  (whose test previously never ran because the logo file was not
  created).
- Refreshed the screenshots in the Templates vignette to match the
  current templates.

## rbranding 0.1.0

CRAN release: 2025-11-21

- Functions for initializing and updating `_brand.yml` file
- Examples and templates for a variety of projects
- Initial CRAN release
