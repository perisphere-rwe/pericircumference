

read_changelog_latest <- function(path = "changelog.md",
                                  version_starts_with = "## Version") {


  if (!file.exists(path)) {

    full_path <- normalizePath(path, winslash = "/", mustWork = FALSE)

    stop(
      sprintf(
        "file %s not found.\n\nHere is the full path to the file you supplied:\n%s\n\nDo you need to change your working directory?",
        path,
        full_path
      ),
      call. = FALSE
    )

  }

  lines <- readLines(path, warn = FALSE)

  idx <- grep(paste0("^", version_starts_with), lines)

  if (length(idx) == 0) {
    stop('No occurrences of "', version_starts_with,'" found in changelog.md',
         call. = FALSE)
  }

  if (length(idx) == 1) {
    return(lines[(idx + 1L):length(lines)])
  }

  out <- lines[(idx[1] + 1L):(idx[2] - 1L)]

  if(any(out == "")) out <- out[-which(out == "")]

  out

}



#' Finalize a release of project results
#'
#' The main purpose of this function is to facilitate the process of
#'  sharing results with your collaborator and updating the code in your
#'  project so that those results won't get inadvertently overwritten
#'  in the future.
#'
#' @param major (numeric) the current major version of your project
#' @param minor (numeric) the current minor version of your project
#'
#' @returns no R objects are returned. Files are modified and the most recent
#'   set of changes are copied to your clipboard so that you can paste them
#'   into an e-mail where you share the results with collaborators.
#'
#' @export
#'
finalize_version <- function(major, minor){

  version_path <- 'version.rds'

  current_version <- assert_valid_version(major = major,
                                          minor = minor,
                                          path = version_path)

  readr::write_rds(current_version, version_path)

  changes <- read_changelog_latest()

  message("Version ", current_version, " has been finalized.\n",
          " - The changes in your changelog are written below .\n",
          " - Remember to update `version_major` and/or `version_minor` in your _targets.R file.\n",
          " - Remember to make a git commit (if feasible) using the commit message 'finalize version ", current_version, "'")

  message("\nChanges in this update:\n", paste(changes, collapse = '\n'))

}

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
#' @export
#'
assert_valid_version <- function(major, minor, path = 'version.rds'){

  if(!file.exists(path)){
    stop("version.rds file not found. This should not happen.",
         " email me at bcjaeger@perisphere-rwe.com for help.",
         call. = FALSE)
  }

  previous_version <- readr::read_rds(path)
  current_version <- paste(major, minor, sep = '.')

  if(current_version <= previous_version){
    stop("version ", current_version, " has already been finalized.",
         " Did you remember to update `version_major` or `version_minor`",
         " in your `_targets.R` file?",
         call. = FALSE)
  }

  invisible(current_version)

}
