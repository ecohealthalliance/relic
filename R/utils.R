#' Get system-level temporary directories and files
#'
#' Useful for files that should survive restarting R, but not resetting the
#' computer.  For instance, [`targets`](https://docs.ropensci.org/targets/) uses
#' a new session for each target built, so these paths will persist across the
#' entire build process.
#' @dev
sys_tempdir <- function() {
  path_dir(path_temp())
}

#' @dev
#' @param pattern A pattern to use for the temporary file name
#' @param ext An extension to use for the temporary file name
#' @rdname sys_tempdir
sys_tempfile <- function(pattern, ext = "") {
  file_temp(pattern = "file", tmp_dir = sys_tempdir(), ext = ext)
}

#' Wrappers to convert objects to git2r objects but allow git2r objects to pass though
#' @dev
as_repo <- function(x) {
  if (inherits(x, "git_repository")) {
    x
  } else {
    repository(x)
  }
}

#' @rdname as_repo
#' @dev
as_commit <- function(x, repo = ".") {
  if (is_commit(x)) {
    x
  } else if (is.character(x)) {
    repo <- as_repo(repo)
    revparse_single(repo, x)
  } else {
    commit(x)
  }
}

is_none <- function(x) length(x) == 0
