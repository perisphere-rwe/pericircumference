
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


  tar_render(
    slides,
    path = here::here("slides/slides.Rmd"),
    output_file = paste0("slides", "-v", version_major, "/",
                         "slides-", basename(here()),
                         "-v", version_major,
                         "-",  version_minor,
                         ".pptx")
  )
  
) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
