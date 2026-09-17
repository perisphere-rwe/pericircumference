
#' Add flextable helper functions to R/
#'
#' Copies `flextable.R` into the `R/` directory of the current project.
#' Contains `flextable_polish()`, `flextable_polish_ppt()`, and
#' `flextable_autofit()` — helper functions for building and styling
#' `flextable` objects for Word/PowerPoint/Quarto output. Prints
#' `add_package()` calls for the packages these helpers depend on.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @importFrom usethis use_directory
#'
#' @export
#'
use_helpers_flextable <- function() {
  .peri_assert_project_root()
  use_directory("R")
  .peri_check_template_pkgs(
    c("flextable", "magrittr", "cli")
  )
  .peri_add_r_helpers_flex()
}

#' Add data.table helper functions to R/
#'
#' Copies `shift.R` into the `R/` directory of the current project. Contains
#' `shift_forward()` and `shift_backward()`, wrappers around
#' `data.table::shift()` that make the shift direction explicit. Prints
#' `add_package()` calls for the packages these helpers depend on.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @importFrom usethis use_directory
#'
#' @export
#'
use_helpers_datatable <- function() {
  .peri_assert_project_root()
  use_directory("R")
  .peri_check_template_pkgs(
    c("data.table")
  )
  .peri_add_r_helpers_datatable()
}

#' Add tidyverse helper functions to R/
#'
#' Copies `summarize_each_group.R` into the `R/` directory of the current
#' project. Contains `summarize_each_group()`, an extension of
#' `dplyr::summarize()` that computes a summary for each group as well as
#' an overall summary, stacking the results into a single data frame. Prints
#' `add_package()` calls for the packages these helpers depend on.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @importFrom usethis use_directory
#'
#' @export
#'
use_helpers_tidyverse <- function() {
  .peri_assert_project_root()
  use_directory("R")
  .peri_check_template_pkgs(
    c("dplyr", "purrr", "checkmate")
  )
  .peri_add_r_helpers_tidyverse()
}

#' Add Market Clarity database connection helpers to R/
#'
#' Copies `market_clarity.R` into the `R/` directory of the current project.
#' Contains `connect_to_db()`, which connects either to a local DuckDB
#' "mini" database built from a shared folder of parquet snapshots
#' (`use_mini_db = TRUE`, the default) or to the full Market Clarity
#' Databricks cluster via `sparklyr::spark_connect()` (`use_mini_db =
#' FALSE`).
#'
#' @details
#' `connect_to_db()` depends on the `DBI`, `duckdb`, `sparklyr`, `stringr`,
#' `purrr`, and `glue` packages being installed and loaded. After the file
#' is added, this function prints the corresponding [add_package()] calls
#' for whichever of these your project needs to add to `packages.R`.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @importFrom usethis use_directory
#'
#' @export
#'
use_helpers_market_clarity <- function() {
  .peri_assert_project_root()
  use_directory("R")
  .peri_check_template_pkgs(
    c("DBI", "duckdb", "sparklyr", "stringr", "purrr", "glue")
  )
  .peri_add_r_helpers_market_clarity()
}
