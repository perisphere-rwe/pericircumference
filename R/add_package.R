#' Add a package to packages.R
#'
#' @param name the name of the package to add.
#' @param purpose a character string describing why the package is needed.
#'   Stored as a comment above the `library()` call. Optional but encouraged.
#' @param path path to the packages file. Defaults to `"packages.R"` in the
#'   current working directory.
#'
#' @details
#' A purpose isn't necessary, but it can sometimes be helpful for you
#' or for someone who reads your code. For example, `library(here)` is
#' informative enough - it tells you that the project requires the `here`
#' package. However, if there is a comment explaining that the project
#' uses the `here` package to manage targets in R-markdown documents,
#' that's a lot more informative.
#'
#' @return Nothing, invisibly.
#'
#' @importFrom cli symbol
#' @importFrom glue glue
#' @importFrom readr read_lines write_lines
#'
#' @export
#'
add_package <- function(name, purpose = NULL, path = "packages.R"){

  if (!file.exists(path)) {
    stop(
      "Could not find ", path, ".\n",
      "- Run pericircumference::use_pericircumference() to initialize the project.\n",
      "- Then run add_package(\"foo\") to add an R package named foo.",
      call. = FALSE
    )
  }

  packages <- read_lines(path)

  new_pkg <- glue("library({name})")

  if (new_pkg %in% packages) {
    message(symbol$tick, glue(" '{new_pkg}' is already in '{path}'"))
    return(invisible(NULL))
  }

  if (!is.null(purpose)) {
    if (!is.character(purpose) || length(purpose) != 1) {
      stop("purpose should be a character value of length 1", call. = FALSE)
    }
    if (!grepl(pattern = "^\\#", x = purpose))
      purpose <- paste("#", purpose)
  }

  packages <- c(packages, purpose, new_pkg)

  readr::write_lines(packages, path)

  message(symbol$tick, glue(" Writing '{new_pkg}' to '{path}'"))

  invisible(NULL)

}
