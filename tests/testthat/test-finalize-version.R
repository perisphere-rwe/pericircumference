
# Helpers ----------------------------------------------------------------------

# Writes a minimal changelog with two version sections to a temp file.
make_changelog <- function(path, env = parent.frame()) {
  withr::local_file(path, .local_envir = env)
  writeLines(c(
    "## Version 0.2",
    "- Second release notes.",
    "",
    "## Version 0.1",
    "- First release notes."
  ), path)
  invisible(path)
}

make_version_file <- function(version, path, env = parent.frame()) {
  withr::local_file(path, .local_envir = env)
  readr::write_rds(version, path)
  invisible(path)
}


# finalize_version() -----------------------------------------------------------

test_that("finalize_version() updates version_path with the new version", {
  tmp      <- withr::local_tempdir()
  vpath    <- file.path(tmp, "version.rds")
  cpath    <- file.path(tmp, "changelog.md")

  make_version_file("0.1", vpath)
  make_changelog(cpath)

  suppressMessages(
    finalize_version(0, 2, version_path = vpath, changelog_path = cpath)
  )

  expect_equal(readr::read_rds(vpath), "0.2")
})

test_that("finalize_version() accepts non-default version_path", {
  tmp   <- withr::local_tempdir()
  vpath <- file.path(tmp, "my_version.rds")
  cpath <- file.path(tmp, "changelog.md")

  make_version_file("0.0", vpath)
  make_changelog(cpath)

  suppressMessages(
    finalize_version(0, 1, version_path = vpath, changelog_path = cpath)
  )

  expect_equal(readr::read_rds(vpath), "0.1")
})

test_that("finalize_version() accepts non-default changelog_path", {
  tmp   <- withr::local_tempdir()
  vpath <- file.path(tmp, "version.rds")
  cpath <- file.path(tmp, "CHANGES.md")

  make_version_file("0.0", vpath)
  make_changelog(cpath)

  expect_message(
    finalize_version(0, 1, version_path = vpath, changelog_path = cpath),
    regexp = "0.1"
  )
})

test_that("finalize_version() errors on invalid version bump", {
  tmp   <- withr::local_tempdir()
  vpath <- file.path(tmp, "version.rds")
  cpath <- file.path(tmp, "changelog.md")

  make_version_file("1.0", vpath)
  make_changelog(cpath)

  expect_error(
    finalize_version(1, 0, version_path = vpath, changelog_path = cpath),
    regexp = "already been finalized"
  )
})

test_that("finalize_version() errors when changelog_path does not exist", {
  tmp   <- withr::local_tempdir()
  vpath <- file.path(tmp, "version.rds")

  make_version_file("0.0", vpath)

  expect_error(
    finalize_version(0, 1,
                     version_path   = vpath,
                     changelog_path = file.path(tmp, "no_such_file.md")),
    regexp = "not found"
  )
})


# read_changelog_latest() ------------------------------------------------------

test_that("read_changelog_latest() returns lines of the most recent version", {
  tmp  <- withr::local_tempdir()
  path <- file.path(tmp, "changelog.md")

  writeLines(c(
    "## Version 0.2",
    "- New feature.",
    "",
    "## Version 0.1",
    "- Initial release."
  ), path)

  result <- pericircumference:::read_changelog_latest(path)
  expect_true(any(grepl("New feature", result)))
  expect_false(any(grepl("Initial release", result)))
})

test_that("read_changelog_latest() errors informatively when file is missing", {
  expect_error(
    pericircumference:::read_changelog_latest(path = tempfile()),
    regexp = "not found"
  )
})

test_that("read_changelog_latest() errors when no version headers found", {
  tmp  <- withr::local_tempdir()
  path <- file.path(tmp, "changelog.md")
  writeLines("just some text with no version headers", path)

  expect_error(
    pericircumference:::read_changelog_latest(path),
    regexp = "No occurrences"
  )
})
