#' Read database tables
#' 
#' @inheritParams DBI::dbReadTable
#' @param conn A `DBIConnection` object, as returned by [db_open()] or
#' data.base path
#' 
#' @importFrom DBI dbWriteTable dbReadTable dbDisconnect
#' @export
db_read <- function(conn, tables, ...) {
  con <- db_open(conn)
  # on.exit(dbDisconnect(con))
  if (missing(tables)) tables <- dbListTables(con)[1]
  tables %<>% set_names(., .)

  ans <- lapply(tables, function(table) {
    dbReadTable(con, table, ...) %>% data.table()
  })
  if (length(tables) == 1) ans <- ans[[1]]
  ans
}

read_sqlite <- db_read
read_db <- db_read
