# global options
.options <- list2env(list(
  con = NULL
))

set_con <- function(con) {
  if (!is.null(.options$con)) db_close(.options$con)
  .options$con <- db_open(con)
  .options$con
}
