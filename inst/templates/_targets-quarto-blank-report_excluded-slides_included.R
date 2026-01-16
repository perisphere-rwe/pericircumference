
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
  
) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
