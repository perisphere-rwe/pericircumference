
create_output_directories <- function(results_version_major,
                                      dirs = c("{{{report_dir}}}", "{{{slides_dir}}}")) {

  for (d in dirs) {
    if (dir.exists(d)) {
      subdir <- paste0(d, "/", d, "-v", results_version_major)
      if (!dir.exists(subdir)) dir.create(subdir)
    }
  }

}
