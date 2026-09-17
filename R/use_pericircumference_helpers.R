
# .peri_assert_project_root -----------------------------------------------------

.peri_assert_project_root <- function() {
  project_root <- normalizePath(here::here(), winslash = "/")
  working_dir  <- normalizePath(getwd(),      winslash = "/")

  if (project_root != working_dir) {
    stop("this function requires the current working directory",
         " be the main directory of the current project.\n",
         " - Current working directory: ", working_dir, "\n",
         " - Main directory of current project: ", project_root)
  }
}

# .peri_add_core_files ---------------------------------------------------------

.peri_add_core_files <- function(tmpl_data) {
  readr::write_rds(x = '0.0', file = 'version.rds')
  usethis::use_template("packages.R",   package = "pericircumference")
  usethis::use_template("conflicts.R",  package = "pericircumference")
  usethis::use_template(".gitignore",   package = "pericircumference")
  usethis::use_template("changelog.md", save_as = "changelog.md",
                        package = "pericircumference")
  usethis::use_template("create_output_directories.R",
                        save_as = "R/create_output_directories.R",
                        package = "pericircumference",
                        data = tmpl_data)
}

# .peri_add_r_helpers_tidyverse -------------------------------------------------

.peri_add_r_helpers_tidyverse <- function() {
  usethis::use_template("summarize_each_group.R",
                        save_as = "R/summarize_each_group.R",
                        package = "pericircumference")
}

# .peri_add_r_helpers_datatable --------------------------------------------------

.peri_add_r_helpers_datatable <- function() {
  usethis::use_template("shift.R",
                        save_as = "R/shift.R",
                        package = "pericircumference")
}

# .peri_add_r_helpers_flex -----------------------------------------------------

.peri_add_r_helpers_flex <- function() {
  usethis::use_template("flextable.R",
                        save_as = "R/flextable.R",
                        package = "pericircumference")
}

# .peri_add_r_helpers_market_clarity ---------------------------------------------

.peri_add_r_helpers_market_clarity <- function() {
  usethis::use_template("market_clarity.R",
                        save_as = "R/market_clarity.R",
                        package = "pericircumference")
}

# .peri_suggest_packages --------------------------------------------------------

.peri_suggest_packages <- function(pkgs, purposes = NULL) {

  if (is.null(purposes)) purposes <- rep(NA_character_, length(pkgs))

  calls <- ifelse(
    is.na(purposes),
    glue::glue('add_package("{pkgs}")'),
    glue::glue('add_package("{pkgs}", "{purposes}")')
  )

  cli::cli_h3("Suggested packages")
  cli::cli_alert_info("Add these to {.file packages.R} with {.fn add_package}:")
  cli::cli_code(calls)

}

# .peri_add_pipeline -----------------------------------------------------------

.peri_add_pipeline <- function(doc_format, tutorial_type, tmpl_data) {
  targets_fname <- glue::glue("_targets-{doc_format}-{tutorial_type}.R")
  usethis::use_template(targets_fname,
                        save_as = "_targets.R",
                        package = "pericircumference",
                        data = tmpl_data)
}

# .peri_add_report -------------------------------------------------------------

.peri_add_report <- function(doc_format, tutorial_type, report_name, md_type,
                             tmpl_data) {
  report_fname <- glue::glue("report-{doc_format}-{tutorial_type}.{md_type}")

  usethis::use_template("refs.bib",
                        save_as = file.path(report_name, "refs.bib"),
                        package = "pericircumference")
  usethis::use_template("refs.csl",
                        save_as = file.path(report_name, "refs.csl"),
                        package = "pericircumference")

  if (doc_format == "office") {
    .peri_use_binary("perisphere-template.docx",
                     file.path(report_name, "perisphere_template.docx"))
    usethis::use_template(report_fname,
                          save_as = file.path(report_name,
                                              glue::glue("{report_name}.{md_type}")),
                          package = "pericircumference",
                          data = tmpl_data)
  }

  if (doc_format == "quarto") {
    usethis::use_template("toc-button.html",
                          save_as = file.path(report_name, "toc-button.html"),
                          package = "pericircumference")
    usethis::use_template("perisphere-report.css",
                          save_as = file.path(report_name, "perisphere-report.css"),
                          package = "pericircumference")
    usethis::use_template(report_fname,
                          save_as = glue::glue("{report_name}.{md_type}"),
                          package = "pericircumference",
                          data = tmpl_data)
  }
}

# .peri_add_slides -------------------------------------------------------------

.peri_add_slides <- function(doc_format, tutorial_type, slides_name, md_type,
                             tmpl_data) {
  slides_fname <- glue::glue("slides-{doc_format}-{tutorial_type}.{md_type}")

  usethis::use_template("refs.bib",
                        save_as = file.path(slides_name, "refs.bib"),
                        package = "pericircumference")
  usethis::use_template("refs.csl",
                        save_as = file.path(slides_name, "refs.csl"),
                        package = "pericircumference")

  if (doc_format == "office") {
    .peri_use_binary("perisphere-template.pptx",
                     file.path(slides_name, "perisphere_template.pptx"))
    usethis::use_template(slides_fname,
                          save_as = file.path(slides_name,
                                              glue::glue("{slides_name}.{md_type}")),
                          package = "pericircumference",
                          data = tmpl_data)
  }

  if (doc_format == "quarto") {
    usethis::use_template("perisphere-slides.css",
                          save_as = file.path(slides_name, "perisphere-slides.css"),
                          package = "pericircumference")
    .peri_use_binary("perisphere-logo.png",
                     file.path(slides_name, "perisphere-logo.png"))
    usethis::use_template(slides_fname,
                          save_as = glue::glue("{slides_name}.{md_type}"),
                          package = "pericircumference",
                          data = tmpl_data)
  }
}

# .peri_use_binary -------------------------------------------------------------

.peri_use_binary <- function(template_name, save_as) {
  src <- system.file("templates", template_name, package = "pericircumference")
  invisible(file.copy(src, to = save_as, overwrite = TRUE))
  cli::cli_alert_success("Writing {.file {save_as}}")
}

# .peri_check_installed_packages -----------------------------------------------

#' @import cli

.peri_check_installed_packages <- function(pkgs) {

  pkgs <- sort(unique(pkgs))

  pkg_installed <- vapply(pkgs,
                          function(pkg) system.file(package = pkg) != "",
                          logical(1L))

  not_installed <- names(pkg_installed)[!pkg_installed]

  if (length(not_installed)) {

    cli::cli_alert_warning(
      paste0(
        "The following package{qty(not_installed)}{?s} {?is/are} required, ",
        "but not installed: {.pkg {not_installed}}."
      )
    )

    perisphere_pkgs <- not_installed[grepl("^peri.*", not_installed)]
    cran_pkgs <- setdiff(not_installed, perisphere_pkgs)

    install_peri <- sprintf(
      "remotes::install_github(paste0(\"perisphere-rwe/\", c(%s)))",
      paste(dQuote(perisphere_pkgs, FALSE), collapse = ", ")
    )

    install_cran <- sprintf(
      "install.packages(c(%s))",
      paste(dQuote(cran_pkgs, FALSE), collapse = ", ")
    )

    if (length(cran_pkgs) && length(perisphere_pkgs)) {
      msg_end <- "{.run {install_cran}} and {.run {install_peri}}."
    } else {
      msg_end <- ifelse(
        length(cran_pkgs),
        "{.run {install_cran}}.",
        "{.run {install_peri}}."
      )
    }

    cli::cli_alert_warning(
      paste0(
        "Install the package{qty(not_installed)}{?s} with ",
        msg_end
      )
    )

  }

}

# .peri_check_template_pkgs ----------------------------------------------------

.peri_check_template_pkgs <- function(pkgs) {

  pkgs <- unique(pkgs)

  template_pkgs <- c(
    "checkmate" = "input validation",
    "cli" = "command line interface helpers",
    "data.table" = "fast data ops",
    "DBI" = "dbConnect()/dbExecute() calls",
    "dplyr" = "tidyverse data management",
    "duckdb" = "local mini database connections",
    "flextable" = "tables for office docs",
    "glue" = "intuitive string concatenation",
    "magrittr" = "pipes!",
    "purrr" = "tidyverse iteration",
    "sparklyr" = "full Databricks cluster connections",
    "stringr" = "tidy string management",
    "_NOMATCH_" = NA_character_
  )

  nomatch_idx <- which(names(template_pkgs) == "_NOMATCH_")

  idx <- match(pkgs, names(template_pkgs), nomatch = nomatch_idx)

  pkg_purposes <- unname(template_pkgs[idx])

  .peri_check_installed_packages(pkgs)

  .peri_suggest_packages(pkgs, pkg_purposes)
}
