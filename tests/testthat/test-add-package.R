
# Helper: write a minimal packages.R to a temp file and return its path.
make_packages_file <- function(env = parent.frame()) {
  tmp  <- withr::local_tempdir(.local_envir = env)
  path <- file.path(tmp, "packages.R")
  writeLines(c("library(targets)", "library(tidyverse)"), path)
  path
}


# add_package() ----------------------------------------------------------------

test_that("add_package() appends a library() call to the packages file", {
  path <- make_packages_file()
  suppressMessages(add_package("ggplot2", path = path))

  contents <- readLines(path)
  expect_true("library(ggplot2)" %in% contents)
})

test_that("add_package() accepts a non-default path", {
  tmp  <- withr::local_tempdir()
  path <- file.path(tmp, "pkgs.R")
  writeLines("library(targets)", path)

  suppressMessages(add_package("dplyr", path = path))
  expect_true("library(dplyr)" %in% readLines(path))
})

test_that("add_package() does not add a duplicate entry", {
  path <- make_packages_file()
  suppressMessages(add_package("targets", path = path))

  contents <- readLines(path)
  expect_equal(sum(contents == "library(targets)"), 1L)
})

test_that("add_package() adds a purpose comment above the library() call", {
  path <- make_packages_file()
  suppressMessages(add_package("glue", purpose = "string interpolation",
                                path = path))

  contents <- readLines(path)
  glue_idx    <- which(contents == "library(glue)")
  comment_idx <- which(grepl("string interpolation", contents))

  expect_length(glue_idx, 1)
  expect_length(comment_idx, 1)
  # comment should appear on the line immediately before library()
  expect_equal(comment_idx, glue_idx - 1L)
})

test_that("add_package() prefixes purpose with # if not already present", {
  path <- make_packages_file()
  suppressMessages(add_package("glue", purpose = "no hash yet", path = path))

  contents <- readLines(path)
  expect_true(any(grepl("^# no hash yet", contents)))
})

test_that("add_package() accepts a purpose that already starts with #", {
  path <- make_packages_file()
  suppressMessages(add_package("glue", purpose = "# already hashed",
                                path = path))

  contents <- readLines(path)
  # should not double-hash
  expect_false(any(grepl("^## already hashed", contents)))
  expect_true(any(grepl("^# already hashed", contents)))
})

test_that("add_package() errors with updated message when packages file is missing", {
  expect_error(
    add_package("ggplot2", path = tempfile()),
    regexp = "pericircumference::use_pericircumference"
  )
})

test_that("add_package() errors when purpose is not a length-1 character", {
  path <- make_packages_file()
  expect_error(suppressMessages(add_package("glue", purpose = 123,         path = path)),
               regexp = "character value of length 1")
  expect_error(suppressMessages(add_package("glue", purpose = c("a", "b"), path = path)),
               regexp = "character value of length 1")
})

test_that("add_package() returns invisibly", {
  path <- make_packages_file()
  expect_invisible(suppressMessages(add_package("glue", path = path)))
})

test_that("add_package() does not attach the package to the session", {
  path     <- make_packages_file()
  before   <- search()
  suppressMessages(add_package("tools", path = path))
  after    <- search()

  # search path should be unchanged — no new packages attached
  expect_equal(before, after)
})
