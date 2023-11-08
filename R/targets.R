#' Get a target from a given git reference
#'
#' @param name The name of the target
#' @param ref The git reference: tag, branch, SHA, or revision like HEAD~1 (see https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions)
#' @param ... Additional arguments passed to \code{\link{tar_load}} or  \code{\link{tar_read}}
#' @export
tar_load_version <- function(name, ref = "HEAD", envir = parent.frame(),  ..., repo = ".") {
  name <- targets::tar_deparse_language(substitute(name))
  tmp_store <- make_temporary_store(ref, repo)
  tar_load(name, store = tmp_store, envir = envir, ...)
}

#' @export
#' @rdname tar_load_version
tar_read_version <- function(name, ref = "HEAD", repo = ".", ...) {
  name <- targets::tar_deparse_language(substitute(name))
  tmp_store <- make_temporary_store(ref, repo)
  tar_read_raw(name, store = tmp_store, ...)
}

make_temporary_store <- function(ref = "HEAD", repo = ".", store = targets::tar_path_store()) {

  current_store <- store
  store_git_obj <- get_git_obj_at_reference(path = fs::path(current_store), ref = ref, repo = repo)
  tmp_store_path <- fs::path(tar_tempdir(), sha(store_git_obj))

  # Don't bother copying if the store is already in the tempdir
  if(fs::dir_exists(tmp_store_path)) {
    return(tmp_store_path)
  } else {
    tmp_store <- copy_git_tree(store_git_obj, dirname = sha(store_git_obj), path = tar_tempdir())
  }

  tmp_store
}
