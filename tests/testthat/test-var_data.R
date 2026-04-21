rmat <- function(T = 50, p = 2) matrix(rnorm(T * p), T, p)

test_that("single matrix is coerced to length-1 list", {
  vd <- new_var_data(rmat(), rmat(), rmat())
  expect_s3_class(vd, "var_data")
  expect_equal(vd$n_subjects, 1L)
  expect_true(is.list(vd$empirical))
})

test_that("list input gives correct subject count", {
  vd <- new_var_data(list(rmat(), rmat()), list(rmat(), rmat()), list(rmat(), rmat()))
  expect_equal(vd$n_subjects, 2L)
  expect_equal(vd$n_vars, 2L)
})

test_that("var_names default to V1, V2, ...", {
  vd <- new_var_data(rmat(), rmat(), rmat())
  expect_equal(vd$var_names, c("V1", "V2"))
})

test_that("custom var_names are stored", {
  vd <- new_var_data(rmat(), rmat(), rmat(), var_names = c("A", "B"))
  expect_equal(vd$var_names, c("A", "B"))
})

test_that("simulated defaults to NULL", {
  vd <- new_var_data(rmat(), rmat(), rmat())
  expect_null(vd$simulated)
})

test_that("simulated is stored when provided", {
  vd <- new_var_data(rmat(), rmat(), rmat(), simulated = rmat())
  expect_length(vd$simulated, 1L)
})

test_that("wrong var_names length errors", {
  expect_error(
    new_var_data(rmat(), rmat(), rmat(), var_names = "X"),
    "var_names"
  )
})

test_that("mismatched column count in predicted errors", {
  expect_error(
    new_var_data(rmat(p = 2), rmat(p = 3), rmat(p = 2)),
    "dimensions"
  )
})

test_that("mismatched row count in residuals errors", {
  expect_error(
    new_var_data(rmat(T = 50), rmat(T = 50), rmat(T = 40)),
    "dimensions"
  )
})

test_that("mismatched subject count in simulated errors", {
  expect_error(
    new_var_data(
      list(rmat(), rmat()), list(rmat(), rmat()), list(rmat(), rmat()),
      simulated = list(rmat())
    ),
    "simulated"
  )
})

test_that("print method outputs var_data header", {
  vd <- new_var_data(rmat(), rmat(), rmat(), var_names = c("X", "Y"))
  expect_output(print(vd), "<var_data>")
  expect_output(print(vd), "X, Y")
})
