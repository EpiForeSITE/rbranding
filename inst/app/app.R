# Returns a filepath to a temporary yaml file
brand_dhhs <- function() {load_brand("brand/_brand2.yml", color.main = "blue")}

#' @export
run_model <- function() {
  shinyAppDir(
    system.file("app/", package = "simpleshiny")
  )
}
