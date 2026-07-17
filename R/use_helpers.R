
#' Add flextable helper functions to R/
#'
#' Copies `flextable.R` into the `R/` directory of the current project.
#' Contains `flextable_polish()`, `flextable_polish_ppt()`, and
#' `flextable_autofit()` — helper functions for building and styling
#' `flextable` objects for Word/PowerPoint/Quarto output.
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
  .peri_add_r_helpers_flex()
}

#' Add data.table helper functions to R/
#'
#' Copies `shift.R` into the `R/` directory of the current project. Contains
#' `shift_forward()` and `shift_backward()`, wrappers around
#' `data.table::shift()` that make the shift direction explicit.
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
  .peri_add_r_helpers_datatable()
}

#' Add tidyverse helper functions to R/
#'
#' Copies `summarize_each_group.R` into the `R/` directory of the current
#' project. Contains `summarize_each_group()`, an extension of
#' `dplyr::summarize()` that computes a summary for each group as well as
#' an overall summary, stacking the results into a single data frame.
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
#' `connect_to_db()` depends on the `DBI`, `duckdb`, and `sparklyr` packages
#' being installed and loaded. Use [add_package()] to add whichever of
#' these your project needs to `packages.R`.
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
  .peri_add_r_helpers_market_clarity()
}
