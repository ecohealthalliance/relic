#' An internal S3 class of git objects with additional metadata

is_relic <- function(x) inherits(x, "relic") && !is.null(attr(x, "mode"))

#' @export
relic <- function(x, ...) {
  UseMethod("relic")
}

#' @export
relic.git_tree <- function(tree, i) {
  blob <- tree[i]
  if (!is_blob(blob)) abort("Object is not a git blob")
  structure(
    blob,
    mode = sprintf("%06o", tree$filemode[i]),
    class = c("relic", "git_blob")
  )
}

#' @export
relic.git_blob <- function(blob, mode) {
  structure(
    blob,
    mode = mode,
    class = c("relic", "git_blob")
  )
}
