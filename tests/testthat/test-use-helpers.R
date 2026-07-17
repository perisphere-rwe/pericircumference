
# Shared helper: create a temp dir, mock here::here() to match it, and run
# code with getwd() set to that dir (so .peri_assert_project_root() passes).
with_mocked_project <- function(code, env = parent.frame()) {
  tmp <- withr::local_tempdir(.local_envir = env)
  usethis::local_project(tmp, force = TRUE, .local_envir = env)
  testthat::local_mocked_bindings(here = function(...) tmp, .package = "here",
                                  .env = env)
  withr::with_dir(tmp, code)
  tmp
}

# use_helpers_flextable() --------------------------------------------------

test_that("use_helpers_flextable() creates R/flextable.R, creating R/ if absent", {
  tmp <- with_mocked_project(suppressMessages(use_helpers_flextable()))

  expect_true(file.exists(file.path(tmp, "R", "flextable.R")))
})

test_that("use_helpers_flextable() errors outside the project root", {
  tmp <- withr::local_tempdir()
  other <- withr::local_tempdir()
  testthat::local_mocked_bindings(here = function(...) other, .package = "here")
  withr::with_dir(tmp, {
    expect_error(use_helpers_flextable(), regexp = "current working directory")
  })
})

# use_helpers_datatable() ---------------------------------------------------

test_that("use_helpers_datatable() creates only R/shift.R", {
  tmp <- with_mocked_project(suppressMessages(use_helpers_datatable()))

  expect_true(file.exists(file.path(tmp, "R", "shift.R")))
  expect_false(file.exists(file.path(tmp, "R", "summarize_each_group.R")))
})

test_that("use_helpers_datatable() errors outside the project root", {
  tmp <- withr::local_tempdir()
  other <- withr::local_tempdir()
  testthat::local_mocked_bindings(here = function(...) other, .package = "here")
  withr::with_dir(tmp, {
    expect_error(use_helpers_datatable(), regexp = "current working directory")
  })
})

# use_helpers_tidyverse() ---------------------------------------------------

test_that("use_helpers_tidyverse() creates only R/summarize_each_group.R", {
  tmp <- with_mocked_project(suppressMessages(use_helpers_tidyverse()))

  expect_true(file.exists(file.path(tmp, "R", "summarize_each_group.R")))
  expect_false(file.exists(file.path(tmp, "R", "shift.R")))
})

test_that("use_helpers_tidyverse() errors outside the project root", {
  tmp <- withr::local_tempdir()
  other <- withr::local_tempdir()
  testthat::local_mocked_bindings(here = function(...) other, .package = "here")
  withr::with_dir(tmp, {
    expect_error(use_helpers_tidyverse(), regexp = "current working directory")
  })
})

# use_helpers_market_clarity() ----------------------------------------------

test_that("use_helpers_market_clarity() creates R/market_clarity.R", {
  tmp <- with_mocked_project(suppressMessages(use_helpers_market_clarity()))

  expect_true(file.exists(file.path(tmp, "R", "market_clarity.R")))
})

test_that("use_helpers_market_clarity() errors outside the project root", {
  tmp <- withr::local_tempdir()
  other <- withr::local_tempdir()
  testthat::local_mocked_bindings(here = function(...) other, .package = "here")
  withr::with_dir(tmp, {
    expect_error(use_helpers_market_clarity(), regexp = "current working directory")
  })
})
