# Reset ggplot2 Theme to Previous State

`brand_reset_ggplot` resets the ggplot2 theme to the state it was in
before brand_set_ggplot() was called.

## Usage

``` r
brand_reset_ggplot()
```

## Value

Invisibly returns TRUE if reset was successful, FALSE if no previous
theme was stored.

## Examples

``` r
{
# Set brand theme
old_wd <- getwd()
setwd(tempdir()) # Change to temp directory for example
brand_init()
get_brand_public()
brand_set_ggplot()

# Create some plots with brand theme...

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
