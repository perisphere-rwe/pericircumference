
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

  tar_target(report_file, "report.qmd", format = "file"),

  tar_target(report, command = {

    output_file <- paste0("report-", basename(here()),
                          "-v", results_version_major,
                          "-",  results_version_minor,
                          ".html")

    output_dir <- paste0("report", "-v", results_version_major)

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
