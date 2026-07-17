#' Assert validity of the current project version
#'
#' This function helps prevent you from accidentally over-writing documents
#'   that you wanted to remain un-modified when you run `tar_make()`. For
#'   example, let's say you sent version 1.1 of the results to your colleague
#'   and then you forgot to change version_minor_current to 2. If you make
#'   changes to your code and re-run the pipeline, you'll end up over-writing
#'   version 1.1 of the results. This is annoying and can sometimes create
#'   issues with reproducibility, so `assert_valid_version()` is included
#'   at the top of the targets pipeline to make sure this mistake is not
#'   allowed.
#'
#' @inheritParams finalize_version
#' @param path a string indicating where `version.rds` is stored. This
#'   should *always* be stored in the project's main directory.
#'
#' @returns a string representing the current version
#'
#' @importFrom readr read_rds
#'
#' @export
#'
assert_valid_version <- function(major, minor, path = 'version.rds'){

  if(!file.exists(path)){
    stop("version.rds file not found. This should not happen.",
         " email me at bcjaeger@perisphere-rwe.com for help.",
         call. = FALSE)
  }

  previous_version <- read_rds(path)

  prev_parts  <- strsplit(previous_version, ".", fixed = TRUE)[[1]]
  prev_major  <- as.integer(prev_parts[1])
  prev_minor  <- as.integer(prev_parts[2])

  major <- as.integer(major)
  minor <- as.integer(minor)

  version_is_valid <- major > prev_major ||
                      (major == prev_major && minor > prev_minor)

  current_version <- paste(major, minor, sep = '.')

  if(!version_is_valid){
    stop("version ", current_version, " has already been finalized.",
         " Did you remember to update `version_major` or `version_minor`",
         " in your `_targets.R` file?",
         call. = FALSE)
  }

  invisible(current_version)

}
