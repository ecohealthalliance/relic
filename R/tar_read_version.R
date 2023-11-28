#' Read a target's value from a git repository
#'
#' Reads the content of targets from a git repository. Target metadata and local
#' target files are extracted into a temporary directory before being read in by
#' `tar_read()`. For targets of type "file", the files are also extracted and
#' the paths to the extracted files are returned.
#'
#' For cloud targets, the target metadata is read from git history and then this
#' metadata is used to download the target from the cloud. For this to work,
#' cloud storage must be set up with versioning. Note that targets metadata
#' includes the bucket, endpoint, and region of a S3-stored target, but you must
#' still provide an AWS access key and secret as environment variables. If these
#' differ from the credentials used for your current project or environment, can
#' use [withr::with_envvar()] to temporarily set the credentials.
#'
#' @param name Name of the target. `tar_read_version()` can take a symbol,
#'   `tar_read_raw_version()` requires a character.
#' @param ref A git commit SHA, tag, branch or other [revision
#'   string](https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions):
#'   such as `"HEAD~1"`, `"main@{2023-02-26 18:30:00}"`, or
#'   `"branch@{yesterday}"`. Can also be a [git2r::commit()] object.  For S3
#'   buckets, a VersionID. Defaults to "HEAD", which also means the latest
#'   version in an S3 bucket.
#' @param store Path to the targets store within the project. Defaults to
#'   `"_targets`, or the current project's [store
#'   name][targets::tar_path_store()] if `repo = "."`.
#' @param repo The repository to get the file from. This can be a local git
#'   directory, a GitHub repository (URL or `"owner/repo"` string), or an S3
#'   bucket indicated by "s3://bucket-name". Defaults to the current working
#'   directory.
#' @export
#' @return The target's value. If the target is of `format = "file"`, this will
#'   be the path to the file in the [relic cache][relic_cache()].
tar_read_version <- function(name, ref = "HEAD", repo = ".", store = NULL) {
  check_installed("targets")
  name <- targets::tar_deparse_language(substitute(name))
  tar_read_raw_version(name, ref, repo, store)
}

#' @rdname tar_read_version
#' @export
tar_read_raw_version <- function(name, ref = "HEAD", repo = ".", store = NULL) {
  check_installed("targets")
  meta <- tar_meta_version(ref = ref, repo = repo, store = store)
  path_store <- attr(meta, "path_store")
  index <- meta$name == name
  if (!any(index) || sum(index) > 1) {
    abort("Target '", name, "' not found in the targets store (or multiple found).")
  }
  record <- meta[max(which(index)), , drop = FALSE]

  if (record$type == "pattern") {
    abort("Branched targets not supported yet")
  }

  target <- switch(record$repository,
    local = read_target_aws(record, path_store = path_store),
    aws = read_target_aws(record, path_store = path_store),
    abort("Unknown targets repository type: ", record$repository)
  )

  target
}

read_target_aws <- function(record, path_store) {
  aws_loc <- aws_loc_from_meta_path(record$path[[1]])
  local_target_path <- get_file_version(
    path = aws_loc$key, ref = aws_loc$version,
    repo = paste0("s3://", aws_loc$bucket),
    endpoint = aws_loc$endpoint, region = aws_loc$region
  )
  record_local <- record
  record_local$path <- list(local_target_path)
  record_local$repository <- "local"
  targets::tar_read_raw(record_local$name,
    meta = record_local,
    store = path_dir(path_dir(local_target_path))
  )
}

read_target_local <- function(record, path_store) {
  # For local targets
  local_target_path <- get_file_version(
    path = record$path[[1]], ref = record$version,
    repo = record$repository
  )
  record_local <- record
  record_local$path <- list(local_target_path)

  targets::tar_read_raw(record_local$name,
    meta = record_local,
    store = path_store
  )
}

aws_loc_from_meta_path <- function(path) {
  splits <- strsplit(path, "=")
  aws_loc <- structure(lapply(splits, function(x) x[[2]]),
    .Names = vapply(splits, function(x) x[[1]], character(1))
  )
  if (!is.null(aws_loc$endpoint)) {
    aws_loc$endpoint <- rawToChar(openssl::base64_decode(aws_loc$endpoint))
    if (aws_loc$endpoint == "NUL") {
      aws_loc["endpoint"] <- list(NULL)
    }
  }
  aws_loc
}
