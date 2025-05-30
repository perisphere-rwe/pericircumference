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

  tar_target(results_file, "results.qmd", format = 'file'),

  tar_target(results, command = {

    output_file <- paste0("results-", basename(here()),
                          "-v", results_version_major,
                          "-",  results_version_minor,
                          ".html")

    output_dir <- paste0("results", "-v", results_version_major)

    quarto_render(input = results_file, output_file = output_file)

    file_moved <- file.copy(from = output_file,
                            to = file.path('doc', output_dir, output_file),
                            overwrite = TRUE)

    if(file_moved){
      file.remove(output_file)
    } else {
      stop(
        "could not copy results output. Check results target in _targets.R"
      )
    }

    NULL

  })

) %>%
  tar_hook_before(
    hook = {source("conflicts.R")},
    names = everything()
  )
