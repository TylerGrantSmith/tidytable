#' Separate a character column into multiple columns
#'
#' @description
#' Separates a single column into multiple columns using a user supplied separator or regex.
#'
#' If a separator is not supplied one will be automatically detected.
#'
#' Note: Using automatic detection or regex will be slower than simple separators such as "," or ".".
#'
#' @param .data A data.frame or data.table
#' @param col The column to split into multiple columns
#' @param into New column names to split into. A character vector.
#' @param sep Separator to split on. Can be specified or detected automatically
#' @param remove If TRUE, remove the input column from the output data.table
#' @param ... Further argument to pass to data.table::tstrsplit
#'
#' @export
#'
#' @examples
#' test_df <- data.table::data.table(x = c("a", "a.b", "a.b", NA))
#'
#' # "sep" can be automatically detected (slower)
#' test_df %>%
#'   dt_separate(x, into = c("c1", "c2"))
#'
#' # Faster if "sep" is provided
#' test_df %>%
#'   dt_separate(x, into = c("c1", "c2"), sep = ".")
dt_separate <- function(.data, col, into,
                        sep = "[^[:alnum:]]+",
                        remove = TRUE,
                        ...) {
  UseMethod("dt_separate")
}

#' @export
dt_separate.data.frame <- function(.data, col, into,
                                   sep = "[^[:alnum:]]+",
                                   remove = TRUE,
                                   ...) {

  if (missing(col)) abort("col is missing and must be supplied")
  if (missing(into)) abort("into is missing and must be supplied")

  .data <- as_tidytable(.data)
  col <- enexpr(col)

  dt_separate(.data, col = !!col, into = into, sep = sep, remove = remove, ...)
}

#' @export
dt_separate.tidytable <- function(.data, col, into,
                                   sep = "[^[:alnum:]]+",
                                   remove = TRUE,
                                   ...) {

  .data <- shallow(.data)

  if (missing(col)) abort("col is missing and must be supplied")
  if (missing(into)) abort("into is missing and must be supplied")

  col <- enexpr(col)

  if (nchar(sep) > 1) {
    # Works automatically, but is slower
    eval_expr(
      .data[, (into) := tstrsplit(!!col, split = str_extract(!!col, sep), fixed=TRUE, ...)][]
    )
  } else {
    # Faster, but sep must be supplied
    eval_expr(
      .data[, (into) := tstrsplit(!!col, split = sep, fixed=TRUE, ...)][]
    )
  }

  if (remove) eval_expr(.data[, !!col := NULL][])

  .data
}
