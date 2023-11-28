#' Given a ref checks if it exists in the cache and returns the full SHA
#' @noRd
ref_in_cache <- function(ref) {
  if (!is_scalar_character(ref)) {
    abort("ref must be a single character string")
  }

  if (nchar(ref) < 4) {
    abort("ref must be at least 4 characters long")
  }

  sha_dirs <- path_file(dir_ls(cache_sha(), type = "directory", recurse = FALSE))
  sha_dirs <- sha_dirs[substr(sha_dirs, 1, nchar(ref)) == ref]

  if (length(sha_dirs) > 1) {
    abort("Ambiguous lookup: multiple matches found for ref ", ref, "in cache.")
  } else if (length(sha_dirs) == 0) {
    return(NA_character_)
  } else {
    return(sha_dirs)
  }
}

#' returns path to a file in the cache, and NA if it doesn't exist, vectorized.
#' Only works for files, not directories, which also return NA
#' @noRd
#'
path_in_cache <- function(path, ref) {
  ref <- ref_in_cache(ref)
  if (is.na(ref)) {
    return(rep(NA_character_, length(path)))
  }
  paths <- path(cache_sha(), ref, path)
  paths[!file_exists(paths) | is_dir(paths)] <- NA_character_

  paths
}
