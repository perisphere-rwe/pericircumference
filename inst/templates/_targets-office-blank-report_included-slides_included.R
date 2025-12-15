
source("packages.R")
source("conflicts.R")

# Load your R files
tar_source()

# Allow crew package to use 3 parallel workers
tar_option_set(
  controller = crew_controller_local(workers = 3)
)

results_version_major <- 0
results_version_minor <- 1

create_output_directories(results_version_major)

tar_plan(

  tar_render(
      report,
      path = here::here("report/report.Rmd"),
      output_file = paste0("report", "-v", results_version_major, "/",
                           "report-", basename(here()),
                           "-v", results_version_major,
                           "-",  results_version_minor,
                           ".docx")
    ), 

  tar_render(
    slides,
    path = here::here("slides/slides.Rmd"),
    output_file = paste0("slides", "-v", results_version_major, "/",
                         "slides-", basename(here()),
                         "-v", results_version_major,
                         "-",  results_version_minor,
                         ".pptx")
  )
  
) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
