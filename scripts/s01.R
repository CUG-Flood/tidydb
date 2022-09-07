source('scripts/main_pkgs.R')

fdata = "C:/Users/kongdd/OneDrive/CUG-Hydro/ChinaData/mete2000/mete2000_complete_2022-week24_[2022061100,2022061611].csv"
df = fread(fdata)


{
  ## version1
  f <- "hello1.db"
  con <- db_open(f)
  # copy_to(con, df, "df")
  RSQLite::dbDisconnect(con)

  db_ReadTable(f, "df")
}

{
  f = "hello2.db"
  # file.remove(f)
  db_write(f, df, "df")
  # db_close(con)
  tbl(con, "df")
  # db_close(con)
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

db_close(con)

db_ReadTable(f)
db_tables(f)
