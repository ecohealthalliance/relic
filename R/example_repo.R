#' Set up a testing and example repository
#'
#' This function generates a repository with a commit history that can be used
#' for testing and examples.
#' @param dir Path to the directory where the repository should be created
#' @param reporter the reporter to use when building targets with [targets::tar_make()]. Defaults to "silent".
#' @param s3 Whether the repository should use S3 storage for targets. Note that
#'   the S3 endpoint and bucket must already be available.
create_example_repo <- function(dir = fs::file_temp("relic_example_"), reporter = "silent", s3 = TRUE) {
  check_installed(c("targets", "glue"))
  if (dir_exists(dir)) dir_delete(dir)
  dir_create(dir)
  od <- setwd(dir)
  on.exit(setwd(od))
  repo <- git2r::init()
  # Configure the repository to use a generic user name and email address
  git2r::config(repo, user.name = "relic-bot", user.email = "relic@relic.r.pacakge")

  # Create a minimal _targets.R file
  write_to_file(
    "_targets.R",
    'library(targets)
    list(
     tar_target(cars, mtcars, repository = "local"),
     tar_target(cars_csv, {name <- "cars.csv"; write.csv(cars, name); name}, format = "file", repository = "local")
    )
  '
  )

  stamp("initial-target-file")

  targets::tar_make(reporter = reporter)
  append_to_file("_targets/.gitignore", c("!objects/\n!objects/*"))
  stamp("first-targets-run")

  overwrite_at_line(
    "_targets.R", 3,
    "tar_target(cars, rbind(mtcars, mtcars)),"
  )
  targets::tar_make(reporter = reporter)
  stamp("longer-cars")

  if(s3) {
  insert_lines_at(
    "_targets.R", 2,
    'Sys.setenv(
      AWS_ACCESS_KEY_ID="minioadmin",
      AWS_SECRET_ACCESS_KEY="minioadmin",
      AWS_DEFAULT_REGION="us-east-1"
      )
     tar_option_set(
       resources = tar_resources(
         aws = tar_resources_aws(
           bucket = "relic-test",
           prefix = "_targets",
           endpoint = "http://localhost:9000"
        )),
      repository = "aws"
       )
    ')
  targets::tar_make(reporter = reporter)
  stamp("setup-s3")
  }

  dir
}
