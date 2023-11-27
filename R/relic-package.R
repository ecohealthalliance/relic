#' Objects from a while back
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import fs git2r
#' @importFrom rlang warn abort inform check_installed is_scalar_character
#' @importFrom gh gh
## usethis namespace: end
NULL

.onLoad <- function(...) {
  if (!is.infinite(relic_cache_cleanup_time())) relic_cache_regular_cleanup()
}
