github_blob_to_file <- function(path, to, mode, commit_sha, owner, repo) {
  contents <- as.raw(gh("/repos/{owner}/{repo}/contents/{path}",
    owner = owner, repo = repo, path = path, ref = commit_sha,
    .accept = "application/vnd.github.v3.raw"
  ))
  write_with_mode(contents, to, mode)
  to
}

github_tree_to_dir <- function(path, tree, to, recurse, commit_sha, owner, repo, skip = TRUE) {
  if (!is.numeric(recurse)) recurse <- (if (recurse) Inf else 0) + 1
  if (recurse > 0) {
    for (i in seq_along(tree)) {
      obj_i <- tree[[i]]
      name_i <- obj_i$name
      to_path_i <- path(to, name_i)
      abs_path_i <- path(path, name_i)
      if (obj_i$type == "tree") {
        dir_create(to_path_i)
        next_tree <- get_github_tree(obj_i$oid, owner, repo)
        github_tree_to_dir(abs_path_i, next_tree, to_path_i, recurse = recurse - 1, commit_sha, owner, repo)
      } else if (obj_i$type == "blob") {
        if (!skip || !file_exists(to_path_i)) {
          github_blob_to_file(abs_path_i, to_path_i, obj_i$mode, commit_sha, owner, repo)
        }
      } else {
        abort("Object is not a git blob or tree")
      }
    }
  }
  to
}


get_github_tree <- function(oid, owner, repo) {
  vars <- list(owner = owner, repo = repo, expression = oid)
  gh_response <- gql(gh_tree_query(), variables = vars)
  gh_response$data$repository$object$entries
}

gh_tree_query <- function() {
  "query ($owner: String!, $repo: String!, $expression: String!) {
    repository(owner: $owner, name: $repo) {
      object(expression: $expression) {
        ... on Tree {
          entries {
            name
            mode
            type
            oid
          }
        }
      }
    }
  }"
}
