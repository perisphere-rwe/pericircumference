
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

{{#include_report}}
  tar_render(
    {{{report_name}}},
    path = here::here("{{{report_dir}}}/{{{report_name}}}.Rmd"),
    output_file = paste0("{{{report_dir}}}", "-v", version_major, "/",
                         "{{{report_name}}}-", basename(here()),
                         "-v", version_major,
                         "-",  version_minor,
                         ".docx")
  ){{#include_slides}},{{/include_slides}}
{{/include_report}}
{{#include_slides}}
  tar_render(
    {{{slides_name}}},
    path = here::here("{{{slides_dir}}}/{{{slides_name}}}.Rmd"),
    output_file = paste0("{{{slides_dir}}}", "-v", version_major, "/",
                         "{{{slides_name}}}-", basename(here()),
                         "-v", version_major,
                         "-",  version_minor,
                         ".pptx")
  )
{{/include_slides}}

) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
