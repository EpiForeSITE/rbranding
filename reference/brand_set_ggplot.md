# Set ggplot2 Theme from Brand Configuration

`brand_set_ggplot` sets the ggplot2 theme based on colors and typography
defined in a \_brand.yml file. This function reads the brand
configuration and applies it as the default ggplot2 theme.

## Usage

``` r
brand_set_ggplot(brand_file = NULL, use_fonts = TRUE)
```

## Arguments

- brand_file:

  Path to the \_brand.yml file. If NULL, looks for \_brand.yml in the
  current directory.

- use_fonts:

  Logical. Whether to attempt to load and use custom fonts from the
  brand file. Default is TRUE.

## Value

Invisibly returns the previous ggplot2 theme (for potential
restoration).

## Details

This function reads a brand.yml file and extracts color and = typography
information to create a custom ggplot2 theme. The function:

- Maps brand colors to ggplot2 theme elements

- Attempts to load Google Fonts specified in the brand file

- Stores the previous theme for later restoration

- Sets the new theme as the default for all subsequent ggplot2 plots

The brand.yml file should follow the schema defined at:
https://github.com/posit-dev/brand-yml/

## Examples

``` r
{
# Set theme from default _brand.yml file
old_wd <- getwd()
setwd(tempdir()) # Change to temp directory for example
brand_init()
get_brand_public()
brand_set_ggplot()

# Create a plot - will use the brand theme
library(ggplot2)
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  labs(title = "Example Plot with Brand Theme")

# Reset to original theme
brand_reset_ggplot()

setwd(old_wd) # Restore original working directory
}
#> Created files './rbranding_config.yml' and placeholder '_brand.yml' in current working directory
#> Checking remote version... 
#> Local branding file overwritten with remote file
#> Brand theme applied successfully!
#> Custom font loaded: open_sans
#> ggplot2 theme reset to previous state.
```
