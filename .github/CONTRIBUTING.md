# Contributing to `relic`

This outlines how to propose a change to `relic`.

## General design considerations

-   `relic` is a high-level interface designed for working with git repositories
    of data science workflows. It is not intended to be a general-purpose client
    for git.
-   `relic`'s primary features are for extracting and comparing files and data
    from git history and running code within and across git history. Functions 
    in the package are generally _read-only_ and do not commit or modify history.
-   `relic` aims to have relatively few dependencies for its core functions (`git2r`
    and low-level packages such as `fs` and `rlang`).  For extended functionality,
    other packages may be used, but these should live under `Suggests:` and
    make use of `rlang::check_installed()`.
    
    Alternatively, using another package in a vignette may be a good way to
    demonstrate how `relic` can be used with other packages rather than extending
    `relic` itself.
-   `relic` has specific support for workflows using
     [`targets`](https://books.ropensci.org/targets/).  Similar functionality
     for other workflow managers may be considered in the future, as may high-level
     interfaces for dealing with other versioned data such as S3 buckets.
-   `relic` uses `git2r` to interface with git/libgit2.  In general `relic` functions
    should not call `libgit2` directly nor call `git` via the command line.  If
    `git2r` does not expose needed functionality in `libgit2`, consider making
    a contribution to `git2r`.
-   In general `relic` only deals with the local git repository.  It does not
    interface with remote repositories, nor interact with the APIs of services like
    GitLab, GitHub, or gitea.
    
## Testing

Tests for `relic` require some considerable bootstrapping outlined in the
[testing README](tests/README.md).  Notably, for testing workflows that interact
with S3 cloud storage, a MinIO server is run in the background to serve as an
S3 API endpoint.  You will need the `minio` command line tool installed as well
as the `mc` MinIO client.

## Lifecycle Statement

`relic` is a new package and its API is still under development.

`relic` developed to support internal projects at EcoHealth Alliance. We strive 
to be good contributors to the open-source ecosystem and for this to be a
general-purpose tool, but internal needs will drive prioritization of development
and design decisions.

## Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the documentation directly using the GitHub web interface, as long as the changes are made in the _source_ file. 
This generally means you'll need to edit [roxygen2 comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`, not a `.Rd` file. 
You can find the `.R` file that generates the `.Rd` by reading the comment in the first line.

## Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure someone from the team agrees that it’s needed. 
If you’ve found a bug, please file an issue that illustrates the bug with a minimal 
[reprex](https://www.tidyverse.org/help/#reprex) (this will also help you write a unit test, if needed).
See our guide on [how to create a great issue](https://code-review.tidyverse.org/issues/) for more advice.

### Pull request process

*   Fork the package and clone onto your computer. If you haven't done this before, we recommend using `usethis::create_from_github("ecohealthalliance/relic", fork = TRUE)`.

*   Install all development dependencies with `devtools::install_dev_deps()`, and then make sure the package passes R CMD check by running `devtools::check()`. 
    If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing. 
*   Create a Git branch for your pull request (PR). We recommend using `usethis::pr_init("brief-description-of-change")`.

*   Make your changes, commit to git, and then create a PR by running `usethis::pr_push()`, and following the prompts in your browser.
    The title of your PR should briefly describe the change.
    The body of your PR should contain `Fixes #issue-number`.

*  For user-facing changes, add a bullet to the top of `NEWS.md` (i.e. just below the first header). Follow the style described in <https://style.tidyverse.org/news.html>.

### Code style

*   New code should follow the tidyverse [style guide](https://style.tidyverse.org). 
    You can use the [styler](https://CRAN.R-project.org/package=styler) package to apply these styles, but please don't restyle code that has nothing to do with your PR.  

*  We use [roxygen2](https://cran.r-project.org/package=roxygen2), with [Markdown syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html), for documentation.  

*  We use [testthat](https://cran.r-project.org/package=testthat) for unit tests. 
   Contributions with test cases included are easier to accept.  

## Code of Conduct

Please note that the relic project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this
project you agree to abide by its terms.
