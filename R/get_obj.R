#' @returns A git2r object representing the file at the given reference, either a blob or, for a directory, a tree
get_git_obj_at_reference <- function(path, ref, repo = ".") {
  # Parse the reference name to a commit object
  if(is.character(ref)) ref <- revparse_single(repo, ref)

  path <- fs::path(path)
  path_parts <- fs::path_split(path)[[1]]
  repo <- git2r::repository(repo)
  repo_tree <- git2r::tree(ref)

  # Find the file in the tree
  obj <- repo_tree
  splits <- path_parts
  while (length(splits) >= 1) {
    obj <- obj[splits[1]]
    splits <- splits[-1]
  }

  return(obj)
}

#' Copy the contents of a git_blob object to disk
#' @return The path to the copied file, which is named for the SHA of the blob
copy_git_obj <- function(obj, filename = sha(obj), path = ".") {

  if(inherits(obj, "git_tree")) return(copy_git_tree(obj, dirname = filename, path))

  stopifnot(inherits(obj, "git_blob"))
  # stopifnot(!is_binary(obj))

  # Find the path of the git object in the .git/objects directory given its SHA

  out_path <- fs::path(path, filename)
  contents <- content(obj, split = FALSE, raw = TRUE)
  if(is.raw(contents)) {
    writeBin(contents, out_path)
  } else {
    cat(content(obj, split = FALSE), file = out_path)
  }

  out_path
}

#' Copy the contents of a git_tree object to a directory on disk recursively
#' @return The path to the directory, which is named for the SHA of the tree
copy_git_tree <- function(tree, dirname = sha(tree), path = ".") {
  out_path <- fs::path(path, dirname)
  fs::dir_create(out_path, recurse = TRUE)
  # Recurse down tree and copy all blobs
  for (i in seq_along(tree$name)) {
    obj <- tree[i]
    if (inherits(obj, "git_blob")) {
      # Can't read binary files yet, see https://github.com/ropensci/git2r/issues/460
      #if(is_binary(obj)) message("Skipping binary file")
      copy_git_obj(obj, filename = tree$name[i], path = out_path)
    } else if (inherits(obj, "git_tree")) {
      copy_git_tree(obj, dirname = tree$name[i], path = out_path)
    } else {
      warning("Unknown git object type")
    }
  }
  return(out_path)
}

#' Get a system-level temporary directory
tar_tempdir <- function() {
  p <- fs::path(fs::path_dir(tempdir()), "tar_versions")
  if(!fs::dir_exists(p)) fs::dir_create(p)
  p
}

