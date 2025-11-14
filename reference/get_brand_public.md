# Download the latest branding file from a public source

`get_brand_public` downloads the latest `_brand.yml` file from the
remote URL specified in `rbranding_config.yml` or provided as function
arguments. The remote file is assumed to be publicly accessible (no
authentication), such as a website or public GitHub repository. If the
local `_brand.yml` file does not exist, it will be created. If the local
file is different from the remote file, the function will save the
contents to `bak_brand.yml` (as backup) and overwrite the local file
with the contents of the remote file. When the function is run
interactively (e.g.,in RStudio console), the user is instead prompted to
choose whether to overwrite the file and whether or not to create the
backup.

## Usage

``` r
get_brand_public(
  remote_file = NULL,
  local_file = NULL,
  config_file = "rbranding_config.yml",
  run_interactive = TRUE,
  backup = FALSE,
  backup_folder = "."
)
```

## Arguments

- remote_file:

  Optional URL. Points to the remote brand file. If `NULL`, the value in
  the configuration file will be used.

- local_file:

  Optional string. Path to the local branding file. If `NULL`, the value
  in the configuration file will be used.

- config_file:

  Path to the configuration file. Default is `rbranding_config.yml`.

- run_interactive:

  Logical indicating whether to run interactively. Defaults to TRUE.

- backup:

  Logical indicating whether to create a backup of the local file if it
  is different from the remote file. Ignored if run interactively.
  Defaults to FALSE.

- backup_folder:

  Folder where the backup file should be saved, if needed. Defaults to
  current working directory.

## Value

NULL. Called for its side effects: updating `_brand.yml` and possibly
creating `bak_brand.yml`

## Examples

``` r
# Interactive example
if (interactive()) {
  tmpdir <- file.path(tempdir(), "brand_files")

  # Initialize config and local brand file
  brand_init(install_path = tmpdir)

  # Update local brand file if needed
  get_brand_public(
    config_file = file.path(tmpdir, "rbranding_config.yml")
  )

  # Cleanup
  unlink(tmpdir, recursive = TRUE)
}

# Non-interactive example
tmpdir <- file.path(tempdir(), "brand_files")
brand_init(install_path = tmpdir)
#> Created files '/tmp/RtmpFIK7o5/brand_files/rbranding_config.yml' and placeholder '_brand.yml' in /tmp/RtmpFIK7o5/brand_files

get_brand_public(
 config_file = file.path(tmpdir, "rbranding_config.yml"),
 run_interactive = FALSE,
 backup = TRUE,
 backup_folder = tmpdir
)
#> Checking remote version... 
#> Backup of local branding file saved to '/tmp/RtmpFIK7o5/brand_files/bak_brand.yml'
#> Local branding file overwritten with remote file

# Cleanup
unlink(tmpdir, recursive = TRUE)
```
