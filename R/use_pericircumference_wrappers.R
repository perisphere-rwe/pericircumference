
#' Initialize a Microsoft Word report project
#'
#' A wrapper around [use_pericircumference()] for experienced users who want
#' to quickly set up a project with a Word report and no slides or tutorials.
#' Equivalent to calling
#' `use_pericircumference(doc_format = "office", include_tutorials = FALSE,
#' include_report = TRUE, include_slides = FALSE, ...)`.
#'
#' @param ... additional arguments passed to [use_pericircumference()],
#'   e.g. `report_name = "results"`.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @export
#'
use_pericircumference_report_ms <- function(...) {
  use_pericircumference(
    doc_format        = "office",
    include_tutorials = FALSE,
    include_report    = TRUE,
    include_slides    = FALSE,
    ...
  )
}

#' Initialize a Quarto HTML report project
#'
#' A wrapper around [use_pericircumference()] for experienced users who want
#' to quickly set up a project with a Quarto report and no slides or tutorials.
#' Equivalent to calling
#' `use_pericircumference(doc_format = "quarto", include_tutorials = FALSE,
#' include_report = TRUE, include_slides = FALSE, ...)`.
#'
#' @param ... additional arguments passed to [use_pericircumference()],
#'   e.g. `report_name = "results"`.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @export
#'
use_pericircumference_report_qt <- function(...) {
  use_pericircumference(
    doc_format        = "quarto",
    include_tutorials = FALSE,
    include_report    = TRUE,
    include_slides    = FALSE,
    ...
  )
}

#' Initialize a Microsoft PowerPoint slides project
#'
#' A wrapper around [use_pericircumference()] for experienced users who want
#' to quickly set up a project with PowerPoint slides and no report or
#' tutorials. Equivalent to calling
#' `use_pericircumference(doc_format = "office", include_tutorials = FALSE,
#' include_report = FALSE, include_slides = TRUE, ...)`.
#'
#' @param ... additional arguments passed to [use_pericircumference()],
#'   e.g. `slides_name = "presentation"`.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @export
#'
use_pericircumference_slides_ms <- function(...) {
  use_pericircumference(
    doc_format        = "office",
    include_tutorials = FALSE,
    include_report    = FALSE,
    include_slides    = TRUE,
    ...
  )
}

#' Initialize a Quarto HTML slides project
#'
#' A wrapper around [use_pericircumference()] for experienced users who want
#' to quickly set up a project with Quarto slides and no report or tutorials.
#' Equivalent to calling
#' `use_pericircumference(doc_format = "quarto", include_tutorials = FALSE,
#' include_report = FALSE, include_slides = TRUE, ...)`.
#'
#' @param ... additional arguments passed to [use_pericircumference()],
#'   e.g. `slides_name = "presentation"`.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @export
#'
use_pericircumference_slides_qt <- function(...) {
  use_pericircumference(
    doc_format        = "quarto",
    include_tutorials = FALSE,
    include_report    = FALSE,
    include_slides    = TRUE,
    ...
  )
}
