
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
#' @param include_slides a logical value indicating whether to include template
#'   documents required for presenting results in slide format
#'
#' @return Nothing. Modifies your workspace.
#'
#' @export
#'
use_pericircumference <- function(doc_format = "office",
                                  include_tutorials = TRUE,
                                  include_report = TRUE,
                                  include_slides = TRUE){

  md_type <- switch(doc_format, 'office' = 'Rmd', 'quarto' = 'qmd')
  tutorial_type <- ifelse(include_tutorials, 'tutorial', 'blank')
  report_type <- ifelse(include_report, 'report_included', 'report_excluded')
  slides_type <- ifelse(include_slides, 'slides_included', 'slides_excluded')

  if(here::here() != getwd()){
    stop("`use_perircumference()` requires the current working directory",
         " be the main directory of the current project.\n",
         " - Current working directory: ", getwd(), "\n",
         " - Main directory of current project: ", here::here())
  }

  readr::write_rds(x = '0.0', file = 'version.rds')

  targets_fname <- glue::glue(
    "_targets-{doc_format}-{tutorial_type}-{report_type}-{slides_type}.R"
  )

  report_fname <- glue::glue(
    "report-{doc_format}-{tutorial_type}.{md_type}"
  )

  slides_fname <- glue::glue(
    "slides-{doc_format}-{tutorial_type}.{md_type}"
  )

  usethis::use_directory("R")

  if(include_report) usethis::use_directory("report")

  if(include_slides) usethis::use_directory("slides")

  usethis::use_template(targets_fname,
                        package = "pericircumference",
                        save_as = "_targets.R")

  usethis::use_template("packages.R",   package = "pericircumference")
  usethis::use_template("conflicts.R",  package = "pericircumference")
  usethis::use_template(".gitignore",   package = "pericircumference")

  usethis::use_template("summarize_each_group.R",
                        save_as = "R/summarize_each_group.R",
                        package = "pericircumference")

  usethis::use_template("create_output_directories.R",
                        save_as = "R/create_output_directories.R",
                        package = "pericircumference")

  usethis::use_template("flextable.R",
                        save_as = "R/flextable.R",
                        package = "pericircumference")

  if(include_report){

  usethis::use_template("refs.bib",
                        save_as = "report/refs.bib",
                        package = "pericircumference")

  usethis::use_template("refs.csl",
                        save_as = "report/refs.csl",
                        package = "pericircumference")

  }

  if(include_slides){

    usethis::use_template("refs.bib",
                          save_as = "slides/refs.bib",
                          package = "pericircumference")

    usethis::use_template("refs.csl",
                          save_as = "slides/refs.csl",
                          package = "pericircumference")

  }

  usethis::use_template("changelog.md",
                        save_as = "changelog.md",
                        package = "pericircumference")

  if(doc_format == 'quarto'){

    report <- glue::glue("report.{md_type}")

    slides <- glue::glue("slides.{md_type}")

    if(include_report){

      usethis::use_template("toc-button.html",
                            save_as = "report/toc-button.html",
                            package = "pericircumference")

      usethis::use_template("perisphere-report.css",
                            save_as = "report/perisphere-report.css",
                            package = "pericircumference")
    }

    if(include_slides){

      usethis::use_template("perisphere-slides.css",
                            save_as = "slides/perisphere-slides.css",
                            package = "pericircumference")

      fpath_perisphere_logo <- system.file("templates",
                                           "perisphere-logo.png",
                                           package = "pericircumference")

      invisible(
        file.copy(
          fpath_perisphere_logo,
          to = 'slides/perisphere-logo.png',
          overwrite = TRUE
        )
      )

    }



  }

  if(doc_format == 'office'){

    report <- file.path('report', glue::glue("report.{md_type}"))

    slides <- file.path('slides', glue::glue("slides.{md_type}"))

    fpath_template_report <- system.file("templates",
                                         "perisphere-template.docx",
                                         package = "pericircumference")

    fpath_template_slides <- system.file("templates",
                                         "perisphere-template.pptx",
                                         package = "pericircumference")

    if(include_report){
      invisible(
        file.copy(
          fpath_template_report,
          to = 'report/perisphere_template.docx',
          overwrite = TRUE
        )
      )
    }

    if(include_slides){
      invisible(
        file.copy(
          fpath_template_slides,
          to = 'slides/perisphere_template.pptx',
          overwrite = TRUE
        )
      )
    }

  }

  if(include_report){

    usethis::use_template(report_fname,
                          save_as = report,
                          package = "pericircumference")

  }

  if(include_slides){

    usethis::use_template(slides_fname,
                          save_as = slides,
                          package = 'pericircumference')

  }

}




