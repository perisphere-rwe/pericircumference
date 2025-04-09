
#' Initialize pericircumference workflow
#'
#' Creates files and directories according to the Perisphere template.
#' The setup is designed to generate tables and figures in the targets
#' pipeline, then load those objects into a results document. The results
#' document itself goes through iterations designated by versions. This may
#' seem unnecessary when using GitHub to handle version control, but it is
#' often helpful to keep versions of old results documents in a space that
#' is easy to access.
#'
#' @param results_format a character value indicating the format of the
#'   results document. Valid options are
#'
#'   - "word": use `officedown::rdocx_document` results document
#'
#' @param include_tutorials a logical value indicating whether to use file
#'   templates for `_targets.R` and `doc/results.Rmd`. The tutorial versions
#'   contain illustrations of targets and tools inside of the results document
#'   that should be helpful for newer users. The blank versions (i.e., the
#'   ones you get with `include_tutorials = FALSE`) should be more helpful
#'   for users who are familiar with the tools and just want to get files.
#'
#' @return Nothing. Modifies your workspace.
#'
#' @export
#'
use_pericircumference <- function(results_format = "word",
                                  include_tutorials = TRUE){

  # TODO: write html template so i can remove this
  stopifnot(results_format == 'word')

  file_suffix <- ifelse(include_tutorials, 'tutorial', 'blank')

  targets_fname <- glue::glue("_targets-{file_suffix}.R")
  results_fname <- glue::glue("results-{file_suffix}.Rmd")
  results_fpath <- file.path("doc", "results.Rmd")

  usethis::use_directory("R")
  usethis::use_directory("doc")

  usethis::use_template(targets_fname,
                        package = "pericircumference",
                        save_as = "_targets.R")

  usethis::use_template("packages.R",   package = "pericircumference")
  usethis::use_template("conflicts.R",  package = "pericircumference")
  usethis::use_template(".gitignore",   package = "pericircumference")

  usethis::use_template("refs.bib",
                        save_as = "doc/refs.bib",
                        package = "pericircumference")

  usethis::use_template("refs.csl",
                        save_as = "doc/refs.csl",
                        package = "pericircumference")

  usethis::use_template("changelog.md",
                        save_as = "doc/changelog.md",
                        package = "pericircumference")

  if(results_format == 'word'){

    fpath_style <- system.file("templates", "style_arial.docx",
                               package = "pericircumference")

    invisible(
      file.copy(
        fpath_style,
        to = 'doc/style_arial.docx',
        overwrite = TRUE
      )
    )

  }

  if (file.exists(results_fpath)) {

    message(results_fpath, " already exists and was not overwritten.")

    return(invisible(results_fpath))

  }

  usethis::use_template(results_fname,
                        save_as = results_fpath,
                        package = "pericircumference")

}




