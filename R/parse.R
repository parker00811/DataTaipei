#'@importFrom magrittr %>%
#'@importFrom magrittr %<>%
searchParse <- function(response) {
  parsed <- httr::content(response, as = "parsed")
  if (class(parsed) == "character") parsed <- RJSONIO::fromJSON(parsed)
  result <- parsed$result
  results <- result$results
  name <- Reduce(union, lapply(results, names))
  name1 <- setdiff(name, "resources")
  retval <- lapply(name1, function(x) sapply(results, function(df) {
    ifelse(is.null(df[[x]]), NA, df[[x]])
  }))
  retval %<>% data.table::as.data.table(retval) %>%
    magrittr::set_colnames(name1)
  attributes(retval) <- c(attributes(retval), result[which(names(result) != "results")], list(resources = lapply(results, `[[`, "resources")))
  retval
}

#'@title Get Resource From Downloaded Table
#'@param tb (data.table). The output of \code{\link{dataSetMetadataSearch}} or \code{\link{resourceMetadataSearch}}.
#'@param index (integer). The index of target.
#'@return A data.frame. The resources of \code{index}th row in \code{tb} will be returned. 
#'@export
getResources <- function(tb, index) {
  .resources <- attr(tb, "resources")[[index]]
  name <- Reduce(union, lapply(.resources, names))
  retval <- lapply(name, function(x) sapply(.resources, function(df) {
    ifelse(is.null(df[[x]]), NA, df[[x]])
  }))
  retval %<>% data.table::as.data.table(retval) %>%
    magrittr::set_colnames(name)
  retval
}


resourceParse <- function(response) {
  result <- httr::content(response, as = "raw")
  writeBin(result, temp <- tempfile())
  if (Sys.info()["sysname"] %>% tolower != "windows") {
    temp2 <- tempfile()
    stopifnot(system(sprintf("iconv -f BIG-5 -t UTF-8 %s > %s", temp, temp2)) == 0)
    temp <- temp2
  }
  data.table::fread(temp)
}