
pkg_version <- function() {
  as.character(utils::packageVersion(pkg_name()))
}

has_length <- function(x) length(x) > 0L

filter_null <- function(x) Filter(Negate(is.null), x)

timestamp_now <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}
