test_that("files are read in properly", {

  withr::local_dir(ex_repo)

  bin_file <- file_read_version("_targets/objects/cars", "first-targets-run", repo = ex_repo)[[1]]
  text_file <- file_read_version("_targets.R", "first-targets-run", repo = ex_repo)[[1]]
  no_file <- file_read_version("_targets/objects/cars", "initial-target-file", repo = ex_repo)[[1]]
  expect_type(bin_file, "raw")
  expect_type(text_file, "character")
  expect_null(no_file)
})
