test_that("files are found in properly", {
  withr::local_dir(ex_repo)

  bin_file <- get_file_version("_targets/objects/cars", "first-targets-run", repo = ex_repo)
  text_file <- get_file_version("_targets.R", "first-targets-run", repo = ex_repo)
  expect_error(get_file_version("_targets/objects/cars", "initial-target-file", repo = ex_repo))
  expect_true(file_exists(bin_file))
  expect_true(file_exists(text_file))
})
