strict_tests <- nzchar(Sys.getenv("RELIC_TEST_STRICT"))
pkgroot <- test_package_root()

test_that("Linting", {
  testthat::skip_on_cran()
  testthat::skip_on_covr()
  lints <- lintr::lint_package(pkgroot)
  has_lints <- length(lints) > 0L
  if (has_lints) {
    lint_output <- format(lints)
  }
  if (strict_tests) {
    testthat::expect(!has_lints, paste0(
      "Not lint free\n",
      format(lints)
    ))
  } else {
    if (has_lints) warning("Lints found, run `lintr::lint_package()` to see them.")
    expect_true(TRUE)
  }
})

test_that("Spelling", {
  testthat::skip_on_cran()
  testthat::skip_on_covr()
  typos <- spelling::spell_check_package(pkgroot)
  has_typos <- nrow(typos) > 0L
  if (strict_tests) {
    expect(!has_typos, paste0(
      "Not typo free: \n",
      capture.output(typos)
    ))
  } else {
    if (has_typos) warning("Typos found, run `spelling::spell_check_package()` to see them.")
    expect_true(TRUE)
  }
})

test_that("Styling", {
  testthat::skip_on_cran()
  testthat::skip_on_covr()
  styler_output <- capture.output(styler_data <- styler::style_pkg(dry = "on"))
  has_style_changes <- any(styler_data$changed)
  if (strict_tests) {
    expect(!has_style_changes, paste0(
      "Style changes to make: \n",
      collapse(styler_output, "\n")
    ))
  } else {
    if (has_style_changes) warning("Style changes found, run `styler::style_pkg()` to fix them.")
    expect_true(TRUE)
  }
})
