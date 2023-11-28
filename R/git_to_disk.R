git_blob_to_file <- function(blob, to, mode) {
  contents <- content(blob, split = FALSE, raw = TRUE)
  write_with_mode(contents, to, mode)
  to
}

git_tree_to_dir <- function(tree, to, recurse, skip = TRUE) {
  if (!is.numeric(recurse)) recurse <- (if (recurse) Inf else 0) + 1
  if (recurse > 0) {
    for (i in seq_along(tree)) {
      obj_i <- tree[i]
      name_i <- tree$name[i]
      path_i <- path(to, name_i)
      if (is_tree(obj_i)) {
        dir_create(path_i)
        git_tree_to_dir(obj_i, path_i, recurse = recurse - 1)
      } else if (is_blob(obj_i)) {
        if (!skip || !file_exists(path_i)) {
          git_blob_to_file(obj_i, path_i, tree$filemode[i])
        }
      } else {
        abort("Object is not a git blob or tree")
      }
    }
  }
  to
}

write_with_mode <- function(contents, to, mode, read_only = TRUE) {
  dir_create(path_dir(to))
  if (mode == 40960L) {
    link_create(rawToChar(contents), to)
  } else if (mode %in% c(33188L, 33261L)) {
    writeBin(contents, to)
  } else {
    abort(paste0(
      "Unknown blob mode: ", mode,
      ", Must be one of 40960L, 33188L, 33261L. Submodules not yet supported."
    ))
  }
  if (read_only) {
    file_chmod(to, mode = "u-w")
  }
  if (mode == 33261L) {
    file_chmod(to, mode = "+x")
  }
  to
}
