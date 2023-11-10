#' Read in files from git history
#'
#' Reads the contents of a file or files from a git repository into memory. If
#' the file does not exist, or is a directory, NULL will be returned.
#'
#' @param path A path or vector of paths of files and/or folders to extract,
#'   relative to the git directory
#' @param ref A git commit SHA, tag, branch or other [revision
#'   string](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions):
#'   such as "HEAD~1", or a [git2r::commit()] object. Defaults to "HEAD".
#' @param repo The path to the git repository or a [git2r::repository()] object.
#' @export
#' @rdname file_read_version
#' @return
#'   - For `file_read_version()`,  a list containing the file contents of each path, named by the path. Each will be a length-1 character vector, or raw vector for binary files.
#'   - For `file_read_versions()`,  a list list of lists, named by the commit SHA.
file_read_version <- function(path, ref = "HEAD", repo = ".") {
  contents <- lapply(path, \(x) file_read_version_single(x, ref, repo))
  names(contents) <- path
  contents
}

#' @export
#' @inheritParams commits_between
#' @rdname file_read_version
file_read_versions <- function(path, from = "HEAD", to = NULL, repo = ".") {
  commits <- commits_between(from, to, repo)
  versions <- lapply(commits, \(x) file_read_version(path, x, repo))
  names(versions) <- vapply(commits, sha, character(1))
  versions
}

file_read_version_single <- function(path, ref) {
  commit <- as_commit(ref, repo)
  obj <- get_obj_at_commit(path, commit)
  if (is_tree(obj) || is_empty(obj)) {
    return(NULL)
  } else if (is_blob(obj)) {
    return(read_blob(obj))
  } else {
    abort("Path is not a file or directory")
  }
}
