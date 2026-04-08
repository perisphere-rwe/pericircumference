
#' @title Make changes after a version has been finalized
#'
#' @description The main purpose of this function is to return to an earlier
#'   version of a project in order to make changes. That is, it undoes the
#'   result of [](finalize_version).
#'
#' @inheritParams finalize_version
#' @inheritParams assert_valid_version
#'
#' @returns Nothing is returned. The version in `version.rds` is updated to an
#'   older version.
#'
#' @importFrom readr write_rds
#'
#' @export
rewind_version <- function(major,
                           minor,
                           path = 'version.rds') {

  current_version <- assert_valid_version(major = major,
                                          minor = minor,
                                          path = path,
                                          allow_previous = TRUE)

  write_rds(current_version, path)

  message(
    "The version has been rewound to {current_version}. ",
    "Please modify changelog.md accordingly."
  )

  invisible(current_version)
}
