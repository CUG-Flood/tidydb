source('scripts/main_pkgs.R')

fdata = "C:/Users/kongdd/OneDrive/CUG-Hydro/ChinaData/mete2000/mete2000_complete_2022-week24_[2022061100,2022061611].csv"

{
  f = "hello2.db"
  file_rm(f)
  db_write(f, df)
  system.time(tbl(f, "df"))
}

{
  ## version1
  df = fread(fdata)

  f <- "hello2.db"
  file_rm(f)  

  con <- db_open(f)
  copy_to(con, df, "df", temporary = FALSE) # this parameter `temporary` matters
  db_close(con)
  system.time(tbl(f, "df"))
}

system.time(df <- fread(fdata))
system.time({
  con <- db_open(f)
  d = tbl(con, "df")
  dat = d %>%
    filter(Station_Id_C == 50136L) %>%
    collect()
  db_close(con)
})



library(dplyr)
{
  file.remove("flights_index.db")
  file.remove("flights_slow.db")

  ## version 1: without index
  con <- db_open("flights_index.db")
  copy_to(con, nycflights13::flights, "flights",
    temporary = FALSE,
    indexes = list("year", "month", "day")) # "carrier", "tailnum", "dest"
  db_close(con)

  ## version 2: no index
  con <- db_open("flights_slow.db")
  copy_to(con, nycflights13::flights, "flights", temporary = FALSE)
  db_close(con)
}

system.time({
  d <- tbl("flights_slow.db", "flights") %>%
    filter(month == 9) %>%
    collect()
})
system.time({
  d <- tbl("flights_index.db", "flights") %>%
    filter(month == 13) %>%
    collect()
})
db_close()
