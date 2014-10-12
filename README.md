## Web site for R package solarius

This web site is provided by [Github Pages](http://pages.github.com) using Markdown and git.

## Howto

Resources:

* [http://getbootstrap.com/components/](http://getbootstrap.com/components/)

### Base url 

Instructions are given in the official documentaion [project-page-url-structure](http://jekyllrb.com/docs/github-pages/#project-page-url-structure).

For this project `_config.yml` file has the following line:

```
baseurl: /solarius
```

The links to pages of the website are created in two ways:

* `<a href="{{ site.baseurl }}/" class="navbar-brand">solarius</a>`
* `<a href="{{ site.baseurl }}/pages/tutorial.html">Tutorial</a>`

Some discussion can be found [here](https://github.com/jekyll/jekyll/issues/332).

Note that testing site locally now is like:

```
$ jekyll serve --baseurl ''
```

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

