# Regression checks on the generated data for the Marine Species Distribution indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 4 dataset(s)", length(meta$datasets) == 4L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pins row count, first and last row, and min/max of each measure per file, so a
# data update fails here and says what changed. Compared as strings.
snap <- function(file, n, first, last, ranges) {
  d <- rd(file)
  row <- function(r) paste(unlist(d[r, ], use.names = FALSE), collapse = "|")
  check(sprintf("%s: %d rows", file, n), nrow(d) == n)
  check(sprintf("%s: first row %s", file, first), row(1L) == first)
  check(sprintf("%s: last row %s", file, last), row(nrow(d)) == last)
  for (k in names(ranges)) {
    v <- d$value[d$variable == k]
    num <- as.numeric(v)
    check(sprintf("%s: %s min %s, max %s", file, k, ranges[[k]][1], ranges[[k]][2]),
          identical(c(v[which.min(num)], v[which.max(num)]), ranges[[k]]))
  }
}

snap("marine_species_latitude_depth.csv", 288L,
     "1989|Multi-Region Average|latitude|0|miles",
     "2019|Southeast (Spring)|depth|-1.290671359|feet",
     list(latitude = c("-17.07549214", "50.4226312"),
          depth    = c("-39.02135111", "34.56683717")))
snap("marine_species_northeast.csv", 414L,
     "1974|American lobster|latitude|40.95936175|degrees",
     "2022|Red hake|change_in_latitude|105.1125865|miles",
     list(latitude  = c("36.85495634", "43.21384187"),
          longitude = c("-74.73775436", "-67.71052486"),
          change_in_latitude = c("-49.61951855", "155.5591284")))
snap("marine_species_bering_sea.csv", 324L,
     "1985|Snow crab|latitude|59.55771463|degrees",
     "2022|Pacific halibut|change_in_latitude|53.10708623|miles",
     list(latitude  = c("57.14329079", "60.18524026"),
          longitude = c("-173.4331926", "-165.5158572"),
          change_in_latitude = c("-49.03147225", "53.10708623")))
snap("marine_species_southeast.csv", 279L,
     "1989|Smooth butterfly ray|latitude|29.88996284|degrees",
     "2019|Atlantic croaker|change_in_latitude|114.8455009|miles",
     list(latitude  = c("29.68074748", "34.10352772"),
          longitude = c("-81.18495101", "-77.64434544"),
          change_in_latitude = c("-14.43585992", "263.1367368")))

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
