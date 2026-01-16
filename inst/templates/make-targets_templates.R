

preamble <- '
source("packages.R")
source("conflicts.R")

# Load your R files
tar_source()

# Allow crew package to use 3 parallel workers
tar_option_set(
  controller = crew_controller_local(workers = 3)
)

version_major <- 0
version_minor <- 1

assert_valid_version(version_major, version_minor)

create_output_directories(version_major)
'


plan_content <- list(
  blank = '',
  tutorial = '
  # data ----

  data = palmerpenguins::penguins,

  # meta ----

  meta = as_data_dictionary(data) %>%
    set_labels(species = "Species",
               sex = "Sex",
               body_mass_g = "Body mass",
               flipper_length_mm = "Flipper length",
               bill_length_mm = "Bill length",
               bill_depth_mm = "Bill depth",
               year = "Collection year",
               island = "Collection location") %>%
    set_category_order(sex = "male") %>%
    set_category_labels(sex = c(female = "Females", male = "Males")) %>%
    set_units(bill_length_mm = "mm",
              bill_depth_mm = "mm",
              flipper_length_mm = "mm",
              body_mass_g = "grams") %>%
    set_divby_modeling(bill_length_mm = 5,
                       bill_depth_mm = 5),

  # stats ----

  tar_target(stats, command = {

    data %>%
      group_by(species) %>%
      summarize_each_group(
        mean_bill_length = mean(bill_length_mm, na.rm = TRUE),
        mean_mass = mean(body_mass_g, na.rm = TRUE),
        sd_mass = sd(body_mass_g, na.rm = TRUE),
        nobs = n()
      ) %>%
      pivot_longer(cols = c(mean_bill_length,
                            mean_mass,
                            sd_mass,
                            nobs)) %>%
      # only needed if we used >= 2 group variables
      select(-.group_variable) %>%
      as_inline(tbl_variables = c(".group_level", "name"),
                tbl_values = "value")

  }),
'
)

report <- list(
  blank = '',
  office = '
  tar_render(
      report,
      path = here::here("report/report.Rmd"),
      output_file = paste0("report", "-v", version_major, "/",
                           "report-", basename(here()),
                           "-v", version_major,
                           "-",  version_minor,
                           ".docx")
    )',
  quarto = '
  tar_target(report_file, "report.qmd", format = "file"),

  tar_target(report, command = {

    output_file <- paste0("report-", basename(here()),
                          "-v", version_major,
                          "-",  version_minor,
                          ".html")

    output_dir <- paste0("report", "-v", version_major)

    quarto_render(input = report_file, output_file = output_file)

    file_moved <- file.copy(from = output_file,
                            to = file.path("report", output_dir, output_file),
                            overwrite = TRUE)

    if(file_moved){
      file.remove(output_file)
    } else {
      stop(
        "could not copy report output. Check report target in _targets.R"
      )
    }

    NULL

  })'
)



slides <- list(
  blank = '',
  office = '
  tar_render(
    slides,
    path = here::here("slides/slides.Rmd"),
    output_file = paste0("slides", "-v", version_major, "/",
                         "slides-", basename(here()),
                         "-v", version_major,
                         "-",  version_minor,
                         ".pptx")
  )
  ',
  quarto = '
  tar_target(slides_file, "slides.qmd", format = "file"),

  tar_target(slides, command = {

    output_file <- paste0("slides-", basename(here()),
                          "-v", version_major,
                          "-",  version_minor,
                          ".html")

    output_dir <- paste0("slides", "-v", version_major)

    quarto_render(input = slides_file, output_file = output_file)

    file_moved <- file.copy(from = output_file,
                            to = file.path("slides", output_dir, output_file),
                            overwrite = TRUE)

    if(file_moved){
      file.remove(output_file)
    } else {
      stop(
        "could not copy slides output. Check slides target in _targets.R"
      )
    }

    NULL

  })
  '
)

postamble <- '%>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
'

library(tidyverse)
library(glue)

targets_guide <- expand_grid(
  output_format = c("office", "quarto"),
  content_type = c("blank", "tutorial"),
  report_type = c("report_included", "report_excluded"),
  slides_type = c("slides_included", "slides_excluded")
) %>%
  mutate(
    fname = glue(
      "_targets-{output_format}-{content_type}-{report_type}-{slides_type}.R"
    ),
    ftext = pmap(
      .l = list(output_format, content_type, report_type, slides_type, fname),
      .f = function(output_format, content_type, report_type, slides_type, fname){

        cat(
          preamble, '\n',
          'tar_plan(',
          plan_content[[content_type]], '\n',

          if(report_type == 'report_included'){
            report[[output_format]]
          } else {
            '\n'
          },


          if(slides_type == 'slides_included'){
            c(if(report_type=="report_included"){ ', \n'} else NULL,
              slides[[output_format]], '\n')
          } else {
            '\n\n'
          },
          ') ',
          postamble,
          sep = '',
          file = file.path("inst", "templates", fname)
        )
      }
    )
  )





