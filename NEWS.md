# rbranding (development version)

* README and vignettes are now built with Quarto (`README.qmd`, `vignettes/*.qmd`, `VignetteBuilder: quarto`). Building the vignettes requires the Quarto CLI.
* Added CRAN, download, and R-universe badges to the README.
* New `foresite_themes/` folder with the official ForeSITE `_brand.yml`, logos, and themes for pkgdown sites and Quarto reports (HTML and PDF). The package website now uses the ForeSITE pkgdown theme.
* The ForeSITE brand is bundled in `inst/brand_files/` and used by the ggplot2 vignette, which no longer needs network access and has larger, clearer figures.
* `brand_add_logo()` now keeps the logo's aspect ratio; `size` sets its height.
* `get_template()` now copies template subdirectories (e.g., `shiny_complex/www/`).
* The `shiny_complex` template no longer errors with hex brand colors in `valueBox()` (newer shinydashboard versions reject them).
* Refreshed the screenshots in the Templates vignette to match the current templates.

# rbranding 0.1.0

* Functions for initializing and updating `_brand.yml` file
* Examples and templates for a variety of projects
* Initial CRAN release
