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

  # data targets ----

  # results targets ----

  # table targets ----

  # figure targets ----

  # document targets ----

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
