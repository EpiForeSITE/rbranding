# Download the latest branding file from a private GitHub repository

`get_brand_private_github` downloads the latest `_brand.yml` file from
the remote URL specified in `rbranding_config.yml` or provided as
function arguments. The remote file is assumed to be in a private GitHub
repository and requires authentication. If the local `_brand.yml` file
does not exist, it will be created. If the local file is different from
the remote file, the function will save the contents to `bak_brand.yml`
(as backup) and overwrite the local file with the contents of the remote
file. When the function is run interactively (e.g., in RStudio console),
the user is instead prompted to choose whether to overwrite the file and
whether or not to create the backup.

## Usage

``` r
get_brand_private_github(
  remote_file = NULL,
  local_file = NULL,
  auth_token = NULL,
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

- auth_token:

  Optional authentication token for accessing the private GitHub
  repository. If `NULL`, the function will attempt to retrieve the token
  from the `GITHUB_TOKEN` environment variable or the git credential
  store.

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
  get_brand_private_github(
    config_file = file.path(tmpdir, "rbranding_config.yml")
  )

  # Cleanup
  unlink(tmpdir, recursive = TRUE)
}

if (FALSE) { # \dontrun{
  # Example not run because it requires a GitHub
  # personal access token with repo access

  tmpdir <- file.path(tempdir(), "brand_files")
  brand_init(install_path = tmpdir)

  get_brand_private_github(
   config_file = file.path(tmpdir, "rbranding_config.yml"),
   auth_token = "your_github_token_here",
   run_interactive = FALSE,
   backup = TRUE,
   backup_folder = tmpdir
  )

  # Cleanup
  unlink(tmpdir, recursive = TRUE)
} # }
```
