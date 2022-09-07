#' Functions for writing data frames or delimiter-separated files to database tables.
#'
#' @param conn file path
#' @param name  a character string specifying a table name. SQLite table names
#' are not case sensitive, e.g., table names ABC and abc are considered equal.
#' @param value a data.frame (or coercible to data.frame) object or a file
#' name (character). In the first case, the data.frame is written to a temporary
#' file and then imported to SQLite; when value is a character, it is interpreted
#' as a file name and its contents imported to SQLite.
#' @param overwrite a logical specifying whether to overwrite an existing table
#' or not. Its default is FALSE.
#' @param append
#' a logical specifying whether to append to an existing table in the DBMS.
#' Its default is FALSE.
#'
#' @export
db_write <- function(conn, value, name, overwrite = FALSE, append = FALSE) {
  conn %<>% db_open()
  on.exit(dbDisconnect(conn))
  dbWriteTable(conn, name, value, overwrite = overwrite, append = append)
}

write_sqlite <- db_write
