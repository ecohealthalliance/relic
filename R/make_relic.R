make_relic <- function(path, ref, repo, ...) {
  repo <- as_relic_repo(repo)
  switch(class(repo),
    relic_git_repo = make_relic_git(path, ref, repo),
    relic_github_repo = make_relic_github(path, ref, repo),
    relic_s3_repo = make_relic_s3(path, ref, repo, ...)
  )
}

make_relic_git <- function(path, ref, repo) {
  commit <- as_commit(ref, repo)
  path <- path(path)
  splits <- path_split(path)[[1]]
  obj <- tree(commit)
  if (path == ".") {
    mode <- 16384L
    type <- "tree"
  } else {
    for (i in seq_along(splits)) {
      parent <- obj
      obj <- obj[splits[i]]
      if (rlang::is_empty(obj)) abort(paste0("File '", path, "' does not exist at '", ref, "' in ", repo))
    }
    mode <- parent$filemode[parent$name == splits[i]]
    type <- parent$type[parent$name == splits[i]]
  }
  structure(list(
    commit_sha = commit$sha,
    obj = obj,
    path = path,
    mode = mode,
    type = type,
    repo = structure(commit$repo$path, class = "relic_git_repo")
  ), class = paste0("relic_git_", type))
}

make_relic_github <- function(path, ref, repo) {
  vars <- list(
    owner = repo$owner,
    repo = repo$repo,
    expression = ref,
    path = path
  )
  gh_response <- gql(query = gh_relic_query(), variables = vars)
  structure(list(
    commit_sha = gh_response$data$repository$object$oid,
    obj = gh_response$data$repository$object$file$object$entries,
    path = path(gh_response$data$repository$object$file$path),
    mode = gh_response$data$repository$object$file$mode,
    type = gh_response$data$repository$object$file$type,
    repo = structure(list(
      owner = gh_response$data$repository$owner$login,
      repo = gh_response$data$repository$name
    ), class = "relic_github_repo")
  ), class = paste0("relic_github_", gh_response$data$repository$object$file$type))
}

# For now only fetching single items.  Future might fetch multiple, allowing for
# version to be set by date
make_relic_s3 <- function(key, version, bucket, endpoint = NULL, region = NULL) {
  check_installed("paws.storage")
  s3 <- paws.storage::s3(
    endpoint = endpoint,
    region = region
  )

  versions <- list()
  truncated <- TRUE
  while (truncated) {
    versions_resp <- s3$list_object_versions(
      Bucket = bucket,
      Prefix = key,
      VersionIdMarker = if (!length(versions)) NULL else versions_resp$NextVersionIdMarker,
      KeyMarker = if (!length(versions)) NULL else versions_resp$NextKeyMarker
    )
    versions <- c(versions, versions_resp$Versions)
    truncated <- versions_resp$IsTruncated
  }
  version_ids <- vapply(versions, function(x) x$VersionId, character(1))
  if (is.null(version) ||
    tolower(version) %in% c("latest", "current", "head", "null")) {
    version_id <- version_ids[vapply(versions, function(x) x$IsLatest, logical(1))]
  } else {
    version_id <- version_ids[substr(version_ids, 1, nchar(version)) == version]
  }

  structure(list(
    path = key,
    commit_sha = version_id,
    bucket = bucket,
    endpoint = endpoint,
    region = region,
    type = "blob"
  ), class = "relic_s3_obj")
}

gh_relic_query <- function() {
  "query ($owner: String!, $repo: String!, $expression: String!, $path: String!) {
    repository(owner: $owner, name: $repo) {
      url
      owner {
        login
      }
      name
      object(expression: $expression) {
        ... on Commit {
          oid
          file(path: $path) {
            path
            name
            mode
            type
            oid
            object {
              ... on Tree {
                entries {
                  path
                  name
                  mode
                  type
                  oid
                }
              }
            }
          }
        }
      }
    }
  }"
}
