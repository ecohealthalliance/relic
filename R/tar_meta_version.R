#' Read a target project's metadata from repository history
#'
#' This function extracts [targets metadata][targets::tar_meta()] from versioned history.
#' In most cases this is a git repository, but it can also be an S3 cloud bucket
#' for a project using cloud versioning and storing the metadata file in the cloud.
#' (See `repository_meta` in [targets::tar_option_set()]).
#'
#' @param ref A git commit SHA, tag, branch or other [revision
#'   string](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions):
#'   such as "HEAD~1", "main@{2023-02-26 18:30:00}", or "branch@{yesterday}".
#'   Can also be a [git2r::commit()] object.  For S3 buckets, a VersionID.
#'   Defaults to "HEAD", which also means the latest version in an S3 bucket.
#' @param store Path to the targets store within the project. Defaults to `"_targets`, or the current project's [store name][targets::tar_path_store()] if `repo = "."`.
#' @param repo The repository to get the file from. This can be a local git
#'  directory, a GitHub repository (URL or "owner/repo" string), or an S3 bucket
#'  indicated by "s3://bucket-name". Defaults to the current working directory.
#' @param endpoint,region For S3 buckets, the endpoint and region of the bucket.
#' @param ... Arguments passed to [targets::tar_meta()]
#' @return A data frame with one row per target/object. See [targets::tar_meta()] for details.
#' @export
tar_meta_version <- function(ref = "HEAD", store = NULL, repo = ".", endpoint = NULL, region = NULL, ...) {
  check_installed("targets")
  if (is.null(store)) {
    store <- if (repo == ".") targets::tar_config_get("store") else "_targets"
  }
  metafile <- get_file_version(path(store, "meta", "meta"), ref, repo = repo, endpoint, region)
  path_store <- path_dir(path_dir(metafile))
  meta <- targets::tar_meta(..., store = path_store)
  attr(meta, "path_store") <- path_store
  meta
}
