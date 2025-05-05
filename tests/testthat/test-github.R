test_that("GitHub testing access works", {
  skip_if_no_github()

  #Look up the GitHub organization
  expect_no_error(gh_response <- gh::gh("/orgs/{org}", org = Sys.getenv("RELIC_TESTING_GITHUB_ORG")))
  token_expiry <- attr(gh_response, "response")$`github-authentication-token-expiration`
  if (as.numeric(as.POSIXct(token_expiry) - Sys.time(), "days") < 7) {
    warning("GitHub token expires in less than a week. Please update the token.")
  }
})
