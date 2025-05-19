
#' Retrieve all repos for an organization or user
#'
#' Given a username or organization, retrieve all the repos
#'
#' @param owner the name of the organization or user to retrieve a list of repos from. E.g. fhdsl
#'
#' @param git_pat A personal access token from GitHub. Only necessary if the
#' repository being checked is a private repository.
#' @param verbose TRUE/FALSE do you want more progress messages?
#'
#' @return A data frame that contains information about the issues from the given repository
#' @importFrom gh gh
#' @importFrom dplyr bind_rows
#' @importFrom jsonlite
#'
#' @export
#'
#' @examples  \dontrun{
#'
#' # First, set up your GitHub credentials using `usethis::gitcreds_set()`.
#' # Get a GitHub personal access token (PAT)
#' usethis::create_github_token()
#'
#' # Give this token to `gitcreds_set()`
#' gitcreds::gitcreds_set()
#'
#' # Now you can retrieve the repositories
#' repos_df <- get_repos("fhdsl")
#'
#' # Alternatively, you can supply the GitHub PAT directly
#' # to the function to avoid doing the steps above.
#' repos_df <- get_repos("fhdsl", git_pat = "gh_somepersonalaccesstokenhere")
#' }
get_repo <- function(owner,
                      repo = NULL,
                      path = NULL,
                      verbose = TRUE) {

  # Try to get credentials




    # Get the issues through API query with gh package
      my_repo <- gh::gh("GET /repos/EpiForeSITE/branding-package/contents/")


    # Make it into a dataframe
    repo_df <- suppressWarnings(as.data.frame(t(do.call(cbind, my_repo))))
    # Add the owner and repo name



    return(repo_df)
}


repo_df = get_repo("EpiForeSITE", "branding-package")
brand = repo_df[repo_df$name == '_brand.yml',]
sha = as.character(brand$sha)
sha
local <- system2(command="git", args=c( "hash-object", "_brand.yml"), stdout = TRUE)
local
print(paste("local hash equals remote hash: ", (sha == toString(local))))

