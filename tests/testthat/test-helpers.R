
# Shared helpers ----------------------------------------------------------

# Sets up a temp directory as the active usethis project for the duration of
# the calling test. Returns the path invisibly.
local_perisphere_project <- function(env = parent.frame()) {
  tmp <- withr::local_tempdir(.local_envir = env)
  usethis::local_project(tmp, force = TRUE, .local_envir = env)
  invisible(tmp)
}

# Build the tmpl_data list the same way use_pericircumference() does.
make_tmpl_data <- function(report_name        = "report",
                           slides_name        = "slides",
                           include_report     = TRUE,
                           include_slides     = TRUE,
                           report_title       = "Report",
                           slides_title       = "Presentation",
                           author             = "") {
  list(
    report_name        = report_name,
    report_dir         = report_name,
    report_title       = report_title,
    slides_name        = slides_name,
    slides_dir         = slides_name,
    slides_title       = slides_title,
    author             = author,
    include_report     = include_report,
    include_slides     = include_slides,
    include_any_output = include_report || include_slides
  )
}


# .peri_use_binary() ------------------------------------------------------

test_that(".peri_use_binary() copies file to destination", {
  tmp <- local_perisphere_project()

  dest <- file.path(tmp, "perisphere_template.docx")
  suppressMessages(.peri_use_binary("perisphere-template.docx", dest))

  expect_true(file.exists(dest))
  expect_gt(file.size(dest), 0)
})

test_that(".peri_use_binary() emits a cli message", {
  tmp <- local_perisphere_project()
  dest <- file.path(tmp, "perisphere_template.docx")

  expect_message(
    .peri_use_binary("perisphere-template.docx", dest),
    regexp = "perisphere_template.docx"
  )
})


# .peri_add_core_files() --------------------------------------------------

test_that(".peri_add_core_files() creates all core files", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "R"))
  suppressMessages(.peri_add_core_files(make_tmpl_data()))

  expect_true(file.exists(file.path(tmp, "version.rds")))
  expect_true(file.exists(file.path(tmp, "packages.R")))
  expect_true(file.exists(file.path(tmp, "conflicts.R")))
  expect_true(file.exists(file.path(tmp, ".gitignore")))
  expect_true(file.exists(file.path(tmp, "changelog.md")))
  expect_true(file.exists(file.path(tmp, "R", "create_output_directories.R")))
})

test_that(".peri_add_core_files() initialises version to '0.0'", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "R"))
  suppressMessages(.peri_add_core_files(make_tmpl_data()))

  version <- readr::read_rds(file.path(tmp, "version.rds"))
  expect_equal(version, "0.0")
})

test_that(".peri_add_core_files() substitutes default dir names into create_output_directories.R", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "R"))
  suppressMessages(.peri_add_core_files(make_tmpl_data()))

  content <- paste(readLines(file.path(tmp, "R", "create_output_directories.R")),
                   collapse = "\n")
  expect_match(content, '"report"')
  expect_match(content, '"slides"')
  expect_no_match(content, "\\{\\{\\{")
})

test_that(".peri_add_core_files() substitutes custom dir names into create_output_directories.R", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "R"))
  suppressMessages(
    .peri_add_core_files(make_tmpl_data(report_name = "results",
                                        slides_name = "presentation"))
  )

  content <- paste(readLines(file.path(tmp, "R", "create_output_directories.R")),
                   collapse = "\n")
  expect_match(content, '"results"')
  expect_match(content, '"presentation"')
  expect_no_match(content, '"report"')
  expect_no_match(content, '"slides"')
})


# .peri_add_r_helpers_misc() ----------------------------------------------

test_that(".peri_add_r_helpers_misc() creates summarize_each_group.R and shift.R", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "R"))
  suppressMessages(.peri_add_r_helpers_misc())

  expect_true(file.exists(file.path(tmp, "R", "summarize_each_group.R")))
  expect_true(file.exists(file.path(tmp, "R", "shift.R")))
  expect_false(file.exists(file.path(tmp, "R", "flextable.R")))
  expect_false(file.exists(file.path(tmp, "R", "create_output_directories.R")))
})

# .peri_add_r_helpers_flex() ----------------------------------------------

test_that(".peri_add_r_helpers_flex() creates flextable.R", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "R"))
  suppressMessages(.peri_add_r_helpers_flex())

  expect_true(file.exists(file.path(tmp, "R", "flextable.R")))
  expect_false(file.exists(file.path(tmp, "R", "shift.R")))
  expect_false(file.exists(file.path(tmp, "R", "summarize_each_group.R")))
})


# .peri_add_pipeline() ----------------------------------------------------

test_that(".peri_add_pipeline() creates _targets.R", {
  tmp <- local_perisphere_project()
  suppressMessages(.peri_add_pipeline("office", "blank", make_tmpl_data()))

  expect_true(file.exists(file.path(tmp, "_targets.R")))
})

test_that(".peri_add_pipeline() substitutes default names correctly", {
  tmp <- local_perisphere_project()
  suppressMessages(.peri_add_pipeline("office", "blank", make_tmpl_data()))

  content <- paste(readLines(file.path(tmp, "_targets.R")), collapse = "\n")

  expect_match(content, "report/report.Rmd")
  expect_match(content, "slides/slides.Rmd")
  expect_no_match(content, "\\{\\{\\{")
})

test_that(".peri_add_pipeline() substitutes custom names correctly", {
  tmp <- local_perisphere_project()
  suppressMessages(
    .peri_add_pipeline(
      "office", "blank",
      make_tmpl_data(report_name = "results", slides_name = "presentation")
    )
  )

  content <- paste(readLines(file.path(tmp, "_targets.R")), collapse = "\n")

  expect_match(content, "results/results.Rmd")
  expect_match(content, "presentation/presentation.Rmd")
  expect_no_match(content, "report/report.Rmd")
  expect_no_match(content, "slides/slides.Rmd")
})

test_that(".peri_add_pipeline() omits report block when include_report = FALSE", {
  tmp <- local_perisphere_project()
  suppressMessages(
    .peri_add_pipeline("office", "blank",
                       make_tmpl_data(include_report = FALSE))
  )

  content <- paste(readLines(file.path(tmp, "_targets.R")), collapse = "\n")

  expect_no_match(content, "report.Rmd")
  expect_match(content, "slides.Rmd")
})

test_that(".peri_add_pipeline() omits slides block when include_slides = FALSE", {
  tmp <- local_perisphere_project()
  suppressMessages(
    .peri_add_pipeline("office", "blank",
                       make_tmpl_data(include_slides = FALSE))
  )

  content <- paste(readLines(file.path(tmp, "_targets.R")), collapse = "\n")

  expect_no_match(content, "slides.Rmd")
  expect_match(content, "report.Rmd")
})

check_pipeline_syntax <- function(doc_format, tutorial_type) {
  combos <- expand.grid(
    include_report = c(TRUE, FALSE),
    include_slides = c(TRUE, FALSE)
  )
  for (i in seq_len(nrow(combos))) {
    tmp <- local_perisphere_project()
    suppressMessages(
      .peri_add_pipeline(
        doc_format, tutorial_type,
        make_tmpl_data(include_report = combos$include_report[i],
                       include_slides = combos$include_slides[i])
      )
    )
    # expect_no_error() registers an expectation each iteration,
    # preventing the "empty test" skip
    expect_no_error(parse(file = file.path(tmp, "_targets.R")))
  }
}

test_that(".peri_add_pipeline() office/blank produces valid R syntax for all inclusion combinations", {
  check_pipeline_syntax("office", "blank")
})

test_that(".peri_add_pipeline() office/tutorial produces valid R syntax for all inclusion combinations", {
  check_pipeline_syntax("office", "tutorial")
})

test_that(".peri_add_pipeline() quarto/blank produces valid R syntax for all inclusion combinations", {
  check_pipeline_syntax("quarto", "blank")
})


# .peri_add_report() ------------------------------------------------------

test_that(".peri_add_report() creates report files for office format", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "report"))

  suppressMessages(
    .peri_add_report("office", "blank", "report", "Rmd", make_tmpl_data())
  )

  expect_true(file.exists(file.path(tmp, "report", "report.Rmd")))
  expect_true(file.exists(file.path(tmp, "report", "refs.bib")))
  expect_true(file.exists(file.path(tmp, "report", "refs.csl")))
  expect_true(file.exists(file.path(tmp, "report", "perisphere_template.docx")))
})

test_that(".peri_add_report() uses custom report_name for office format", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "results"))

  suppressMessages(
    .peri_add_report("office", "blank", "results", "Rmd",
                     make_tmpl_data(report_name = "results"))
  )

  expect_true(file.exists(file.path(tmp, "results", "results.Rmd")))
  expect_false(file.exists(file.path(tmp, "results", "report.Rmd")))
})

test_that(".peri_add_report() substitutes title and author into office .Rmd", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "report"))

  suppressMessages(
    .peri_add_report("office", "blank", "report", "Rmd",
                     make_tmpl_data(report_title = "My Study", author = "Jane Smith"))
  )

  content <- paste(readLines(file.path(tmp, "report", "report.Rmd")), collapse = "\n")
  expect_match(content, 'title: "My Study"')
  expect_match(content, 'author: "Jane Smith"')
  expect_no_match(content, "\\{\\{\\{")
})

test_that(".peri_add_report() creates report files for quarto format", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "report"))

  suppressMessages(
    .peri_add_report("quarto", "blank", "report", "qmd", make_tmpl_data())
  )

  expect_true(file.exists(file.path(tmp, "report.qmd")))
  expect_true(file.exists(file.path(tmp, "report", "toc-button.html")))
  expect_true(file.exists(file.path(tmp, "report", "perisphere-report.css")))
})

test_that(".peri_add_report() substitutes title, author, and dir paths into quarto .qmd", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "results"))

  suppressMessages(
    .peri_add_report("quarto", "blank", "results", "qmd",
                     make_tmpl_data(report_name  = "results",
                                    report_title = "My Study",
                                    author       = "Jane Smith"))
  )

  content <- paste(readLines(file.path(tmp, "results.qmd")), collapse = "\n")
  expect_match(content, 'title: "My Study"')
  expect_match(content, 'author: "Jane Smith"')
  expect_match(content, "results/refs.bib")
  expect_match(content, "results/perisphere-report.css")
  expect_no_match(content, "report/")
  expect_no_match(content, "\\{\\{\\{")
})


# .peri_add_slides() ------------------------------------------------------

test_that(".peri_add_slides() creates slides files for office format", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "slides"))

  suppressMessages(
    .peri_add_slides("office", "blank", "slides", "Rmd", make_tmpl_data())
  )

  expect_true(file.exists(file.path(tmp, "slides", "slides.Rmd")))
  expect_true(file.exists(file.path(tmp, "slides", "refs.bib")))
  expect_true(file.exists(file.path(tmp, "slides", "refs.csl")))
  expect_true(file.exists(file.path(tmp, "slides", "perisphere_template.pptx")))
})

test_that(".peri_add_slides() uses custom slides_name for office format", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "presentation"))

  suppressMessages(
    .peri_add_slides("office", "blank", "presentation", "Rmd",
                     make_tmpl_data(slides_name = "presentation"))
  )

  expect_true(file.exists(file.path(tmp, "presentation", "presentation.Rmd")))
  expect_false(file.exists(file.path(tmp, "presentation", "slides.Rmd")))
})

test_that(".peri_add_slides() substitutes title and author into office .Rmd", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "slides"))

  suppressMessages(
    .peri_add_slides("office", "blank", "slides", "Rmd",
                     make_tmpl_data(slides_title = "My Slides", author = "Jane Smith"))
  )

  content <- paste(readLines(file.path(tmp, "slides", "slides.Rmd")), collapse = "\n")
  expect_match(content, 'title: "My Slides"')
  expect_match(content, 'author: "Jane Smith"')
  expect_no_match(content, "\\{\\{\\{")
})

test_that(".peri_add_slides() creates slides files for quarto format", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "slides"))

  suppressMessages(
    .peri_add_slides("quarto", "blank", "slides", "qmd", make_tmpl_data())
  )

  expect_true(file.exists(file.path(tmp, "slides.qmd")))
  expect_true(file.exists(file.path(tmp, "slides", "perisphere-slides.css")))
  expect_true(file.exists(file.path(tmp, "slides", "perisphere-logo.png")))
})

test_that(".peri_add_slides() substitutes title, author, and dir paths into quarto .qmd", {
  tmp <- local_perisphere_project()
  dir.create(file.path(tmp, "presentation"))

  suppressMessages(
    .peri_add_slides("quarto", "blank", "presentation", "qmd",
                     make_tmpl_data(slides_name  = "presentation",
                                    slides_title = "My Slides",
                                    author       = "Jane Smith"))
  )

  content <- paste(readLines(file.path(tmp, "presentation.qmd")), collapse = "\n")
  expect_match(content, 'title: "My Slides"')
  expect_match(content, 'author: "Jane Smith"')
  expect_match(content, "presentation/perisphere-slides.css")
  expect_match(content, "presentation/perisphere-logo.png")
  expect_no_match(content, "slides/")
  expect_no_match(content, "\\{\\{\\{")
})
