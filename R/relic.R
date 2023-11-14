#' An internal S3 class of git objects with additional metadata
#' @param x an object
is_relic <- function(x) inherits(x, "relic") && !is.null(attr(x, "mode"))

#' @export
#' @noRd
relic <- function(x, ...) {
  UseMethod("relic")
}

relic.git_tree <- function(x, i, ...) {
  blob <- x[i]
  if (!is_blob(blob)) abort("Object is not a git blob")
  structure(
    blob,
    mode = if (is.integer(mode)) sprintf("%06o", mode) else mode,
    class = c("relic", "git_blob")
  )
}

relic.git_blob <- function(x, mode, ...) {
  structure(
    x,
    mode = if (is.integer(mode)) sprintf("%06o", mode) else mode,
    class = c("relic", "git_blob")
  )
}
