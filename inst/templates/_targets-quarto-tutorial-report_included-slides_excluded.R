
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

tar_plan(
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

  })

) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
