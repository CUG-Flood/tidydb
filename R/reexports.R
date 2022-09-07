#' @importFrom lubridate year month day hour
#' @export 
lubridate::year

#' @export
lubridate::month

#' @export
lubridate::day

#' @export
lubridate::hour


#' @importFrom data.table data.table fread fwrite
#' @export
data.table::fread

#' @export
data.table::fwrite

#' @export
data.table::data.table


#' @importFrom stringr str_extract
#' @export
stringr::str_extract


#' @importFrom dplyr tbl
#' @export
dplyr::tbl

#' @export
tbl.character <- function(src, ...) {
  .options$con <- db_open(src)
  tbl(.options$con, ...)
}
