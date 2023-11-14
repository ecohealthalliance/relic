#' Tools for generating an example repository
#' @noRd
#' @param path path to the file to write or modify
#' @param text text to write to the file
#' @rdname example_utils_txt
write_to_file <- function(path, text) {
  dir_create(path_dir(path))
  text <- glue::glue(text, .open = "<<", .close = ">>")
  text <- strsplit(text, "\n")[[1]]
  cat(text, file = path, sep = "\n")
}

#' @noRd
#' @rdname example_utils_txt
append_to_file <- function(path, text) {
  dir_create(path_dir(path))
  text <- strsplit(glue::glue(text, .open = "<<", .close = ">>", ), "\n")[[1]]
  cat(text, file = path, sep = "\n", append = TRUE)
}

#' @noRd
#' @param line the line number to start overwriting or inserting at
#' @rdname example_utils_txt
overwrite_at_line <- function(path, line, text) {
  file_lines <- readLines(path)
  text <- strsplit(glue::glue(text, .open = "<<", .close = ">>", ), "\n")[[1]]
  # text_lines <- seq_along(text) + line - 1
  for (i in seq_along(text)) {
    file_lines[line + i - 1] <- text[i]
  }
  writeLines(file_lines, path)
}

#' @noRd
#' @param lines the lines to delete
#' @rdname example_utils_txt
delete_lines <- function(path, lines) {
  file_lines <- readLines(path)
  file_lines <- file_lines[-lines]
  writeLines(file_lines, path)
}

#' @noRd
#' @rdname example_utils_txt
insert_lines_at <- function(path, line, text) {
  file_lines <- readLines(path)
  text <- strsplit(glue::glue(text, .open = "<<", .close = ">>", ), "\n")[[1]]
  file_lines <- c(file_lines[1:(line-1)], text, file_lines[(line):length(file_lines)])
  writeLines(file_lines, path)
}
