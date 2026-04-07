# ggplot2 and Thematic Integration with Brand Themes

## Overview

This vignette demonstrates how to integrate ggplot2 and plotly
visualizations with brand themes using the `rbranding` package. The
package provides functions to:

1.  Load brand configuration from `_brand.yml` files
2.  Apply brand colors and typography to ggplot2 themes
3.  Add brand logos to plots
4.  Reset themes when needed

## Getting Started

First, let’s load the required packages:

``` r
library(rbranding)
library(ggplot2)

# Suggested packages for enhanced functionality
# library(plotly)  # For interactive plots
# library(sysfonts)  # For custom fonts
# library(showtext)  # For custom fonts
```

## Step 1: Initialize and Load Brand Configuration

Start by initializing the branding configuration and getting the latest
brand file:

``` r
## Use a temporary directory as the knit root for the entire document.
## This avoids calling setwd()/on.exit() in the chunk and ensures
## subsequent chunks are evaluated with `temp_dir` as their working dir.
temp_dir <- tempdir()
knitr::opts_knit$set(root.dir = temp_dir)

# (Optional) store the original working directory for interactive use only
# Note: during knitting, chunks will be evaluated with root.dir set to temp_dir,
# so we explicitly copy/write files into that directory below.
old_wd <- getwd()

# Initialize branding (creates rbranding_config.yml and placeholder _brand.yml)
brand_init()
#> Created files './rbranding_config.yml' and placeholder '_brand.yml' in current working directory

# Get the latest brand file from the repository
get_brand_public()
#> Checking remote version...
#> Local branding file overwritten with remote file

# to install these files directly to your working directory (the knit root):
get_template("ggplot2")
#> Copied example.R to /home/runner/work/rbranding/rbranding/vignettes
#> Copied README.md to /home/runner/work/rbranding/rbranding/vignettes
```

For this vignette, we’ll use the existing `_brand.yml` file in the
package:

``` r
# In a real project, you would have a _brand.yml file in your working directory
# For this demo, we'll use the package's example brand file
brand_file <- system.file("brand_files", "_brand.yml", package = "rbranding")
if (brand_file != "") {
  # copy the example brand file and logos into the knit root (temp_dir)
  file.copy(brand_file, file.path(temp_dir, "_brand.yml"))
  # Copy logo files as well
  logo_files <- list.files(system.file("brand_files", package = "rbranding"), 
                          pattern = "*.png", full.names = TRUE)
  file.copy(logo_files, temp_dir)
  # Use a relative path for later chunks (they run with root.dir=temp_dir)
  brand_file <- "_brand.yml"
} else {
  # Fallback to a basic brand configuration for demonstration
  brand_config <- "
meta:
  name:
    full: Example Organization
    short: EO

color:
  palette:
    primary: '#1c8478'
    secondary: '#4e2d53'
    accent: '#474747'
  foreground: black
  background: white
  primary: primary
  secondary: secondary

typography:
  fonts:
    - family: Open Sans
      source: google
  base: Open Sans
"
  # write a fallback brand file into the knit root
  writeLines(brand_config, file.path(temp_dir, "_brand.yml"))
  brand_file <- "_brand.yml"
}

cat("Using brand file:", brand_file)
#> Using brand file: _brand.yml
```

## Step 2: Set the ggplot2 Theme

Apply the brand theme to ggplot2. This will set colors and fonts
according to your brand configuration:

``` r
# Set the brand theme
brand_set_ggplot(brand_file)
#> Brand theme applied successfully!
#> Custom font loaded: open_sans
```

## Step 3: Create ggplot2 Visualizations

Now create some plots that will automatically use your brand theme:

``` r
# Create a basic scatter plot
p1 <- ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point(aes(color = factor(cyl)), size = 3) +
  labs(
    title = "Car Weight vs. Miles per Gallon",
    subtitle = "Data from the 1974 Motor Trend magazine",
    x = "Miles per Gallon",
    y = "Weight (1000 lbs)",
    color = "Cylinders"
  ) +
  theme(legend.position = "bottom")

print(p1)
```

![Branded scatterplot of car weight vs. miles per
gallon](ggplot2-integration_files/figure-html/basic-plot-1.png)

``` r
# Create a bar plot
p2 <- ggplot(mtcars, aes(x = factor(cyl), fill = factor(gear))) +
  geom_bar(position = "dodge") +
  labs(
    title = "Car Count by Cylinders and Gears",
    x = "Number of Cylinders",
    y = "Count",
    fill = "Gears"
  ) +
  theme(legend.position = "bottom")

print(p2)
```

![Branded bar plot of car count by cylinders and
gears](ggplot2-integration_files/figure-html/bar-plot-1.png)

## Step 4: Add Brand Logo (Optional)

If your brand configuration includes a logo, you can add it to your
plots:

``` r
# Add logo to the plot (requires logo in brand.yml and png package)
p1_with_logo <- p1 + brand_add_logo(x = 0.9, y = 0.1, size = 0.05)
print(p1_with_logo)
```

## Step 5: Interactive Plots with plotly

You can also create interactive versions of your plots using plotly:

``` r
library(plotly)

# Convert ggplot to interactive plotly chart
p1_interactive <- ggplotly(p1, tooltip = c("x", "y", "colour"))
p1_interactive
```

## Step 6: Advanced Theming

You can customize specific aspects of the theme while maintaining brand
consistency:

``` r
# Customize theme elements while keeping brand colors
p3 <- ggplot(mtcars, aes(x = hp, y = mpg, size = wt)) +
  geom_point(alpha = 0.7) +
  scale_size_continuous(range = c(2, 8)) +
  labs(
    title = "Engine Performance Analysis",
    subtitle = "Relationship between horsepower, fuel efficiency, and weight",
    x = "Horsepower",
    y = "Miles per Gallon",
    size = "Weight (1000 lbs)"
  ) +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    plot.subtitle = element_text(size = 12, face = "italic"),
    legend.position = "right"
  )

print(p3)
```

![Branded scatterplot of engine performance
analysis](ggplot2-integration_files/figure-html/advanced-theme-1.png)

## Step 7: Reset Theme

When you’re done with the brand theme, you can reset to the default
ggplot2 theme:

``` r
# Reset to original theme
brand_reset_ggplot()
#> ggplot2 theme reset to previous state.

# Create a plot with default theme to show the difference
p4 <- ggplot(mtcars, aes(x = mpg, y = wt)) +
  geom_point(aes(color = factor(cyl)), size = 3) +
  labs(
    title = "Same Plot with Default Theme",
    x = "Miles per Gallon",
    y = "Weight (1000 lbs)",
    color = "Cylinders"
  )

print(p4)
```

![Scatterplot of engine performance analysis with default ggplot2
theme](ggplot2-integration_files/figure-html/reset-theme-1.png)

## Best Practices

1.  **Set theme early**: Call
    [`brand_set_ggplot()`](https://epiforesite.github.io/rbranding/reference/brand_set_ggplot.md)
    at the beginning of your analysis
2.  **Test font loading**: Custom fonts may not work in all environments
3.  **Use consistent colors**: Stick to the brand palette for
    consistency
4.  **Reset when needed**: Use
    [`brand_reset_ggplot()`](https://epiforesite.github.io/rbranding/reference/brand_reset_ggplot.md)
    to return to default themes
5.  **Logo placement**: Position logos where they don’t interfere with
    data

## Troubleshooting

### Common Issues

- **Font loading fails**: Some environments may not support custom
  Google Fonts
- **Logo not found**: Ensure the logo path in `_brand.yml` is correct
  and the file exists
- **Colors not applied**: Check that your `_brand.yml` file follows the
  correct schema

### Solutions

``` r
# Disable custom fonts if having issues
brand_set_ggplot(use_fonts = FALSE)

# Check brand configuration
doc <- yaml::read_yaml("_brand.yml")
str(doc$color)
str(doc$typography)
```

## Conclusion

The `rbranding` package makes it easy to create consistent, branded
visualizations across your organization. By following this workflow, you
can ensure that all your ggplot2 and plotly charts maintain brand
consistency while being accessible and professional.

For more information about the brand.yml schema, visit:
<https://github.com/posit-dev/brand-yml/>
