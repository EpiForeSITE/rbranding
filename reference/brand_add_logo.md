# Add Brand Logo to ggplot2 Plot

`brand_add_logo` adds a logo from the brand configuration as an
annotation to a ggplot2 plot.

## Usage

``` r
brand_add_logo(x = 0.9, y = 0.1, size = 0.05, logo_type = "icon")
```

## Arguments

- x:

  Numeric. Horizontal position of the logo (0-1 scale). Default is 0.9.

- y:

  Numeric. Vertical position of the logo (0-1 scale). Default is 0.1.

- size:

  Numeric. Size of the logo as a fraction of the plot (0-1 scale).
  Default is 0.05.

- logo_type:

  Character. Which logo to use: "icon" (default) or "full".

## Value

A ggplot2 annotation_custom layer that can be added to a plot with `+`.

## Details

This function reads the logo path from the stored brand configuration
and creates a ggplot2 annotation layer. The brand configuration must be
loaded first using brand_set_ggplot().

The function supports PNG images and requires the 'png' and 'grid'
packages.

## Examples

``` r
{
# First set the brand theme to load configuration
old_wd <- getwd()
setwd(tempdir()) # Change to temp directory for example
brand_init()
get_brand_public()
get_template("blank")
brand_set_ggplot()

# Create a plot and add logo
library(ggplot2)
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  labs(title = "Example Plot") +
  brand_add_logo()

# Customize logo position and size
ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point() +
  labs(title = "Example Plot") +
  brand_add_logo(x = 0.1, y = 0.9, size = 0.08)

setwd(old_wd) # Restore original working directory
}
#> Created files './rbranding_config.yml' and placeholder '_brand.yml' in current working directory
#> Checking remote version... 
#> Local branding file overwritten with remote file
#> Copied blank.txt to /tmp/Rtmp98QbCX
#> Copied icon.png to /tmp/Rtmp98QbCX
#> Copied logo.png to /tmp/Rtmp98QbCX
#> Brand theme applied successfully!
#> Custom font loaded: open_sans

```
