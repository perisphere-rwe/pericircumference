
# Strategy: use local_mocked_bindings() to capture the arguments actually
# passed to use_pericircumference(), so we can verify both the fixed args
# and ... forwarding without needing a live project directory.

capture_pericircumference_args <- function(wrapper_call, env = parent.frame()) {
  captured <- NULL
  testthat::local_mocked_bindings(
    use_pericircumference = function(...) { captured <<- list(...) },
    .package = "pericircumference",
    .env = env
  )
  wrapper_call
  captured
}

# use_pericircumference_report_ms() -------------------------------------------

test_that("use_pericircumference_report_ms() passes correct fixed arguments", {
  args <- capture_pericircumference_args(use_pericircumference_report_ms())

  expect_equal(args$doc_format,        "office")
  expect_equal(args$include_tutorials, FALSE)
  expect_equal(args$include_report,    TRUE)
  expect_equal(args$include_slides,    FALSE)
})

test_that("use_pericircumference_report_ms() forwards include_helpers_* via ...", {
  args <- capture_pericircumference_args(
    use_pericircumference_report_ms(include_helpers_flextable = FALSE,
                                    include_helpers_misc      = TRUE)
  )
  expect_equal(args$include_helpers_flextable, FALSE)
  expect_equal(args$include_helpers_misc,      TRUE)
})

test_that("use_pericircumference_report_ms() forwards ... to use_pericircumference()", {
  args <- capture_pericircumference_args(
    use_pericircumference_report_ms(report_name = "results")
  )
  expect_equal(args$report_name, "results")
})

# use_pericircumference_report_qt() -------------------------------------------

test_that("use_pericircumference_report_qt() passes correct fixed arguments", {
  args <- capture_pericircumference_args(use_pericircumference_report_qt())

  expect_equal(args$doc_format,        "quarto")
  expect_equal(args$include_tutorials, FALSE)
  expect_equal(args$include_report,    TRUE)
  expect_equal(args$include_slides,    FALSE)
})

test_that("use_pericircumference_report_qt() forwards ... to use_pericircumference()", {
  args <- capture_pericircumference_args(
    use_pericircumference_report_qt(report_name = "results")
  )
  expect_equal(args$report_name, "results")
})

# use_pericircumference_slides_ms() -------------------------------------------

test_that("use_pericircumference_slides_ms() passes correct fixed arguments", {
  args <- capture_pericircumference_args(use_pericircumference_slides_ms())

  expect_equal(args$doc_format,        "office")
  expect_equal(args$include_tutorials, FALSE)
  expect_equal(args$include_report,    FALSE)
  expect_equal(args$include_slides,    TRUE)
})

test_that("use_pericircumference_slides_ms() forwards ... to use_pericircumference()", {
  args <- capture_pericircumference_args(
    use_pericircumference_slides_ms(slides_name = "presentation")
  )
  expect_equal(args$slides_name, "presentation")
})

# use_pericircumference_slides_qt() -------------------------------------------

test_that("use_pericircumference_slides_qt() passes correct fixed arguments", {
  args <- capture_pericircumference_args(use_pericircumference_slides_qt())

  expect_equal(args$doc_format,        "quarto")
  expect_equal(args$include_tutorials, FALSE)
  expect_equal(args$include_report,    FALSE)
  expect_equal(args$include_slides,    TRUE)
})

test_that("use_pericircumference_slides_qt() forwards ... to use_pericircumference()", {
  args <- capture_pericircumference_args(
    use_pericircumference_slides_qt(slides_name = "presentation")
  )
  expect_equal(args$slides_name, "presentation")
})
