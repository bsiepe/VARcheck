set.seed(42)

make_vd <- function(T = 50, p = 3, subjects = 1, with_sim = TRUE) {
  make_mat <- function() matrix(rnorm(T * p), T, p)
  if (subjects == 1) {
    emp <- make_mat()
    pred <- emp + matrix(rnorm(T * p, sd = 0.3), T, p)
    res <- emp - pred
    sim <- if (with_sim) make_mat() else NULL
  } else {
    emp <- replicate(subjects, make_mat(), simplify = FALSE)
    pred <- lapply(emp, \(m) m + matrix(rnorm(T * p, sd = 0.3), T, p))
    res <- Map(`-`, emp, pred)
    sim <- if (with_sim) replicate(subjects, make_mat(), simplify = FALSE) else NULL
  }
  new_var_data(emp, pred, res, sim, var_names = paste0("V", seq_len(p)))
}

test_that("returns a patchwork object", {
  expect_s3_class(plot_var_check(make_vd()), "patchwork")
})

test_that("vars selection by name works", {
  p <- plot_var_check(make_vd(), vars = c("V1", "V3"))
  expect_s3_class(p, "patchwork")
})

test_that("vars selection by index works", {
  p <- plot_var_check(make_vd(), vars = c(1L, 2L))
  expect_s3_class(p, "patchwork")
})

test_that("single variable works", {
  vd <- make_vd(p = 1)
  expect_s3_class(plot_var_check(vd, panels = c("data", "residuals")), "patchwork")
})

test_that("panels subset works", {
  vd <- make_vd()
  expect_s3_class(plot_var_check(vd, panels = c("data", "residuals")), "patchwork")
  expect_s3_class(plot_var_check(vd, panels = "scatter"), "patchwork")
})

test_that("multi-subject: subject selection works", {
  vd <- make_vd(subjects = 2)
  expect_s3_class(plot_var_check(vd, subject = 2), "patchwork")
})

test_that("ylim overrides are accepted", {
  p <- plot_var_check(make_vd(), ylim_data = c(-10, 10), ylim_res = c(-3, 3))
  expect_s3_class(p, "patchwork")
})

test_that("colors partial override merges with defaults", {
  p <- plot_var_check(make_vd(), colors = list(predicted = "steelblue"))
  expect_s3_class(p, "patchwork")
})

test_that("theme override is accepted", {
  p <- plot_var_check(
    make_vd(),
    theme = ggplot2::theme(text = ggplot2::element_text(size = 8))
  )
  expect_s3_class(p, "patchwork")
})

test_that("error when subject out of range", {
  expect_error(plot_var_check(make_vd(), subject = 99), "subject")
})

test_that("error on unknown variable name", {
  expect_error(plot_var_check(make_vd(), vars = "Z"), "Unknown variable")
})

test_that("error when simulated panel requested but data missing", {
  vd <- make_vd(with_sim = FALSE)
  expect_error(
    plot_var_check(vd, panels = c("data", "simulated")),
    "simulated"
  )
})

test_that("error when data is not var_data", {
  expect_error(plot_var_check(list(a = 1)), "var_data")
})
