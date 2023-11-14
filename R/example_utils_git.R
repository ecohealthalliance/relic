#' Convenience functions for making and viewing a git repository
#'
#' @noRd
#' @param msg Text to use for both the commit message and tag
#' @return The path to the repository
#' @rdname example_utils_git
stamp <- function(msg, repo = ".") {
  git2r::add(repo = repo, path = ".")
  git2r::commit(repo = repo, message = msg, all = TRUE)
  git2r::tag(object = repo, name = msg)
}

#' @noRd
#' @param nlines the number of lines to print from each file
#' @rdname example_utils_git
print_dir <- function(repo, nlines = 10) {
  files <- dir_ls(dir, all = TRUE, recurse = TRUE, type = "file", regexp = ".*\\.git/.*", invert = TRUE)
  for (f in files) {
    print(path(f))
    text_content <- tryCatch(
      {
        readLines(f, n = nlines)
      },
      warning = function(w) {
        return("<BINARY>\n")
      },
      error = function(e) {
        stop(e)
      }
    )
    # Check if file is binary

    cat(c(text_content, "\n"), sep = "\n")
  }
  if (dir_exists(path(dir, ".git"))) {
    repo <- git2r::repository(dir)
    cat("Git commits:\n")
    print(as.data.frame(repo))
    cat(c("TAGS:", paste(names(tags(repo)), collapse = ", "), "\n"))
    invisible(NULL)
  }
}
