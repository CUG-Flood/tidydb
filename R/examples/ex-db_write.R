## version1
con <- db_open()
db_write(con, mtcars, close=FALSE)
tbl(con, "mtcars")
db_close(con)

## version2
f_db = "hello.db"
if (file.exists(f_db)) file.remove(f_db)
db_write(f_db, mtcars)
tbl(f_db, "mtcars")
db_close()
file.remove(f_db)

## write list
f_db <- "hello2.db"
l = list(a = mtcars, b = mtcars)
db_write(f_db, l)
tbl(f_db, "a")
all(db_tables(f_db) == names(l))
db_close()
file.remove(f_db)
