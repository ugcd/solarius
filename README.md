## Web site for R package solarius

This web site is provided by [Github Pages](http://pages.github.com) using Markdown and git.

## Howto

Resources:

* [http://getbootstrap.com/components/](http://getbootstrap.com/components/)

### Rmarkdown chunks:

* Issue [Code not properly displayed for R lessons using Jekyll #524](https://github.com/swcarpentry/bc/issues/524)

Current solution is to add the following chunk to *.Rmd files:

```
hook.t <- function(x, options) stringr::str_c("\n\n~~~\n", x, "~~~\n\n")
hook.r <- function(x, options) stringr::str_c("\n\n~~~ ", 
  tolower(options$engine), "\n", x, "~~~\n\n")

knitr::knit_hooks$set(source = hook.r, output = hook.t, warning = hook.t,
  error = hook.t, message = hook.t)
```



