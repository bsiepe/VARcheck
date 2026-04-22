.coerce_to_list <- function(x, name) {
  if (is.matrix(x)) {
    list(x)
  } else if (is.list(x) && all(vapply(x, is.matrix, logical(1)))) {
    x
  } else {
    stop(
      "`", name, "` must be a numeric matrix or a list of numeric matrices.",
      call. = FALSE
    )
  }
}

.validate_var_data <- function(x) {
  n_subj <- length(x$empirical)
  n_vars <- ncol(x$empirical[[1]])

  for (comp in c("predicted", "residuals")) {
    m <- x[[comp]]
    if (length(m) != n_subj) {
      stop(
        "`", comp, "` must have the same number of subjects as `empirical`.",
        call. = FALSE
      )
    }
    for (i in seq_len(n_subj)) {
      if (ncol(m[[i]]) != n_vars || nrow(m[[i]]) != nrow(x$empirical[[i]])) {
        stop(
          "`", comp, "` subject ", i,
          " has different dimensions than `empirical`.",
          call. = FALSE
        )
      }
    }
  }

  if (!is.null(x$simulated)) {
    m <- x$simulated
    if (length(m) != n_subj) {
      stop(
        "`simulated` must have the same number of subjects as `empirical`.",
        call. = FALSE
      )
    }
    for (i in seq_len(n_subj)) {
      if (ncol(m[[i]]) != n_vars || nrow(m[[i]]) != nrow(x$empirical[[i]])) {
        stop(
          "`simulated` subject ", i,
          " has different dimensions than `empirical`.",
          call. = FALSE
        )
      }
    }
  }

  invisible(x)
}

#' Create a VAR data object
#'
#' Constructs a `var_data` object used as input to [plot_var_check()].
#' Each component is either a single `T x p` numeric matrix (single subject)
#' or a list of `T_i x p` matrices (multiple subjects). Single matrices are
#' coerced to a length-1 list automatically.
#'
#' @param empirical Numeric matrix or list of matrices. Observed values.
#' @param predicted Numeric matrix or list of matrices. Model predictions.
#' @param residuals Numeric matrix or list of matrices. Residuals
#'   (`empirical - predicted`).
#' @param simulated Optional numeric matrix or list of matrices. Data
#'   simulated from the fitted model. Required only when plotting the
#'   `"simulated"` panel.
#' @param var_names Optional character vector of length `p` with variable
#'   names used as plot labels. Defaults to `"V1"`, `"V2"`, etc.
#'
#' @return An object of class `var_data`.
#' @export
#'
#' @examples
#' set.seed(1)
#' emp <- matrix(rnorm(200), nrow = 100, ncol = 2)
#' pred <- emp + matrix(rnorm(200, sd = 0.3), 100, 2)
#' res <- emp - pred
#' sim <- matrix(rnorm(200), 100, 2)
#' vd <- new_var_data(emp, pred, res, sim, var_names = c("Mood", "Energy"))
new_var_data <- function(
    empirical,
    predicted,
    residuals,
    simulated = NULL,
    var_names = NULL) {
  empirical <- .coerce_to_list(empirical, "empirical")
  predicted <- .coerce_to_list(predicted, "predicted")
  residuals <- .coerce_to_list(residuals, "residuals")
  if (!is.null(simulated)) simulated <- .coerce_to_list(simulated, "simulated")

  n_vars <- ncol(empirical[[1]])

  if (is.null(var_names)) {
    var_names <- paste0("V", seq_len(n_vars))
  } else if (length(var_names) != n_vars) {
    stop(
      "`var_names` must have length equal to the number of variables (",
      n_vars, ").",
      call. = FALSE
    )
  }

  out <- structure(
    list(
      empirical = empirical,
      predicted = predicted,
      residuals = residuals,
      simulated = simulated,
      var_names = var_names,
      n_subjects = length(empirical),
      n_vars = n_vars
    ),
    class = "var_data"
  )

  .validate_var_data(out)
  out
}

#' @rdname new_var_data
#' @param x A `var_data` object.
#' @param ... Not used; present for S3 method compatibility.
#' @export
print.var_data <- function(x, ...) {
  n_tp <- vapply(x$empirical, nrow, integer(1))
  tp_str <- if (length(unique(n_tp)) == 1) {
    as.character(n_tp[[1]])
  } else {
    paste0(min(n_tp), "\u2013", max(n_tp))
  }
  comps <- c("empirical", "predicted", "residuals")
  if (!is.null(x$simulated)) comps <- c(comps, "simulated")

  cat("<var_data>\n")
  cat("  Subjects  :", x$n_subjects, "\n")
  cat("  Variables :", x$n_vars, "(", paste(x$var_names, collapse = ", "), ")\n")
  cat("  Time pts  :", tp_str, "\n")
  cat("  Components:", paste(comps, collapse = ", "), "\n")
  invisible(x)
}
