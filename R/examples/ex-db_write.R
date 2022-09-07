## example 01: write to memory
con <- db_open()
db_write(con, mtcars, close=FALSE)
d = tbl(con, "mtcars")
is.data.frame(db_read(con, close=FALSE))
db_close(con)

## example02: write to file
f_db = "hello1.db"
if (file.exists(f_db)) file.remove(f_db)
db_write(f_db, mtcars)
tbl(f_db, "mtcars")
db_close()

is.data.frame(db_read(f_db))
file.remove(f_db)

## example03: write list
f_db <- "hello2.db"
if (file.exists(f_db)) file.remove(f_db)
l = list(a = mtcars, b = mtcars)
db_write(f_db, l)
all(db_tables(f_db) == names(l))

d = tbl(f_db, "a")
db_close()

db_read(f_db)
db_read(f_db, close = FALSE)
db_close()

file.remove(f_db)
