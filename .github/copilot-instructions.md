# R Branding Package Developer Instructions

**ALWAYS follow these instructions first and only fallback to additional search or bash commands if the information here is incomplete or found to be in error.**

## Repository Overview

This is an R package called `rbranding` that facilitates the creation of Shiny apps for CFA projects conforming to STLTs' branding and design standards. The package provides automated branding configuration, theme management, and interactive component linking for ForeSITE Shiny applications.

## Core Package Functions
- `brand_init()` - Initializes branding configuration by creating rbranding_config.yml and _brand.yml files
- `get_brand_public()` - Downloads/updates latest branding files from public source with user prompts
- `get_brand_private_github()` - Downloads/updates latest branding files from private GitHub repositories with authentication
- `get_template()` - Downloads Shiny and Quarto templates for branded applications
- `brand_set_ggplot()` / `brand_reset_ggplot()` - Apply/reset branded ggplot2 themes
- `brand_add_logo()` - Add branded logos to ggplot2 visualizations

**Note:** For interactive map-table linking in Shiny apps, the package uses the external `linkeR` package. See `inst/examples/shiny_wastewater/app.R` for a demonstration.

## Dependencies and Installation

### System Requirements
```bash
# Install R and core development tools
sudo apt-get update
sudo apt-get install -y r-base r-base-dev
sudo apt-get install -y libcurl4-openssl-dev libssl-dev libxml2-dev
sudo apt-get install -y texlive-latex-base texlive-latex-extra texlive-fonts-extra
```

### R Package Dependencies
```bash
# Install core R packages via apt (more reliable than CRAN in restricted environments)
sudo apt-get install -y r-cran-devtools r-cran-yaml r-cran-shiny r-cran-dt r-cran-htmltools
sudo apt-get install -y r-cran-dplyr r-cran-knitr r-cran-rmarkdown r-cran-bslib

# If network access to CRAN is available, install additional packages:
sudo Rscript -e "install.packages(c('leaflet', 'tinytest', 'here', 'pkgdown'), repos='https://cloud.r-project.org/')"
```

**CRITICAL:** If CRAN access fails with network errors, this is normal in restricted environments. The package builds successfully with just the apt-installed dependencies.

## Building and Testing

### Build Commands
```bash
# Build and check the package - NEVER CANCEL, takes 10-15 seconds
_R_CHECK_FORCE_SUGGESTS_=false make check

# Install the package - takes 1 second  
sudo make install

# Generate documentation - takes 1.5 seconds
make docs

# Build pkgdown website (if pkgdown available)
make website
```

**NEVER CANCEL builds or tests.** Package builds complete in 10-15 seconds. Always set appropriate timeouts:
- Build/check commands: Set timeout to 30+ minutes
- Documentation: Set timeout to 10+ minutes
- Installation: Set timeout to 5+ minutes

### Testing
```bash
# Test core package functionality (always works)
echo 'library(rbranding); brand_init()' | R --no-save --quiet

# Run unit tests (requires tinytest and proper paths)
echo 'library(tinytest); run_test_dir("inst/tinytest")' | R --no-save --quiet
```

**Note:** Current tests have path dependency issues. Core package functionality can be validated manually.

## Running Applications

### Available Applications
- **Main App**: `inst/app/app.R` - Main branding demonstration app
- **Wastewater Dashboard**: `inst/examples/shiny_wastewater/app.R` - Interactive map/table linking
- **Quarto Website**: `inst/examples/quarto_website/` - Branded Quarto site example  
- **R Markdown**: `inst/examples/rmarkdown/` - Branded R Markdown examples

### Running Apps with Script
```bash
# Run main app (in inst/app/)
./run_app.sh

# Note: Script looks for inst/app/examples/ but examples are in inst/examples/
# Run examples manually instead:
cd inst/examples/shiny_wastewater && Rscript app.R

# Get script help
./run_app.sh --help
```

### Manual Shiny App Execution
```bash
# For apps requiring full dependencies
cd inst/examples/shiny_wastewater
Rscript -e "shiny::runApp('app.R', host='0.0.0.0', port=3838)"
```

**DEPENDENCY LIMITATION:** Example apps require `leaflet` and `DT` packages which may not be available in all environments. Core package functionality works without these.

## Validation Scenarios

### ALWAYS Test After Making Changes
1. **Build Validation**: 
   ```bash
   _R_CHECK_FORCE_SUGGESTS_=false make check
   ```
   Must complete successfully in 10-15 seconds.

2. **Core Function Test**:
   ```bash
   echo 'library(rbranding); brand_init()' | R --no-save --quiet
   ```
   Should create rbranding_config.yml and _brand.yml files.

3. **Package Help Test**:
   ```bash
   echo 'library(rbranding); help(package="rbranding")' | R --no-save --quiet  
   ```
   Should display package information and function index.

4. **Documentation Test**:
   ```bash
   make docs
   ```
   Should complete without errors in 1.5 seconds.

### Manual Testing Workflow 
**When dependencies are NOT available (common in restricted environments):**
1. Test core package functions:
   ```bash
   echo 'library(rbranding); brand_init()' | R --no-save --quiet
   ```
   Should create rbranding_config.yml and _brand.yml files without errors.

2. Test package loading and help:
   ```bash
   echo 'library(rbranding); help(package="rbranding")' | R --no-save --quiet
   ```

**When dependencies ARE available (full environment):**
1. Navigate to `inst/examples/shiny_wastewater/`
2. Start the Shiny app: `Rscript -e "shiny::runApp('app.R')"`
3. Test interactive features:
   - Click on map markers to verify table row selection
   - Click on table rows to verify map marker highlighting  
   - Verify details panel updates correctly
   - Test with multiple locations

**Note:** Main app in `inst/app/app.R` currently has structural issues. Use example apps for testing.

## Repository Structure

### Key Directories
- `R/` - Package source code (get_repo.R, get_template.R, link_plots.R)
- `inst/examples/` - Example applications demonstrating package usage
- `inst/tinytest/` - Unit tests using tinytest framework
- `man/` - Generated documentation files
- `vignettes/` - Package vignettes and tutorials
- `.github/workflows/` - CI/CD pipelines (R-CMD-check.yaml, pkgdown.yaml)

### Important Files
- `DESCRIPTION` - Package metadata and dependencies
- `Makefile` - Build automation (check, install, docs, example targets)
- `run_app.sh` - Script for running example applications
- `_brand.yml` - Default branding configuration
- `rbranding_config.yml` - Package configuration template

## Common Issues and Solutions

### Build Failures
- **Missing leaflet**: Normal in restricted environments. Use `_R_CHECK_FORCE_SUGGESTS_=false` flag.
- **LaTeX errors**: Install `texlive-fonts-extra` package.
- **Permission errors**: Use `sudo` for system-wide R package installation.

### Network Issues  
- **CRAN access blocked**: Use apt packages instead of CRAN when possible.
- **Download failures in get_brand_*() functions**: Normal behavior, function includes error handling.

### Application Issues
- **Missing leaflet/DT**: Example apps require these packages. Core package functions work without them.
- **Port conflicts**: Default Shiny port is 3838, change if needed.

## CI/CD Information

### GitHub Workflows
- **R-CMD-check.yaml**: Runs on push/PR, tests across multiple R versions and OS
- **pkgdown.yaml**: Builds and deploys package documentation website

### Build Matrix
Tests run on:
- macOS (latest R)
- Windows (latest R)  
- Ubuntu (devel, release, oldrel-1)

## Development Workflow

### Making Changes
1. Always run build validation first: `_R_CHECK_FORCE_SUGGESTS_=false make check`
2. Test core functionality: `echo 'library(rbranding); brand_init()' | R --no-save --quiet`
3. Update documentation if needed: `make docs`
4. Validate changes don't break existing functionality
5. Test example apps if dependencies available

### Before Committing
- Ensure package builds successfully
- Run documentation generation  
- Test core package functions
- Verify no new errors introduced in check process

## Time Expectations
- **Package check**: 10-15 seconds
- **Package install**: 1 second
- **Documentation**: 1.5 seconds  
- **Dependency installation**: 2-5 minutes (when network available)
- **Example app startup**: 5-10 seconds (when dependencies available)

**ALWAYS wait for completion. NEVER CANCEL long-running commands.**