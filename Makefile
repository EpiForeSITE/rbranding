help:
	@echo "Makefile for building and running the project"
	@echo "Available targets:"
	@echo "  docs - Generate documentation"
	@echo "  readme - Render README.md from README.qmd"
	@echo "  website - Build the pkgdown website"
	@echo "  sync-brand - Copy foresite_themes brand files into inst/brand_files"
	@echo "  help - Show this help message"
	@echo "  install - Install the package"
	@echo "  example - Run the example application"
	@echo "  check - Build and check the package"

docs:
	@echo "Generating documentation..."
	Rscript -e 'devtools::document()'

readme:
	@echo "Rendering README..."
	quarto render README.qmd

sync-brand:
	@echo "Syncing ForeSITE brand into inst/brand_files..."
	mkdir -p inst/brand_files/assets/logos
	cp foresite_themes/_brand.yml inst/brand_files/_brand.yml
	cp foresite_themes/assets/logos/*.png inst/brand_files/assets/logos/

website:
	@echo "Building website..."
	Rscript -e 'pkgdown::build_site()'

install:
	@echo "Installing package..."
	R CMD INSTALL .

example:
	@echo "Running example..."
	Rscript -e 'shiny::runApp(system.file("templates", "link_plots.R", package = "rbranding"))'

check:
	R CMD build . && \
	R CMD check --as-cran rbranding_*.tar.gz

.PHONY: help docs readme sync-brand website install example check
