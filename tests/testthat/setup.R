#Sys.setenv("RELIC_TEST_S3"="true")

withr::local_envvar(
  "R_USER_CACHE_DIR" = tempdir())

## Run a MinIO server in the background to test S3 object storage with `targets`
if(nzchar(Sys.getenv("RELIC_TEST_S3"))) {
  s3_dir <- file_temp("s3_cache")
  dir_create(s3_dir)

  mc_dir <- tools::R_user_dir("relic-test", "data")
  dir_create(mc_dir)
  withr::local_options(list("minioclient.dir"=mc_dir))

  minioclient::install_mc()
  minioclient::install_minio_server()
  message("Installed MinIO server and client")
  s3_srv <- minioclient::minio_server(dir = s3_dir, process_args = list(stdout = "minio.log", stderr = "2>&1"))
  Sys.sleep(2)
  stopifnot(s3_srv$is_alive())
  message("Started background MinIO server")
  ## Create a bucket for testing
  minioclient::mc_alias_set("relic", "localhost:9000", "minioadmin", "minioadmin", scheme = "http")
  minioclient::mc_mb("relic/relic-test")

  s3_repo <- create_example_repo(s3 = TRUE)

  if(rlang::is_interactive()) {
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





