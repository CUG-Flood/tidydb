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

db_merge <- function(...) {
  fs = list(...)
  lapply(fs, db_read) %>% do.call(rbind, .)
}

#' write_db
#'
#' @param con SQLite connection returned by [DBI::dbConnect()], or the file path of SQLite.
#' @param d data.frame or data.table object.
#' @inheritParams timeinfo
#' 
#' @export
write_db <- function(con, d, time,
                     table_data = "runoff_hourly", table_info = "timeinfo",
                     log = TRUE, check_time = TRUE,
                     overwrite = FALSE, append = TRUE, mink = 10) {
  file_log <- NULL
  if (is.character(con)) file_log <- gsub("\\..{1,6}$", ".log", con)

  con <- db_open(con)
  on.exit(db_close(con))

  if (nrow(d) < mink) {
    warning("too short records")
    print(d)
    return()
  }

  if (overwrite) append <- FALSE
  if (check_time && is_processed(con, time)) {
    fprintf("[ok] %s exist.\n", time)
    return()
  }

  info <- timeinfo(time)
  dbWriteTable(con, table_data, cbind(info[, .(timestr, timenum)], d),
    overwrite = overwrite, append = append
  )
  dbWriteTable(con, table_info, info, overwrite = overwrite, append = append)

  if (is.character(file_log)) {
    info_all <- read_sqlite(con, table_info)
    fwrite(info_all, file_log)
  }
}

#' @param mink minimum records
#'
#' @rdname write_db
#' @importFrom data.table fread
#' @export
write_db_char <- function(con, file, overwrite = FALSE, append = TRUE, mink = 10) {
  d <- fread(file)
  time <- guess_time(file)
  write_db(con, d, time, overwrite, append)
}

#' @rdname write_db
#' @export
#' @examples
#' # write_db_batch("chinawater.db", files)
write_db_batch <- function(dbname = "chinawater.db", files, overwrite = TRUE) {
  timeinfo <- guess_time(files) %>%
    timeinfo() %>%
    unique()
  runoff_hourly <- plyr::llply(files, db_parse_csv, .progress = "text") %>%
    do.call(rbind, .) %>%
    unique()

  con <- db_open(dbname)
  on.exit(db_close(con))

  lst <- listk(runoff_hourly, timeinfo)
  list2db(lst, con, overwrite = overwrite)
}
