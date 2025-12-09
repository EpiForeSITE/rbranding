# Initialize branding configuration

`brand_init` initializes the branding configuration by creating two
files:

- `rbranding_config.yml`: contains remote and local file paths to brand
  files

- `_brand.yml`: a placeholder branding file It is intended to be run
  once. Use a `get_brand_*()` function to download/update the brand
  file.

## Usage

``` r
brand_init(brand_url = NULL, install_path = ".")
```

## Arguments

- brand_url:

  Optional URL. Points to the remote brand file. If `NULL`, defaults to
  rbranding's brand file on GitHub.

- install_path:

  Optional string. Directory where the files should be created. Defaults
  to the current working directory.

## Value

NULL. Called for its side effects: downloading and creating
`rbranding_config.yml` and `_brand.yml` files.

## Examples

``` r
tmpdir <- file.path(tempdir(), "brand_files")

brand_init(install_path = tmpdir)
#> Created files '/tmp/RtmphRWcoH/brand_files/rbranding_config.yml' and placeholder '_brand.yml' in /tmp/RtmphRWcoH/brand_files

# Clean up
unlink(tmpdir, recursive = TRUE)
```
