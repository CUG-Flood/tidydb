#' @import RSQLite
#' @export
sqlite_con <- function(con) {
  if (!("SQLiteConnection" %in% class(con)) && is.character(con)) {
    con <- dbConnect(dbDriver("SQLite"), dbname = con)
  }
  con
}

#' Functions for writing data frames or delimiter-separated files to database tables.
#'
#' @param file file path
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
write_sqlite <- function(file, name, value, overwrite = FALSE, append = FALSE) {
  # con <- dbConnect(SQLite(), file)
  con <- sqlite_con(file)
  on.exit(dbDisconnect(con))

  dbWriteTable(con, name, value, overwrite = overwrite, append = append)
}

#' @rdname write_sqlite
#' @export
read_sqlite <- function(file, name) {
  con <- sqlite_con(file)
  # on.exit(dbDisconnect(con))

  if (missing(name)) {
    names <- dbListTables(con)
    name <- names[1]
  }
  dbReadTable(con, name) %>% data.table()
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

  con <- sqlite_con(con)
  on.exit(dbDisconnect(con))

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
  runoff_hourly <- plyr::llply(files, read_csv, .progress = "text") %>%
    do.call(rbind, .) %>%
    unique()

  con <- db_sqlite(dbname)
  on.exit(dbDisconnect(con))

  lst <- listk(runoff_hourly, timeinfo)
  list2db(lst, con, overwrite = overwrite)
}

#' @rdname write_db
#' @export
read_db <- function(dbname, tables = NULL) {
  con <- dbConnect(dbDriver("SQLite"), dbname = dbname)
  on.exit(dbDisconnect(con))

  if (is.null(tables)) tables <- dbListTables(con)
  tables %<>% set_names(., .)
  ans <- lapply(tables, function(table) {
    dbReadTable(con, table) %>% data.table()
  })
  if (length(tables) == 1) ans <- ans[[1]]
  ans
}

#' @export
db_tables <- function(file) {
  con <- dbConnect(dbDriver("SQLite"), dbname = file)
  on.exit(dbDisconnect(con))
  dbListTables(con)
}
