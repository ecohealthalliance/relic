#' The relic cache
#'
#' @description The relic cache directory stores files that have been retrieved
#' from both local and remote repositories to avoid repeated extractions or
#' downloads. Its location can be set with the environment variable
#' `RELIC_CACHE_DIR` or `options("relic.cache.dir")`, and it defaults to the
#' user cache directory.  The cache is cleaned up regularly at package startup,
#' but can also be cleaned up manually with `relic_cache_cleanup()` or cleared
#' entirely with `relic_cache_delete()`.
#' @export
#' @return The path to the relic cache directory
#' @examples
#' relic_cache()
relic_cache <- function() {
  dir_create(path_tidy(Sys.getenv(
    "RELIC_CACHE_DIR",
    getOption("relic.cache.dir",
      default = tools::R_user_dir("relic", "cache")
    )
  )))
}

#' @export
#' @rdname relic_cache
relic_cache_delete <- function() {
  dir_delete(relic_cache())
}

#' @param max_age The maximum age of files to keep in the cache, as a [difftime][base::difftime()]
#'   object.  Files older than this will be deleted.  Defaults to `Inf`. Can be
#'   set with the environment variable `RELIC_CACHE_MAX_AGE` or
#'   `options("relic.cache.max.age")`, which take numeric time in days or a
#'   string with units, e.g., "1 day" or "2 weeks".
#' @param max_size The maximum size of the cache, as a string that can be parsed
#'   by [fs::fs_bytes()].  Defaults to "20 MB".  Can be set with the environment
#'   variable `RELIC_CACHE_MAX_SIZE` or `options("relic.cache.max.size")`.
#'   Cached files will be deleted from oldest to youngest until the cache size
#'   is under this limit.
#' @export
#' @rdname relic_cache
relic_cache_cleanup <- function(max_age = relic_cache_max_age(), max_size = relic_cache_max_size()) {
  cache_all <- dir_info(relic_cache(), recurse = TRUE, include_dirs = TRUE, all = TRUE)
  min_age <- Sys.time() - max_age
  file_delete(cache_all[cache_all$modification_time < min_age, ]$path)
  cache_all <- cache_all[cache_all$modification_time >= min_age, ]

  # Delete oldest files up until size is under max size
  cache_files <- cache_all[cache_all$type %in% c("file"), ]
  file_delete(cache_files[cumsum(cache_files$size) > max_size, ]$path)

  # Delete any symlinks that point to non-existent files
  file_delete(cache_all[cache_all$type == "symlink" & !file_exists(cache_all$path), ]$path)

  # Delete empty directories recursively, by checking if their path is found in the path of any files
  cache_dirs <- cache_all[cache_all$type %in% c("directory"), ]
  for (dir in cache_dirs$path) {
    if (dir_exists(dir) && !length(dir_ls(dir, all = TRUE))) {
      dir_delete(dir)
    }
  }
  # Delete any symlinks that point to non-existent files again to get rid of directories
  file_delete(cache_all[cache_all$type == "symlink" & !file_exists(cache_all$path), ]$path)
}

#' @param cleanup_time The time between cache cleanups, as a [difftime][base::difftime()] object.
#'   Defaults to 1 day. Can be set with the environment variable
#'   `RELIC_CACHE_CLEANUP_TIME` or `options("relic.cache.cleanup.time")`, which
#'   take numeric time in days or a string with units, e.g., "1 day" or "2
#'   weeks".  If set to "Inf", no cleanup will be performed at startup.
#' @export
#' @rdname relic_cache
relic_cache_regular_cleanup <- function(cleanup_time = relic_cache_cleanup_time()) {
  cache_timestamp_file <- path(path_package("relic"), "cache_timestamp.rds")
  if (!file_exists(cache_timestamp_file) ||
    readRDS(cache_timestamp_file) < (Sys.time() - cleanup_time)) {
    relic_cache_cleanup()
  }
  saveRDS(Sys.time(), cache_timestamp_file)
}

#' @export
#' @rdname relic_cache
relic_cache_max_size <- function() {
  fs_bytes(Sys.getenv(
    "RELIC_CACHE_MAX_SIZE",
    getOption("relic.cache.max.size",
      default = "20 MB"
    )
  ))
}

#' @export
#' @rdname relic_cache
relic_cache_max_age <- function() {
  parse_age(Sys.getenv(
    "RELIC_CACHE_MAX_AGE",
    getOption("relic.cache.max.age",
      default = Inf
    )
  ))
}

#' @export
#' @rdname relic_cache
relic_cache_cleanup_time <- function() {
  parse_age(Sys.getenv(
    "RELIC_CACHE_CLEANUP_TIME",
    getOption("relic.cache.cleanup.time",
      default = 1
    )
  ))
}

parse_bool <- function(x) {
  if (is.logical(x)) {
    out <- x
  } else if (is.numeric(x)) {
    out <- (x != 0)
  } else if (is.character(x)) {
    x <- tolower(x)
    if (x %in% c("true", "t", "yes", "y", "1")) {
      out <- TRUE
    } else if (x %in% c("false", "f", "no", "n", "0")) {
      out <- FALSE
    }
  } else {
    abort("Invalid boolean value: ", x)
  }
  out
}


# nolint start: cyclocomp_linter
parse_age <- function(x) {
  if (is.na(x) || is.null(x) || !length(x) || !nzchar(x) || x == "Inf" || is.infinite(x)) { # nolint
    return(as.difftime(Inf, units = "days"))
  } else if (is.numeric(x)) {
    return(as.difftime(x, units = "days"))
  }
  x <- strsplit(x, "\\s")[[1]]
  units <- if (is.na(x[2])) "days" else x[2]
  as.difftime(as.numeric(x[1]), units = units)
}
# nolint end

cache_sha <- function() {
  path(dir_create(relic_cache(), "sha"))
}

cache_git <- function() {
  path(dir_create(relic_cache(), "git"))
}

cache_gh <- function() {
  path(dir_create(relic_cache(), "gh"))
}

cache_s3 <- function() {
  path(dir_create(relic_cache(), "s3"))
}


relic_git_cache_path <- function(relic) {
  path(relic_cache(), relic@commit$sha, relic@path)
}
