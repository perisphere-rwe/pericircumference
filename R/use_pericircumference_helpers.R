
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
