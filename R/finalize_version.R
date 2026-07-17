
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
    stop('No occurrences of "', version_starts_with, '" found in ', path,
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
#' @param version_path a string giving the path to the `version.rds` file.
#'   Defaults to `"version.rds"` in the current working directory.
#' @param changelog_path a string giving the path to the changelog file.
#'   Defaults to `"changelog.md"` in the current working directory.
#'
#' @returns no R objects are returned. Files are modified and the most recent
#'   set of changes are printed so that you can paste them into an e-mail
#'   where you share the results with collaborators.
#'
#' @importFrom readr write_rds
#'
#' @export
#'
finalize_version <- function(major, minor,
                              version_path   = "version.rds",
                              changelog_path = "changelog.md") {

  current_version <- assert_valid_version(major = major,
                                          minor = minor,
                                          path  = version_path)

  write_rds(current_version, version_path)

  changes <- read_changelog_latest(path = changelog_path)

  message("Version ", current_version, " has been finalized.\n",
          " - The changes in your changelog are written below.\n",
          " - Remember to update `version_major` and/or `version_minor` in your _targets.R file.\n",
          " - Remember to make a git commit (if feasible) using the commit message 'finalize version ", current_version, "'")

  message("\nChanges in this update:\n", paste(changes, collapse = '\n'))

}
