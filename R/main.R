library(usethis)

#' Create basic Shiny App Templates
#'
#'#' @description
#' `rbranding_create` creates a starter project
#'
#'
#' @export
rbranding_create <- function() {
  wd = getwd()

  dir.create(file.path(wd, "inst"))
  dir.create(file.path(wd, "inst/app"))
  dir.create (file.path(wd, "inst/app/www"))


}
