#' Read database tables
#' 
#' @inheritParams DBI::dbReadTable
#' @param con A `DBIConnection` object, as returned by [db_open()] or
#' data.base path
#' @param tables vector of dbTable names. If not specified, read the first table.
#' 
#' @importFrom DBI dbWriteTable dbReadTable dbDisconnect
#' @export
db_read <- function(con = NULL, tables = NULL, close = TRUE, ...) {
  con %<>% db_open()
  if (close) {
    on.exit(db_close(con))
  } else {
    set_con(con)
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
