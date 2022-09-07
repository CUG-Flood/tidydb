test_that("db_write works", {
  ## version1
  con <- db_open()
  db_write(con, mtcars, close=FALSE)
  d = tbl(con, "mtcars")
  expect_true(is.tbl(d))
  db_close(con)

  ## version2
  f_db = "hello.db"
  if (file.exists(f_db)) file.remove(f_db)
  db_write(f_db, mtcars)
  d = tbl(f_db, "mtcars")
  expect_true(is.tbl(d))
  db_close()
  file.remove(f_db)

  ## write list
  f_db <- "hello2.db"
  l = list(a = mtcars, b = mtcars)
  db_write(f_db, l)
  d = tbl(f_db, "a")
  expect_true(is.tbl(d))
  expect_true(all(db_tables(f_db) == names(l)))
  db_close()
  file.remove(f_db)
})
