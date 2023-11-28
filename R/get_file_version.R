#' Get in files from versioned repository
#'
#' Fetches the contents of a file from a versioned repository - a local git
#' repository, a GitHub repository, or an S3 bucket. Always fetches the file
#' to a local cache and returns the path to it.
#'
#' @param path Path of a file relative to the git directory or bucket
#' @param ref A git commit SHA, tag, branch or other [revision
#'   string](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions):
#'   such as "HEAD~1", "main@{2023-02-26 18:30:00}", or "branch@{yesterday}".
#'   Can also be a [git2r::commit()] object. For S3 buckets, a VersionID.
#'   Defaults to "HEAD", which also means the latest version in an S3 bucket.
#' @param repo The repository to get the file from. This can be a local git
#'  directory, a GitHub repository (URL or "owner/repo" string), or an S3 bucket
#'  indicated by "s3://bucket-name". Defaults to the current working directory.
#' @param endpoint,region For S3 buckets, the endpoint and region of the bucket.
#'   If NULL, the default endpoint and region in local config or environment variables are used.
#'   (Usually `us-east-1` and `s3.amazonaws.com`.)
#' @export
#' @return A [path][fs::path()] to the file in the local cache.
get_file_version <- function(path, ref = "HEAD", repo = ".", endpoint = NULL, region = NULL) {
  if (!is_scalar_character(path)) {
    stop("path must be a single string")
  }

  # Check if the file is in the cache already
  in_cache <- path_in_cache(path, ref)
  if (!is.na(in_cache)) {
    return(in_cache)
  }
  relic <- make_relic(path, ref, repo, endpoint, region)

  relic_cache_path <- path(cache_sha(), relic$commit_sha, relic$path)
  if (relic$type == "blob" && file_exists(relic_cache_path)) {
    return(relic_cache_path)
  } else {
    extract_relic(relic, relic_cache_path)
  }
}
