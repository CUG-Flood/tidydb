#' open data.base
#' 
#' @inheritParams DBI::dbConnect
#' 
#' @seealso [DBI::dbConnect()]
#' 
#' @examples 
#' library(dplyr)
#' con <- db_open()
#' DBI::dbWriteTable(con, "mtcars", mtcars)
#' tbl(con, "mtcars")
#' 
#' @import DBI
#' @export 
db_open <- function(con = ":memory:", ...) {
  # con = path
  if (!("SQLiteConnection" %in% class(con)) && is.character(con)) {
    con <- DBI::dbConnect(RSQLite::SQLite(), dbname = con, ...)
  }
  con
}

# also named as `sqlite_con`
sqlite_con <- db_open
db_sqlite <- db_open

#' @rdname db_open
#' @export
db_close <- function(con = NULL) {
  if (is.null(con)) con = .options$con
  dbDisconnect(con)
}
