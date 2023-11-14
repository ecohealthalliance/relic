#' Copy files from git history
#'
#' Copy files from git history to disk. Directories are copied recursively.
#'
#' The default behavior is to copy the file to a cache directory named after
#' both the commit and and the file path. These paths are universally unique,
#' so if `use_cache = TRUE`, the file will not be re-copied if it already exists
#' at that path.
#'
#' @inheritParams file_read_version
#' @param name the name to give the file when it is copied to disk. Defaults to
#'   the original name of the file or directory.
#' @param dir The path to the directory where the file should be copied.
#'   Defaults to a system-level temporary directory named after the SHA of the
#'   git commit. Will be created if does not exist.
#' @param full_name If TRUE, the file will be written to the full relative path
#'   of its location in the git repository, below `dir`. Defaults to TRUE if
#'   both `name` and `dir` are NULL, FALSE otherwise.
#' @param recurse If `path` is a directory, should should it be copied recursively? If
#'   numeric, how many levels deep should it be copied? Defaults to TRUE.
#' @param use_cache Should the cache be used? Defaults to TRUE.
#' @return
#'   - For `file_copy_version()`, A character vector of paths to the copied files or directories.
#'   - For `file_copy_versions()`, a list of character vectors of paths.
#'   Where files do not exist in a commit, `NA` values are returned.
#' @export
file_copy_version <- function(path, ref = "HEAD", name = NULL, dir = NULL, full_name = NULL, recurse = TRUE, repo = ".", use_cache = TRUE) {
  path(vapply(path, \(x) file_copy_version_single(x, ref, name, dir, full_name, recurse, repo, use_cache), character(1)))
}

#' @inheritParams commits_between
#' @export
#' @rdname file_copy_version
file_copy_versions <- function(path, from = "HEAD", to = NULL, name = NULL, dir = NULL, full_name = NULL, recurse = TRUE, repo = ".", use_cache = TRUE) {
  commits <- commits_between(from = from, to = to, repo = repo)
  versions <- lapply(commits, \(x) file_copy_version(path, x, name, dir, full_name, recurse, repo, use_cache))
  names(versions) <- vapply(commits, sha, character(1))
  versions
}

file_copy_version_single <- function(path, ref, name, dir, full_name, recurse, repo, use_cache) {
  commit <- as_commit(ref, repo)

  if (is.null(full_name)) full_name <- is.null(name) && is.null(dir)
  if (is.null(name)) name <- path_file(path)
  if (is.null(dir)) dir <- path(relic_cache(), sha(commit))
  if (full_name) dir <- path(dir, path_dir(path))

  out_path <- path_norm(path(dir, name))

  obj <- get_obj_at_commit(path, commit)
  if (is_none(obj)) {
    return(NA_character_)
  }

  if (is_tree(obj)) {
    dir_create(out_path)
    return(file_copy_recursive(obj, out_path, recurse, repo, use_cache))
  } else if (is_blob(obj)) {
    if (!file_exists(out_path) || !use_cache) {
      blob_to_file(obj, out_path, attr(obj, "mode"))
    }
  } else {
    abort("Path is not a file or directory")
  }

  out_path
}

file_copy_recursive <- function(obj, dir, recurse, repo, use_cache) {
  if (!is.numeric(recurse)) recurse <- if (recurse) Inf else 0

  if (recurse > 0) {
    for (i in seq_along(obj)) {
      obj_i <- obj[i]
      name_i <- obj$name[i]
      path_i <- path(dir, name_i)
      if (inherits(obj_i, "git_tree")) {
        dir_create(path_i)
        file_copy_recursive(obj_i, dir = path_i, recurse = recurse - 1)
      } else if (inherits(obj_i, "git_blob")) {
        if (!file_exists(path_i) || !use_cache) {
        blob_to_file(obj_i, path_i)
        }
      } else {
        abort("Object is not a git blob or tree")
      }
    }
  }
  dir
}
