skip_if_no_github <- function() {
  skip_if_offline("github.com")
  skip_on_cran()

  skip_if(!nzchar(Sys.getenv("RELIC_TESTING_GITHUB_PAT")), "No RELIC_TESTING_GITHUB_PAT env var")
  skip_if(!nzchar(Sys.getenv("RELIC_TESTING_GITHUB_ORG")), "No RELIC_TESTING_GITHUB_ORG env var")

}
