
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
  tar_target({{{report_name}}}_file, "{{{report_name}}}.qmd", format = "file"),

  tar_target({{{report_name}}}, command = {

    output_file <- paste0("{{{report_name}}}-", basename(here()),
                          "-v", version_major,
                          "-",  version_minor,
                          ".html")

    output_dir <- paste0("{{{report_dir}}}", "-v", version_major)

    quarto_render(input = {{{report_name}}}_file, output_file = output_file)

    file_moved <- file.copy(from = output_file,
                            to = file.path("{{{report_dir}}}", output_dir, output_file),
                            overwrite = TRUE)

    if(file_moved){
      file.remove(output_file)
    } else {
      stop("could not copy {{{report_name}}} output. Check {{{report_name}}} target in _targets.R")
    }

    NULL

  }){{#include_slides}},{{/include_slides}}
{{/include_report}}
{{#include_slides}}
  tar_target({{{slides_name}}}_file, "{{{slides_name}}}.qmd", format = "file"),

  tar_target({{{slides_name}}}, command = {

    output_file <- paste0("{{{slides_name}}}-", basename(here()),
                          "-v", version_major,
                          "-",  version_minor,
                          ".html")

    output_dir <- paste0("{{{slides_dir}}}", "-v", version_major)

    quarto_render(input = {{{slides_name}}}_file, output_file = output_file)

    file_moved <- file.copy(from = output_file,
                            to = file.path("{{{slides_dir}}}", output_dir, output_file),
                            overwrite = TRUE)

    if(file_moved){
      file.remove(output_file)
    } else {
      stop("could not copy {{{slides_name}}} output. Check {{{slides_name}}} target in _targets.R")
    }

    NULL

  })
{{/include_slides}}

) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
