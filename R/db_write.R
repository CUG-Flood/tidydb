#' Functions for writing data frames or delimiter-separated files to database tables.
#' 
#' @param conn file path
#' @param name  a character string specifying a table name. SQLite table names
#' are not case sensitive, e.g., table names ABC and abc are considered equal.
#' @param value `data.frame` or `list` object
#' @param overwrite a logical specifying whether to overwrite an existing table
#' or not. Its default is FALSE.
#' @param append
#' a logical specifying whether to append to an existing table in the DBMS.
#' Its default is FALSE.
#' @param close Boolean. Whether close db after write data.
#' @param others to [DBI::dbWriteTable()]
#' 
#' @example R/examples/ex-db_write.R
#' @seealso [DBI::dbWriteTable()]
#' @export
db_write <- function(conn, value, name = NULL, overwrite = FALSE, append = FALSE, close = TRUE, ...) {
  .name = deparse(substitute(value))

  conn %<>% db_open()
  if (close) on.exit(dbDisconnect(conn))
  if (is.data.frame(value)) {
    name %<>% `%||%`(.name)
    dbWriteTable(conn, name, value, overwrite = overwrite, append = append, ...)
  } else if (is.list(value)) {
    name %<>% `%||%`(names(value))
    for (i in seq_along(value)) {
      dbWriteTable(conn, name[i], value[[i]], overwrite = overwrite, append = append, ...)
    }
  }
}

write_sqlite <- db_write
