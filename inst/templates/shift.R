#' @description Helper functions for `data.table` workflows. The `shift`
#'   function is unclear about direction, so these functions wrap it
#'   and make the direction much more clear.

shift_forward <- function(x, n = 1L, fill, give.names = FALSE) {
  shift(x = x, n = n, fill = fill, type = "lag", give.names = give.names)
}

shift_backward <- function(x, n = 1L, fill, give.names = FALSE) {
  shift(x = x, n = n, fill = fill, type = "lead", give.names = give.names)
}
