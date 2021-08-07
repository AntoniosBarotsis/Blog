[![github pages](https://github.com/AntoniosBarotsis/Blog/actions/workflows/deploy_bookdown.yml/badge.svg)](https://github.com/AntoniosBarotsis/Blog/actions/workflows/deploy_bookdown.yml)

# Blog

This repository houses my blog created with [Blogdown](https://github.com/rstudio/blogdown) and [Hugo](https://github.com/gohugoio/hugo)
using the [Papermod](https://github.com/adityatelange/hugo-PaperMod) theme.

## Running locally

If you want to run the blog locally **without** making changes to the `.Rmd` files you can do so with:

```bash
hugo run
```

If you don't have `hugo` installed, check [this](https://gohugo.io/getting-started/installing).

If you want to edit the `.Rmd` files however you need to use `Blogdown`. Run the following R code:

```R
install.packages('blogdown')
blogdown::serve_site()
```