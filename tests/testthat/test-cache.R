test_that("A relic cache dir set by environent variable overrides one set by options", {
  env_dir <- path_tidy(tempfile())
  options_dir <- path_tidy(tempfile())
  withr::local_envvar(RELIC_CACHE_DIR = env_dir)
  withr::local_options(relic.cache.dir = options_dir)
  expect_equal(relic_cache(), env_dir)
})
