#' @description Connect to Market Clarity data. By default, connects to a
#'   local "mini" DuckDB database built from a shared folder of parquet
#'   snapshots. Set `use_mini_db = FALSE` to connect to the full Market
#'   Clarity Databricks cluster instead.

connect_to_db <- function(use_mini_db = TRUE,
                          fpath_mini_db = NULL){

  if(use_mini_db){

    fpath_mini_db <- fpath_mini_db %||%
      "/userdata/cfor/databases/Perishpere_Market_Clarity/databricks/random_sample"

    con_mini_db <- dbConnect(duckdb())
    # after making a duckdb connection, create a local database that
    # contains the tables in our shared file space
    tbl_names_mini_db <- list.files(fpath_mini_db,
                                    pattern = '\\.parquet',
                                    full.names = FALSE) %>%
      str_remove('\\.parquet')

    # this creates a view of each table stored in our shared file space
    # for your mini database. You need to have a view of a table in order
    # to run SQL queries on it. We don't have to save the output of this
    # code because we are just running it for its side effects on the
    # duckdb connection
    list.files(fpath_mini_db,
               pattern = '\\.parquet',
               full.names = TRUE) %>%
      set_names(tbl_names_mini_db) %>%
      iwalk(.f = ~ {
        dbExecute(con_mini_db,
                  glue("CREATE VIEW {.y} AS SELECT * from read_parquet('{.x}')"))
      })

    return(con_mini_db)

  }

  if (getRversion() >= "4.5.2") {

    spark_connect(
      cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
      method = "databricks_connect",
      version = Sys.getenv("DATABRICKS_VERSION"),
      envname = Sys.getenv("DATABRICKS_PYTHON_ENV")
    )

  } else {

    spark_connect(
      cluster_id = Sys.getenv("DATABRICKS_CLUSTER_ID"),
      method = "databricks_connect",
      version = Sys.getenv("DATABRICKS_VERSION")
    )

  }

}
