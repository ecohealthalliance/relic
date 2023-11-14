#' List commits between two git commits
#'
#' Given two commit objects, find the commits between them.
#'
#' "Between" is bit of a slippery concept in git, since there may be multiple
#' paths between two commits. Internally it uses [git2r::commits()] which, in
#' turn using the [revwalk
#' API](https://libgit2.org/libgit2/#HEAD/group/revwalk), which is similar to
#' [git rev-list](https://git-scm.com/docs/git-rev-list). Essentially, it walks
#' back from the `to/from` commit (whichever is the descendant) until it reaches
#' the other. If there are multiple paths between the two commits, it will
#' return the commits on all paths.
#'
#' @param from A commit object or revision string. A string of the form
#'   'from...to' may also be passed, in which case the commits between the two
#'   revision strings are used and the `to` argument is ignored. If a list of commits
#'   is passed, these commits are used rather than calculating the commits between.
#' @param to A commit object or reference
#' @param filter_file The path to a file relative to the git directory. If not NULL,
#'   only commits modifying this file will be returned. Note that modifying
#'   commits that occurred before the file was given its present name are not
#'   returned.
#' @param repo The path to the git repository
#' @return A list of commits
#' @export
commits_between <- function(from, to = NULL, filter_file = NULL, repo = ".") {
  repo <- as_repo(repo)
  if (is.list(from) && all(vapply(from, is_commit, logical(1)))) {
    return(commits)
  }
  range <- commits_range(from, to, repo)
  if (is.null(range[[2]])) {
    return(list(range[[1]]))
  }

  # Check which is a descendant of the other
  to_descendant <- descendant_of(commit = range[[2]], ancestor = range[[1]])
  from_descendant <- descendant_of(commit = range[[1]], ancestor = range[[2]])
  if (!to_descendant && !from_descendant) stop("The two commits are not related")
  descendant <- if (to_descendant) range[[2]] else range[[1]]
  ancestor <- if (to_descendant) range[[1]] else range[[2]]

  # Find a branch the descendant is on
  branches <- branches(repo, flags = "local")
  branch_matches <- vapply(branches, function(branch) {
    tip <- lookup_commit(branch)
    identical(tip, descendant) ||
      descendant_of(commit = tip, ancestor = descendant)
  }, logical(1))
  if (!any(branch_matches)) stop("The descendant commit is not on any branch")
  ref_branch <- names(branches)[branch_matches][[1]]

  commits <- commits(
    repo = repo,
    ref = ref_branch,
    path = path
  )
  # Filter out commits that are not descendants of the ancestor or
  # are descendants of the descendant
  commits <- Filter(function(commit) {
    identical(commit, descendant) ||
      identical(commit, ancestor) ||
      (descendant_of(commit = commit, ancestor = ancestor) &&
        !descendant_of(commit = commit, ancestor = descendant))
  }, commits)

  if (to_descendant) commits <- rev(commits)

  commits
}

#' Parse 1 or 2 commits or revision strings into two commits
#' @noRd
commits_range <- function(from, to, repo) {
  if (is.character(from)) {
    refs <- strsplit(from, "...", fixed = TRUE)[[1]]
    if (length(refs) == 2) {
      from <- revparse_single(repo, refs[[1]])
      to <- revparse_single(repo, refs[[2]])
    }
  }
  # Look up the commit objects if references are given
  if (is.character(from)) from <- revparse_single(repo, from)
  if (is.character(to)) to <- revparse_single(repo, to)

  list(from, to)
}
