help:
	@echo "Makefile for building and running the project"
	@echo "Available targets:"
	@echo "  docs - Generate documentation"
	@echo "  help - Show this help message"
	@echo "  install - Install the package"
	@echo "  example - Run the example application"

docs:
	@echo "Generating documentation..."
	Rscript -e 'devtools::document()'

install:
	@echo "Installing package..."
	R CMD INSTALL .

example:
	@echo "Running example..."
	Rscript -e 'shiny::runApp(system.file("examples", "link_plots.R", package = "rbranding"))'

.PHONY: help docs install example