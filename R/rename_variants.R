#' Rename a selection of variables
#'
#' @description
#' These scoped variants of `rename()` operate on a selection of variables
#'
#' There are two variants:
#'
#' * `dt_rename_all()`
#' * `dt_rename_across()`: Replaces both `dt_rename_if()` & `dt_rename_at()`
#'
#' Supports enhanced selection
#'
#'
#' @param .data A data.frame or data.table
#' @param .cols vector `c()` of bare column names for `dt_rename_across()` to use
#' @param .vars vector `c()` of bare column names for `dt_rename_at()` to use
#' @param .predicate Predicate to pass to `dt_rename_if()`
#' @param .fun Function to pass
#' @param ... Other arguments for the passed function
#'
#' @md
#' @export
#'
#' @examples
#' example_dt <- data.table::data.table(
#'   x = 1,
#'   y = 2,
#'   double_x = 2,
#'   double_y = 4)
#'
#' as_dt(example_dt) %>% dt_rename_all(~ sub("x", "stuff", .x))
#'
#' as_dt(example_dt) %>%
#'   dt_rename_across(c(x, double_x), ~ sub("x", "stuff", .x))
dt_rename_all <- function(.data, .fun, ...) {
  UseMethod("dt_rename_all")
}

#' @export
dt_rename_all.default <- function(.data, .fun, ...) {

  dt_rename_across(.data, dt_everything(), .fun, ...)
}

#' @export
#' @rdname dt_rename_all
dt_rename_at <- function(.data, .vars, .fun, ...) {
  UseMethod("dt_rename_at")
}

#' @export
dt_rename_at.default <- function(.data, .vars, .fun, ...) {

  .vars <- enexpr(.vars)

  dt_rename_across(.data, !!.vars, .fun, ...)
}

#' @export
#' @rdname dt_rename_all
dt_rename_across <- function(.data, .cols, .fun, ...) {
  UseMethod("dt_rename_across")
}

#' @export
dt_rename_across.tidytable <- function(.data, .cols, .fun, ...) {

  .cols <- enexpr(.cols)
  .cols <- vec_selector(.data, !!.cols) %>%
    as.character()

  .data <- shallow(.data)

  .fun <- anon_x(.fun)

  #TODO Make this work without a loop

  if (length(.cols) > 0) {
    for (old_name in .cols) {
      new_name <- .fun(old_name, ...)
      setnames(.data, old_name, new_name)
    }
    .data
  } else {
    .data
  }
}

#' @export
dt_rename_across.data.frame <- function(.data, .cols, .fun, ...) {
  .data <- as_tidytable(.data)
  .cols <- enexpr(.cols)

  dt_rename_across(.data, .cols = !!.cols, .fun = .fun, ...)
}

#' @export
#' @rdname dt_rename_all
dt_rename_if <- function(.data, .predicate, .fun, ...) {
  UseMethod("dt_rename_if")
}

#' @export
dt_rename_if.default <- function(.data, .predicate, .fun, ...) {

  .predicate <- enexpr(.predicate)

  dt_rename_across(.data, !!.predicate, .fun, ...)

}
