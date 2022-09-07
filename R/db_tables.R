#' @export
db_tables <- function(file) {
  con = db_open(file)
  on.exit(dbDisconnect(con))
  dbListTables(con)
}
