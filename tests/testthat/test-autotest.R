library(autotest)

Sys.setenv("AUTOTEST" = "1")
# Skip this test unless environment variable AUTOTEST is set to 1
test_that("autotest tests pass", {
  skip_if(!Sys.getenv("AUTOTEST") == "1", "Skipping autotest, set `AUTOTEST=1` to test")
  tests <- autotest::autotest_package(here::here(), test = TRUE)
  autotest::expect_autotest_no_err(tests)
})
