
create_output_directories <- function(results_version_major){

  if(dir.exists('report')){
    if(!dir.exists(glue("report/report-v{results_version_major}"))){
      dir.create(glue("report/report-v{results_version_major}"))
    }
  }


  if(dir.exists('slides')){
    if(!dir.exists(glue("slides/slides-v{results_version_major}"))){
      dir.create(glue("slides/slides-v{results_version_major}"))
    }
  }

}
