#' Wrappers to convert objects to git2r objects but allow git2r objects to pass
#' though
#' @noRd
as_relic_repo <- function(x) {
  if (inherits(x, "git_repository")) {
    repo <- structure(path(x$path), class = "relic_git_repo")
  } else if (is.character(x) && dir_exists(x)) {
    repo <- structure(path(discover_repository(x)), class = "relic_git_repo")
  } else if (!is.null(gh_repo <- github_owner_repo(x))) {
    repo <- structure(gh_repo, class = "relic_github_repo")
  } else if (is.character(x) && substr(x, 1, 5) == "s3://") {
    repo <- structure(substr(x, 6, nchar(x)), class = "relic_s3_repo")
  } else {
    abort("Unable to find repository for ", x)
  }
  return(repo)
}

github_owner_repo <- function(url) {
  gh_regex <- "^(git@github.com:|https?://github.com/)?(?<owner>[^/]+)/(?<repo>[^/]+)(\\.git|/.*)?$"
  owner_repo <- regmatches(url, regexec(gh_regex, url, perl = TRUE))[[1]][c("owner", "repo")]
  if (any(is.na(owner_repo))) {
    return(NULL)
  }
  as.list(owner_repo)
}


#' @rdname as_repo
#' @noRd
as_commit <- function(x, repo = ".") {
  if (is_commit(x)) {
    x
  } else if (is.character(x)) {
    revparse_single(repo, x)
  } else {
    commit(x)
  }
}

gql <- function(query, ...) {
  gh(
    endpoint = "POST /graphql", query = query,
    .send_headers = c("X-Github-Next-Global-ID" = "1"),
    ...
  )
}
