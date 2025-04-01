source("packages.R")
source("conflicts.R")

# Load your R files
tar_source()

# Allow crew package to use 3 parallel workers
tar_option_set(
  controller = crew_controller_local(workers = 3)
)

results_version_major <- 1
results_version_minor <- 0

if(!dir.exists(glue("doc/results-v{results_version_major}"))){
  dir.create(glue("doc/results-v{results_version_major}"))
}


tar_plan(

  data = palmerpenguins::penguins,

  meta = as_data_dictionary(data) %>%
    set_labels(species = "Species",
               sex = "Sex",
               body_mass_g = "Body mass",
               flipper_length_mm = "Flipper length",
               bill_length_mm = "Bill length",
               bill_depth_mm = "Bill depth",
               year = "Collection year",
               island = "Collection location") %>%
    set_factor_order(sex = "male") %>%
    set_factor_labels(sex = c(female = "Females", male = "Males")) %>%
    set_units(bill_length_mm = "mm",
              bill_depth_mm = "mm",
              flipper_length_mm = "mm",
              body_mass_g = "grams") %>%
    set_divby_modeling(bill_length_mm = 5,
                       bill_depth_mm = 5),

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
      as_inline(tbl_variables = c('.group_level', 'name'),
                tbl_values = 'value')

  }),

  tar_render(
    results,
    path = here::here("doc/results.Rmd"),
    output_file = paste0("results", "-v", results_version_major, "/",
                         "results-", basename(here()),
                         "-v", results_version_major,
                         "-",  results_version_minor,
                         ".docx")
  )

) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
