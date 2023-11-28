extract_relic <- function(relic, ...) {
  UseMethod("extract_relic")
}

#' @export
extract_relic.default <- function(relic, to, ...) {
  stop("Unknown relic type.")
}

#' @export
extract_relic.relic_git_blob <- function(relic, to, ...) {
  git_blob_to_file(relic$obj, to, relic$mode)
}

#' @export
extract_relic.relic_git_tree <- function(relic, to, recurse = TRUE, ...) {
  git_tree_to_dir(relic$obj, to, recurse)
}

#' @export
extract_relic.relic_github_blob <- function(relic, to, ...) {
  github_blob_to_file(relic$path, to, relic$mode, relic$commit_sha, relic$repo$owner, relic$repo$repo)
}

#' @export
extract_relic.relic_github_tree <- function(relic, to, recurse = TRUE, ...) {
  github_tree_to_dir(relic$path, relic$obj, to, recurse, relic$commit_sha, relic$repo$owner, relic$repo$repo)
}

#' @export
extract_relic.relic_s3_obj <- function(relic, to, ...) {
  s3_obj_to_file(relic$path, relic$commit_sha, relic$bucket, to, relic$endpoint, relic$region)
}
