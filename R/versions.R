get.github.version <- function(config) {
  if (is.null(config$github_url)) {
    result <- github2versions(config$source_url)
  } else {
    result <- github2versions(config$github_url)
  }
  if (is.null(result)) {
    result <- "master"
  }
  if (!("master" %in% result)) {
    result <- c(result, "master")
  }
  black_list <- c("vcf-direct-final", "stable2", "stable1", "konnector2-prerelease", 
    "konnector-prelease", "bc_4.13", "BCM", "st-final", "sgdp")
  result <- result[!result %in% black_list]
  return(result)
}

github2versions <- function(github.url) {
  github.url <- str_replace(github.url, "http://|https://|git://", "")
  txt <- str_split(github.url, "/")[[1]]
  user <- txt[2]
  repo <- txt[3]
  h <- basicTextGatherer()
  myheader <- c(`User-Agent` = "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0_1 like Mac OS X; ja-jp) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A306 Safari/6531.22.7", 
    Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", 
    `Accept-Language` = "en-us", Connection = "keep-alive", `Accept-Charset` = "GB2312,utf-8;q=0.7,*;q=0.7")
  url <- sprintf("https://api.github.com/repos/%s/%s/tags?client_id=1d40ab6884d214ef6889&client_secret=23b818c2bad8e9f88dafd8a425613475362b326d", 
    user, repo)
  txt <- getURL(url, headerfunction = h$update, httpheader = myheader)
  json <- tempfile()
  cat(txt, file = json, sep = "\n")
  return(read.config(file = json)$name)
}

use.github.response <- function(config) {
  flag1 <- (!is.null(config$github_url)) && is.null(config$version_fixed)
  flag2 <- (!is.null(config$source_url)) && !is.null(config$use_github_versions)
  return(flag1 || flag2)
}

nongithub2versions <- function(name) {
  script <- system.file("extdata", "scripts/parse_version.R", package = "BioInstaller")
  source(script)
  text <- sprintf("get.%s.versions()", name)
  tryCatch(eval(parse(text = text)), error = function(e) {
    NULL
  })
}

version.newest <- function(config, versions) {
  if (is.null(config$version_order_fixed)) {
    versions <- versions[order(str_extract(versions, "[0-9.-].*"), decreasing = T)]
  }
  if (!is.null(config$version_newest_fixed)) {
    return(config$version_newest_fixed)
  }
  return(versions[1])
}
