#' Add a package to packages.R
#'
#' @param name the name of the package
#' @param purpose what's the purpose of the package being added?
#'
#' @details
#' A purpose isn't necessary, but it can sometimes be helpful for you
#' or for someone who reads your code. For example, `library(here)` is
#' informative enough - it tells you that the project requires the `here`
#' package. However, if there is a comment explaining that the project
#' uses the `here` package to manage targets in R-markdown documents,
#' that's a lot more informative.
#'
#'
#' @return Nothing. Attempts to modify the packages.R file and prints a
#'   summary message if the modification is successful.
#'
#' @export
#'
add_package <- function(name, purpose = NULL){

  if(!file.exists("./packages.R")){
    stop("Create packages.R file before using `add_pkg()`.\n",
         "- run pericircle::use_targets() to initialize project\n",
         "- run add_pkg(\"foo\") to add an R package named foo",
         call. = FALSE)
  }

  packages <- readr::read_lines("./packages.R")

  new_pkg <- glue::glue("library({name})")

  if(new_pkg %in% packages){ return(NULL) }

  if(!is.null(purpose)){

    if(!is.character(purpose)){
      stop("purpose should be a character value of length 1")
    }

    if(!length(purpose) == 1){
      stop("purpose should be a character value of length 1",
           call. = FALSE)
    }

    if(!grepl(pattern = "^\\#", x = purpose))
      purpose <- paste("#", purpose)

  }

  packages <- c(packages, purpose, new_pkg)

  readr::write_lines(packages, "./packages.R")

  message(cli::symbol$tick,
          glue::glue(" Writing '{new_pkg}' to './packages.R'"))

}
