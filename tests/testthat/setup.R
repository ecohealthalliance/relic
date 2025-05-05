# Read in credentials if the file is unencrypted
env_file <- fs::path(rprojroot::find_root(rprojroot::is_r_package), ".env")
if (file.exists(env_file)) {
  x <- try(readRenviron(env_file), silent = TRUE)
  if (!inherits(x, "try-error")) {
    Sys.setenv("GITHUB_PAT" = Sys.getenv("RELIC_TESTING_GITHUB_PAT"))
  }
}

# Set a temporary location for the cache
withr::local_envvar(list(
  "R_USER_CACHE_DIR" = tempdir(),
  "RELIC_TESTING_GITHUB_PAT" = Sys.getenv("RELIC_TESTING_GITHUB_PAT"),
  "GITHUB_PAT" = Sys.getenv("RELIC_TESTING_GITHUB_PAT"))
)

## Run a MinIO server in the background to test S3 object storage with `targets`
if (nzchar(Sys.getenv("RELIC_TEST_S3"))) {
  s3_dir <- fs::file_temp("s3_cache")
  fs::dir_create(s3_dir)

  # Set minioclient directory to package directory so it is cached with packages
  mc_dir <- file.path(find.package("minioclient"), "mc_bin")
  fs::dir_create(mc_dir)
  withr::local_options(list(minioclient.dir = mc_dir, minioserver.dir = mc_dir))
  minioclient::install_mc()
  minioclient::install_minio_server()
  message("Installed MinIO server and client")

  # Launch server
  s3_srv <- minioclient::minio_server(dir = s3_dir, process_args = list(stdout = "minio.log", stderr = "2>&1"))
  Sys.sleep(2)
  stopifnot(s3_srv$is_alive())
  message("Started background MinIO server")

  ## Create a bucket for testing
  minioclient::mc_alias_set("relic", "localhost:9000", "minioadmin", "minioadmin", scheme = "http")
  minioclient::mc_mb("relic/relic-test")

  s3_repo <- create_example_repo(s3 = TRUE)

  if (rlang::is_interactive()) {
    s3_srv$kill()
    dir_delete(s3_dir)
  } else {
    withr::defer(s3_srv$kill(), testthat::teardown_env())
    withr::defer(dir_delete(s3_dir), testthat::teardown_env())
    withr::defer(dir_delete(s3_repo), testthat::teardown_env())
  }
}

## Create an example repository for testing
ex_repo <- create_example_repo(s3 = FALSE)
withr::defer(dir_delete(ex_repo), testthat::teardown_env())
