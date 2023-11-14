#' Read a target project's metadata from git history
#'
#' @export
#' @param ref A git commit SHA, tag, branch or other [revision
#'   string](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions):
#'   such as "HEAD~1", or a [git2r::commit()] object. Defaults to "HEAD".
#' @param store Path to the targets store within the project. Defaults to the current project's store.
#' @param repo The path to the git repository or a [git2r::repository()] object.
#' @param ... Arguments passed to [targets::tar_meta()]
tar_meta_version <- function(ref = "HEAD", ..., store = targets::tar_path_store(), repo = ".") {
  check_installed("targets")
  path_meta <- file_copy_version(path(store, "meta", "meta"), ref, repo = repo)
  meta <- targets::tar_meta(..., store = store)
  meta
}
