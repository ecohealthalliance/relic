#' Check if a target exists in a version of the pipeline
#'
#' @inheritParams tar_read_version
#' @export
tar_exists_version <- function(name, ref = "HEAD", branches = NULL, repo = ".", store = targets::tar_path_store()) {
  check_installed("targets")
  name <- targets::tar_deparse_language(substitute(name))
  tar_exists_version_raw(name, ref, branches, repo, store)
}

#' @export
#' @rdname tar_exists_version
tar_exists_version_raw <- function(name, ref = "HEAD", branches = NULL, repo = ".", store = targets::tar_path_store()) {
  check_installed("targets")
  repo <- as_repo(repo)
  ref <- as_commit(ref, repo)
  path_store <- file_copy_version(store, ref, repo = repo, recurse = FALSE)
  meta <- tar_meta_version(ref = ref, store = path_store)
  target_meta <- meta[meta$name == name, ]
  if (!nrow(target_meta)) {
    return(FALSE)
  }
  TRUE
}
