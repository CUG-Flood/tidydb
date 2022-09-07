# In the db, column name is `timestr`.

#' @export
is_processed <- function(con, time) {
  if (!("SQLiteConnection" %in% class(con)) && is.character(con)) {
    con <- dbConnect(dbDriver("SQLite"), dbname = con)
    on.exit(dbDisconnect(con))
  }
  if (!is.character(time)) time <- time2str(time)

  tryCatch({
    rs <- dbSendQuery(con, glue("SELECT * FROM timeinfo WHERE timestr = '{time}'"))
    on.exit(dbClearResult(rs))
    nrow(dbFetch(rs)) > 0
  }, error = function(e) {
    message(sprintf("%s", e$message))
    FALSE
  })
}

db_parse_csv <- function(file) {
  timeinfo <- guess_time(file) %>% timeinfo()
  cbind(timeinfo[, .(timestr, timenum)], fread(file))
}

db_merge <- function(db1, db2) {
  l1 <- read_db(db1)
  l2 <- read_db(db2)
}

#' @export
db_writeList <- function(lst, con, overwrite = TRUE) {
  append <- !overwrite
  if (is.character(con)) {
    con <- db_sqlite(con)
    on.exit(dbDisconnect(con))
  }

  names <- names(lst)
  for (i in seq_along(lst)) {
    dbWriteTable(con, names[i], lst[[i]], overwrite = overwrite, append = append)
  }
}

list2db <- db_writeList
