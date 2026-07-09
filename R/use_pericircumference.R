
#' Initialize pericircumference workflow
#'
#' Creates files and directories according to the Perisphere template. The setup
#' is designed to generate tables and figures in the targets pipeline, then load
#' those objects into a results document. The results document itself goes
#' through iterations designated by versions. This may seem unnecessary when
#' using GitHub to handle version control, but it is often helpful to keep
#' versions of old results documents in a space that is easy to access.
#'
#' @param doc_format a character value indicating the format of project output
#'   documents. Valid options are
#'
#'   - "office": uses `officedown` to provide .docx and .pptx outputs.
#'   - "quarto": uses `quarto` to provide .html outputs
#'
#' @param include_tutorials a logical value indicating whether to use file
#'   templates for `_targets.R` and related files. The tutorial versions contain
#'   illustrations of targets and tools inside of the results document that
#'   should be helpful for newer users. The blank versions (i.e., the ones you
#'   get with `include_tutorials = FALSE`) should be more helpful for users who
#'   are familiar with the tools and just want to get files.
#'
#' @param include_report a logical value indicating whether to include template
#'   documents required for presenting results in a report.
#'
#' @param include_slides a logical value indicating whether to include template
#'   documents required for presenting results in slides.
#'
#' @param report_name a character value giving the name used for the report
#'   directory and document file. Defaults to `"report"`, which produces a
#'   `report/` directory containing `report.Rmd` (or `report.qmd`). Set to
#'   e.g. `"results"` to get `results/results.Rmd` instead.
#'
#' @param slides_name a character value giving the name used for the slides
#'   directory and document file. Defaults to `"slides"`, which produces a
#'   `slides/` directory containing `slides.Rmd` (or `slides.qmd`). Set to
#'   e.g. `"presentation"` to get `presentation/presentation.Rmd` instead.
#'
#' @param report_title a character value used as the `title:` field in the
#'   report document's YAML front matter. Defaults to `"Report"`.
#'
#' @param slides_title a character value used as the `title:` field in the
#'   slides document's YAML front matter. Defaults to `"Presentation"`.
#'
#' @param author a character value used as the `author:` field in all
#'   generated documents' YAML front matter. Defaults to `""` (empty).
#'
#' @param include_helpers_flextable a logical value indicating whether to copy
#'   `flextable.R` into `R/`. Contains helper functions for building flextable
#'   objects. Defaults to `TRUE`.
#'
#' @param include_helpers_misc a logical value indicating whether to copy
#'   `summarize_each_group.R` and `shift.R` into `R/`. Defaults to `FALSE`.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @importFrom glue glue
#' @importFrom here here
#' @importFrom readr write_rds
#' @importFrom usethis use_directory use_template
#'
#' @export
#'
use_pericircumference <- function(doc_format               = "office",
                                  include_tutorials         = TRUE,
                                  include_report            = TRUE,
                                  include_slides            = TRUE,
                                  report_name               = "report",
                                  slides_name               = "slides",
                                  report_title              = "Report",
                                  slides_title              = "Presentation",
                                  author                    = "",
                                  include_helpers_flextable = TRUE,
                                  include_helpers_misc      = FALSE) {

  if (here() != getwd()) {
    stop("`use_pericircumference()` requires the current working directory",
         " be the main directory of the current project.\n",
         " - Current working directory: ", getwd(), "\n",
         " - Main directory of current project: ", here())
  }

  md_type       <- switch(doc_format, 'office' = 'Rmd', 'quarto' = 'qmd')
  tutorial_type <- ifelse(include_tutorials, 'tutorial', 'blank')

  tmpl_data <- list(
    report_name        = report_name,
    report_dir         = report_name,
    report_title       = report_title,
    slides_name        = slides_name,
    slides_dir         = slides_name,
    slides_title       = slides_title,
    author             = author,
    include_report     = include_report,
    include_slides     = include_slides,
    include_any_output = include_report || include_slides
  )

  use_directory("R")
  if (include_report) use_directory(report_name)
  if (include_slides) use_directory(slides_name)

  .peri_add_core_files(tmpl_data)
  if (include_helpers_flextable) .peri_add_r_helpers_flex()
  if (include_helpers_misc)      .peri_add_r_helpers_misc()
  .peri_add_pipeline(doc_format, tutorial_type, tmpl_data)

  if (include_report) .peri_add_report(doc_format, tutorial_type, report_name, md_type, tmpl_data)
  if (include_slides) .peri_add_slides(doc_format, tutorial_type, slides_name, md_type, tmpl_data)

}
