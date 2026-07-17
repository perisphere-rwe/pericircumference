
# Helper: write a version.rds into a temp dir and return the file path
version_file <- function(version_string, env = parent.frame()) {
  tmp  <- withr::local_tempdir(.local_envir = env)
  path <- file.path(tmp, "version.rds")
  readr::write_rds(version_string, path)
  path
}

# Valid bumps -------------------------------------------------------------------

test_that("assert_valid_version() accepts a minor bump", {
  path <- version_file("1.2")
  expect_equal(assert_valid_version(1, 3, path = path), "1.3")
})

test_that("assert_valid_version() accepts a major bump", {
  path <- version_file("1.9")
  expect_equal(assert_valid_version(2, 0, path = path), "2.0")
})

test_that("assert_valid_version() returns invisibly", {
  path <- version_file("0.0")
  expect_invisible(assert_valid_version(0, 1, path = path))
})

# The lexicographic bug --------------------------------------------------------

test_that("assert_valid_version() correctly accepts minor version >= 10", {
  # String comparison "1.9" > "1.10" — this was the bug
  path <- version_file("1.9")
  expect_equal(assert_valid_version(1, 10, path = path), "1.10")
})

test_that("assert_valid_version() correctly accepts minor version >= 10 across a range", {
  for (minor in 10:20) {
    path <- version_file(paste0("1.", minor - 1L))
    expect_equal(
      assert_valid_version(1, minor, path = path),
      paste0("1.", minor)
    )
  }
})

# Invalid versions -------------------------------------------------------------

test_that("assert_valid_version() rejects the same version", {
  path <- version_file("1.3")
  expect_error(assert_valid_version(1, 3, path = path), "already been finalized")
})

test_that("assert_valid_version() rejects a lower minor version", {
  path <- version_file("1.3")
  expect_error(assert_valid_version(1, 2, path = path), "already been finalized")
})

test_that("assert_valid_version() rejects a lower major version", {
  path <- version_file("2.0")
  expect_error(assert_valid_version(1, 9, path = path), "already been finalized")
})

test_that("assert_valid_version() rejects minor=9 when previous is minor=10", {
  # Inverse of the lexicographic bug: 1.9 should NOT be accepted after 1.10
  path <- version_file("1.10")
  expect_error(assert_valid_version(1, 9, path = path), "already been finalized")
})

# Missing file -----------------------------------------------------------------

test_that("assert_valid_version() errors when version.rds does not exist", {
  expect_error(
    assert_valid_version(1, 0, path = tempfile()),
    "version.rds file not found"
  )
})
