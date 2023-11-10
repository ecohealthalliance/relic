#' List files and folders in a git repository
#'
#' @inheritParams file_read_version
#' @param param all If TRUE hidden files are also returned
#' @param recurse If TRUE recurse fully, if a positive number the number of levels to recurse
#' @param type One or more of "any", "file", "directory", "symlink", or "submodule"
#' @param regexp A regular expression (e.g. ⁠[.]csv$⁠) passed on to grep() to filter paths.
#' @param glob A wildcard aka globbing pattern (e.g. ⁠*.csv⁠) passed on to grep() to filter paths
#' @param invert If TRUE, return paths that do not match the pattern or glob
#' @return A character vector of paths
#' @export
dir_ls_version <- function(path = ".", ref = "HEAD", all = FALSE, recurse = FALSE, type = "any", regexp = NULL, glob = NULL, repo = ".") {
  tree <- get_obj_at_commit(path, ref, repo)
  if (!is_tree(tree)) abort("Path is not a directory")
  if (!is.numeric(recurse)) recurse <- if (recurse) Inf else 0

  modelist <- list(
    file = c("100644", "100755"),
    directory = "040000",
    symlink = "120000",
    submodules = "160000"
  )
  modes <- if (type == "any") unlist(modelist) else unlist(modelist[type])

  paths <- dir_ls_recurse(tree, recurse, modes)

  if (!all) {
    paths <- path_filter(paths, regexp = "^[^\\.].*$")
  }
  paths <- path_filter(paths, glob = glob, regexp = regexp)
  paths
}

dir_ls_recurse <- function(tree, recurse, modes) {
  paths <- tree$name[sprintf("%06o", tree$filemode) %in% modes]
  if (recurse > 0) {
    dirs <- tree$name[tree$type == "tree"]
    if (!length(dirs)) {
      return(paths)
    }
    trees <- tree[tree$type == "tree"]
    if (is_tree(trees)) trees <- list(trees)
    new_paths <- lapply(trees, function(x) dir_ls_recurse(x, recurse - 1, modes))
    for (i in seq_along(dirs)) new_paths[[i]] <- path(dirs[i], new_paths[[i]])
    paths <- c(paths, unlist(new_paths))
  }
  path(paths)
}

#' @inheritParams commits_between
#' @export
#' @rdname dir_ls_version
dir_ls_versions <- function(path, from = "HEAD", to = NULL, all = FALSE, recurse = FALSE, type = "any", regexp = NULL, glob = NULL, repo = ".") {
  commits <- commits_between(from = from, to = to, repo = repo)
  versions <- list()
  for (i in seq_along(commits)) {
    versions[[i]] <- dir_ls_version(path, ref = commits[[i]], all = all, recurse = recurse, type = type, regexp = regexp, glob = glob, repo = repo)
  }
  names(versions) <- vapply(commits, sha, character(1))
  versions
}


## TODO make a dir_tree_version that prints
