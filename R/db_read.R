#' Read database tables
#'
#' @inheritParams DBI::dbReadTable
#' @param src A `DBIConnection` (dbi) object, as returned by [db_open()] or
#' data.base `path`
#' - `dbi`: not close after reading (default)
#' - `path`: close after reading (default)
#' @param tables vector of dbTable names. If not specified, read the first table.
#' @param close Boolean. Whether close connection after read.
#' - `opened`: not close
#' - `not opened`: close
#' 
#' @importFrom DBI dbWriteTable dbReadTable dbDisconnect
#' @export
db_read <- function(src = NULL, tables = NULL, close = !is.dbi(src), ...) {
  con = db_open(src)
  if (close) {
    on.exit(db_close(con))
  } else {
    if (!is.dbi(src) && !close) set_con(con)
  }
  
  if (is.null(tables)) tables <- dbListTables(con)[1]
  tables %<>% set_names(., .)

  ans <- lapply(tables, function(table) {
    dbReadTable(con, table, ...) %>% data.table()
  })
  if (length(tables) == 1) ans <- ans[[1]]
  ans
}

read_sqlite <- db_read
read_db <- db_read


#' @export
tbl.character <- function(src, ...) {
  con <- set_con(src)
  tbl(con, ...)
}
