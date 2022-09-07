#' open data.base
#' 
#' @inheritParams DBI::dbConnect
#' @param con A [DBI::dbConnect()] object or db path
#' 
#' @example R/examples/ex-db_write.R
#' 
#' @seealso [DBI::dbConnect()]
#' @import DBI
#' @export 
db_open <- function(con = ":memory:", ...) {
  # con = path
  if (is.null(con)) con = .options$con
  if (!("SQLiteConnection" %in% class(con)) && is.character(con)) {
    con <- DBI::dbConnect(RSQLite::SQLite(), dbname = con, ...)
  }
  con
}

#' @rdname db_open
#' @export
db_is_opened <- function(con) {
  ("SQLiteConnection" %in% class(con))
}

# also named as `sqlite_con`
sqlite_con <- db_open
db_sqlite <- db_open

#' @rdname db_open
#' @export
db_close <- function(con = NULL) {
  if (is.null(con)) con = .options$con
  if (!is.null(con)) {
    dbDisconnect(con)
    .options$con = NULL
  } else {
    message(sprintf("No dbConnect in backends."))
  }
  invisible()
}
