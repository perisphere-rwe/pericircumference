
local_mocked_pericircumference_project <- function(env = parent.frame()) {
  tmp <- withr::local_tempdir(.local_envir = env)
  usethis::local_project(tmp, force = TRUE, .local_envir = env)
  testthat::local_mocked_bindings(here = function(...) tmp, .package = "here",
                                  .env = env)
  invisible(tmp)
}

test_that("use_pericircumference() adds summarize_each_group.R and flextable.R when include_tutorials = TRUE", {
  tmp <- local_mocked_pericircumference_project()

  withr::with_dir(tmp, {
    suppressMessages(
      use_pericircumference(include_tutorials = TRUE,
                            include_report    = FALSE,
                            include_slides    = FALSE)
    )
  })

  r_files <- list.files(file.path(tmp, "R"))
  expect_true("summarize_each_group.R" %in% r_files)
  expect_true("flextable.R" %in% r_files)
  expect_false("shift.R" %in% r_files)
  expect_false("market_clarity.R" %in% r_files)
})

test_that("use_pericircumference() adds no optional helpers when include_tutorials = FALSE", {
  tmp <- local_mocked_pericircumference_project()

  withr::with_dir(tmp, {
    suppressMessages(
      use_pericircumference(include_tutorials = FALSE,
                            include_report    = FALSE,
                            include_slides    = FALSE)
    )
  })

  r_files <- list.files(file.path(tmp, "R"))
  expect_false("summarize_each_group.R" %in% r_files)
  expect_false("shift.R" %in% r_files)
  expect_false("flextable.R" %in% r_files)
  expect_false("market_clarity.R" %in% r_files)
})

test_that("use_pericircumference() errors outside the project root", {
  tmp <- withr::local_tempdir()
  other <- withr::local_tempdir()
  testthat::local_mocked_bindings(here = function(...) other, .package = "here")
  withr::with_dir(tmp, {
    expect_error(use_pericircumference(include_report = FALSE, include_slides = FALSE),
                regexp = "current working directory")
  })
})
