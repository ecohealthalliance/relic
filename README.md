
<!-- README.md is generated from README.Rmd. Please edit that file -->

# relic: objects from history

<!-- badges: start -->

[![Project Status:
Concept](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R-CMD-check](https://github.com/noamross/relic/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/noamross/relic/actions/workflows/R-CMD-check.yaml)
[![pkgcheck](https://github.com/noamross/relic/workflows/pkgcheck/badge.svg)](https://github.com/noamross/relic/actions?query=workflow%3Apkgcheck)
[![codecov](https://codecov.io/gh/noamross/relic/branch/main/graph/badge.svg)](https://codecov.io/gh/noamross/relic)
[![relic on
R-Universe](https://noamross.r-universe.dev/badges/relic)](https://noamross.r-universe.dev/relic)
[![CRAN
status](https://www.r-pkg.org/badges/version/relic)](https://CRAN.R-project.org/package=relic)
<!-- badges: end -->

The `relic` package provides tools for working with version-controlled
workflows, primarily git repositories and
[`targets`](https://books.ropensci.org/targets-manual) project. It
enables extracting and comparing files and objects from project history.

## Installation

You can install the development version of `relic` like so:

``` r
install.packages("relic", repos = c("https://noamross.r-universe.dev"))
```

## Related work

- [git2r](https://github.com/ropensci/git2r) is a low-level R interface
  to git, and is used by relic.
- [gert](https://github.com/r-lib/gert) is an alternative, higher-level
  R interface to git especially suited to performing and automating git
  operations.
- [gittargets](https://github.com/ropensci/gittargets) is an R package
  for versioning objects in the `targets` framework using git.
- [git2rdata](https://github.com/ropensci/git2rdata/) is an R package
  for organizing tabular data to store in git repositories.
- [git2net](https://github.com/gotec/git2net) is a Python package that
  facilitates network analysis of git repositories.
- [bisectr](https://github.com/wch/bisectr) is an R package for running
  `git bisect` to find commits that introduced bugs in project history.
- [dolt](https:://dolthub.com) is a relational database with git-like
  versioning and [doltr](https:://github.com/ecohealthalliance/doltr) is
  an R interface to it.

Find more related packages on
[R-Universe](https://r-universe.dev/search/?q=git).

## Code of Conduct

Please note that the relic project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

`relic` is developed at [EcoHealth
Alliance](https://www.ecohealthalliance.org/).

[![Created by EcoHealth
Alliance](https://raw.githubusercontent.com/ropensci/citesdb/master/vignettes/figures/eha-footer.png)](https://www.ecohealthalliance.org/)
