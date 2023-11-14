#' The relic cache directory
#'
#' Get the relic cache directory, which can be specified as either the R option
#' `relic.cache.dir` or the environment variable `RELIC_CACHE_DIR`. (The
#' environment variable has higher priority).  If neither
#' is set, the default is set by tools::R_user_dir("relic", "cache").
#' @export
#' @return The path to the relic cache directory
#' @examples
#' relic_cache()
relic_cache <- function() {
  Sys.getenv(
    "RELIC_CACHE_DIR",
    getOption("relic.cache.dir",
      default = tools::R_user_dir("relic", "cache")
    )
  )
}

#' @export
#' @rdname relic_cache
relic_cache_clear <- function() {
  dir_delete(relic_cache())
}


#' Wrappers to convert objects to git2r objects but allow git2r objects to pass though
#' @noRd
as_repo <- function(x) {
  if (inherits(x, "git_repository")) {
    x
  } else {
    repository(x)
  }
}

#' @rdname as_repo
#' @noRd
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
