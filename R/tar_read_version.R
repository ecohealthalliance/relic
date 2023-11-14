#' Read a target's value from a git repository
#'
#' Reads the content of targets from a git repository. Target metadata and
#' local target files are extracted into a temporary directory before being
#' read in by `tar_read()`. For targets of type "file", the files are also
#' extracted and the paths to the extracted files are returned.
#'
#' For cloud targets, the target metadata is read from git history and then
#' this metadata is used to download the target from the cloud. For this to work,
#' cloud storage must be set up with versioning. Note that the cloud configuration
#' will use same bucket/endpoint/credentials set in the _current_ environment.
#'
#' @param name Name of the target. `tar_read_version()` can take a symbol, `tar_read_raw_version()` requires a character.
#' @param branches Integer of indices of the (targets) branches to load if the target is a pattern.
#' @param store Path to the targets store within the project. Defaults to the current project's store.
#' @inheritParams file_read_version
#' @export
#' @return The target's return values, loaded files in the git file/⁠, or the paths to the custom files and directories if format = "file" was set.
#'   If the target is not found at the commit, NULL is returned.  See [tar_exists_version()] to check for the presence of a target.
tar_read_version <- function(name, ref = "HEAD", branches = NULL, extract_files = TRUE, repo = ".", store = targets::tar_path_store()) {
  check_installed("targets")
  name <- targets::tar_deparse_language(substitute(name))
  tar_read_raw_version(name, branches, ref, extract_files, repo, store)
}

#' @export
#' @inheritParams commits_between
#' @rdname tar_read_version
tar_read_versions <- function(name, from = "HEAD", to = NULL, branches = NULL, extract_files = TRUE, repo = ".", store = targets::tar_path_store()) {
  check_installed("targets")
  name <- targets::tar_deparse_language(substitute(name))
  tar_read_raw_versions(name, from, to, branches, extract_files, repo, store)
}

#' @rdname tar_read_version
#' @param extract_files If TRUE, targets of type "file" will be extracted to a temporary directory and these paths will be returned. If FALSE, the paths as stored in the target will be returned unmodified
#' @export
tar_read_raw_version <- function(name, ref = "HEAD", branches = NULL, extract_files = TRUE, repo = ".", store = targets::tar_path_store()) {
  check_installed("targets")
  repo <- as_repo(repo)
  ref <- as_commit(ref, repo)
  path_store <- file_copy_version(store, ref, repo = repo, recurse = FALSE)
  meta <- tar_meta_version(ref = ref, store = path_store)
  target_meta <- meta[meta$name == name, ]
  if (!nrow(target_meta)) {
    return(NULL)
  }
  # For local targets
  if (target_meta$repository == "local") {
    if (!target_meta$format == "file") {
      if (target_meta$type == "pattern") {
        file_copy_version(path(targets::tar_path_objects_dir(path_store), target_meta$children[[1]]), ref, repo = repo)
      } else {
        file_copy_version(path(targets::tar_path_objects_dir(path_store), name), ref, repo = repo)
      }
      target <- targets::tar_read_raw(name, meta = meta, store = path_store)
    } else if (target_meta$format == "file") {
      file_path <- targets::tar_read_raw(name, meta = meta, store = path_store)
      if (extract_files) {
        target <- file_copy_version(file_path, ref, repo = repo)
      } else {
        target <- file_path
      }
    }
  } else {
    targets <- targets::tar_read_raw(name, meta = meta, store = path_store)
  }
  target
}

#' @rdname tar_read_version
#' @export
tar_read_raw_versions <- function(name, from = "HEAD", to = NULL, branches = NULL, extract_files = TRUE, repo = ".", store = targets::tar_path_store()) {
  check_installed("targets")
  repo <- as_repo(repo)
  commits <- commits_between(from, to, repo)
  versions <- lapply(commits, \(x) tar_read_raw_version(name, x, branches, extract_files, repo, store))
  names(versions) <- vapply(commits, sha, character(1))
  versions
}
