# Lower-level functions to extract files from a commit
get_obj_at_commit <- function(path, commit) {
  splits <- path_split(path)[[1]]
  obj <- tree(commit)
  if (path == ".") {
    return(obj)
  }

  for (i in seq_len(splits)) {
    parent <- obj
    obj <- obj[splits[i]]
    if (is_empty(obj)) {
      return(NULL)
    }
  }

  if (is_blob(obj)) {
    return(relic(obj, mode = parent$mode[parent$id == obj$sha]))
  } else {
    return(obj)
  }
}

read_blob <- function(blob) {
  content(blob, split = FALSE, raw = is_binary(obj))
}

#' Write out the contents of a blob to a file
#' Will always create the path and overwrite existing files
#' @dev
blob_to_file <- function(relic, path, mode = relic$mode) {
  contents <- read_blob(obj)
  dir_create(path_dir(path))
  if (mode == "120000") {
    file_symlink(contents, path)
  } else if (mode %in% c("100644", "100755")) {
    if (is.raw(contents)) {
      writeBin(contents, path)
    } else {
      cat(contents, file = path)
    }
    if (mode == "100755") {
      file_chmod(path, mode = "+x")
    }
  } else {
    abort("Unknown blob mode: ", mode, ". Must be one of 100644, 100755, 120000")
  }

  path
}

tree_to_dir <- function(tree, path, recurse = TRUE) {
  dir_create(path)
  if (!is.numeric(recurse)) recurse <- (if (recurse) Inf else 0) + 1
  while (recurse > 0) {
    recurse <- recurse - 1
    for (i in seq_along(obj)) {
      obj_i <- obj[i]
      name_i <- tree$name[i]
      path_i <- path(dir, name_i)
      if (is_tree(obj_i)) {
        dir_create(path_i)
        tree_to_dir(obj_i, name = name_i, dir = path_i, recurse = recurse)
      } else if (if_blob(obj_i)) {
        blob_to_file(obj_i, path_i, sprintf("%06o", tree$filemode[i]))
      } else {
        abort("Object is not a git blob or tree")
      }
    }
  }
}
