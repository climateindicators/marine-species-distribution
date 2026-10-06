# Build tidy long-format data for the Marine Species Distribution indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Figure 1 is pivoted inline; figures 2-4 share reshape_species() below.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Figures 2-4 share one layout: a species header row (name over the first of
# three columns), a sub-header row, then one row per year. Returns long data
# with columns year, species, variable, value, unit; blank cells are dropped.
SPECIES_SUBHEADERS <- c("Latitude", "Longitude", "Change in latitude (miles)")
SPECIES_VARIABLES  <- c("latitude", "longitude", "change_in_latitude")
SPECIES_UNITS      <- c("degrees", "degrees", "miles")

reshape_species <- function(raw, what) {
  hdr <- unlist(raw[1, ], use.names = FALSE)
  stopifnot(
    "Year row not found" = hdr[1] == "Year",
    "sub-headers changed" = identical(hdr[-1], rep(SPECIES_SUBHEADERS, length.out = length(hdr) - 1L))
  )
  species_at <- seq(2L, ncol(raw), by = 3L)
  species    <- names(raw)[species_at]
  if (any(species == "") || any(names(raw)[-c(1L, species_at)] != "")) {
    stop("Species header row of ", what, " is not one name per three columns.", call. = FALSE)
  }
  body <- raw[-1, , drop = FALSE]
  year <- body[[1]]
  out <- lapply(seq_along(species), function(s) {
    lapply(1:3, function(k) {
      v <- body[[species_at[s] + k - 1L]]
      keep <- trimws(v) != ""
      data.frame(
        year = year[keep], species = species[s], variable = SPECIES_VARIABLES[k],
        value = v[keep], unit = SPECIES_UNITS[k], stringsAsFactors = FALSE
      )
    })
  })
  out <- bind_rows(unlist(out, recursive = FALSE))
  assert_conservation(body[-1], seq_len(ncol(body) - 1L), nrow(out), what)
  out
}

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Marine Species Distribution",
  slug                    = "marine-species-distribution",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-marine-species-distribution/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-06/marine-species_documentation.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Change in Latitude and Depth of Marine Species, 1974–2022 ----

f1_path <- file.path(raw_dir, "marine-species_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f1_raw,
  id_cols          = "Year",
  expected_headers = c("Multi-Region Average - Latitude", "Multi-Region Average - Depth", "Northeast (Spring) - Latitude", "Northeast (Spring) - Depth", "Eastern Bering Sea - Latitude", "Eastern Bering Sea - Depth", "Southeast (Spring) - Latitude", "Southeast (Spring) - Depth"),
  what             = "marine-species_fig-1.csv"
)

# Units line carries one unit per measure: latitude change in miles, depth
# change in feet. Carried per row in `unit`; meta.yml keeps EPA's full line.
f1_cols <- setdiff(names(f1_raw), "Year")
f1 <- bind_rows(lapply(f1_cols, function(nm) {
  keep  <- trimws(f1_raw[[nm]]) != ""
  parts <- strsplit(nm, " - ", fixed = TRUE)[[1]]
  stopifnot(length(parts) == 2L, parts[2] %in% c("Latitude", "Depth"))
  lat <- parts[2] == "Latitude"
  data.frame(
    year     = f1_raw$Year[keep],
    region   = parts[1],
    variable = if (lat) "latitude" else "depth",
    value    = f1_raw[[nm]][keep],
    unit     = if (lat) "miles" else "feet",
    stringsAsFactors = FALSE
  )
}))
assert_conservation(f1_raw, f1_cols, nrow(f1), "marine-species_fig-1.csv")

write_csv_stable(f1, file.path(out_dir, "marine_species_latitude_depth.csv"))

# ---- Figure 2: Average Location of Three Fish and Shellfish Species in the Northeast, 1974–2022 ----

f2_path <- file.path(raw_dir, "marine-species_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f2_raw,
  id_cols          = character(),
  expected_headers = c("", "American lobster", "", "", "Black sea bass", "", "", "Red hake", "", ""),
  what             = "marine-species_fig-2.csv"
)

f2 <- reshape_species(f2_raw, "marine-species_fig-2.csv")
write_csv_stable(f2, file.path(out_dir, "marine_species_northeast.csv"))

# ---- Figure 3: Average Location of Three Fish and Shellfish Species in the Bering Sea, 1985–2022 ----

f3_path <- file.path(raw_dir, "marine-species_fig-3.csv")
f3_meta <- read_epa_preamble(f3_path)
f3_raw  <- read_epa_csv(f3_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f3_raw,
  id_cols          = character(),
  expected_headers = c("", "Snow crab", "", "", "Walleye pollock", "", "", "Pacific halibut", "", ""),
  what             = "marine-species_fig-3.csv"
)

f3 <- reshape_species(f3_raw, "marine-species_fig-3.csv")
write_csv_stable(f3, file.path(out_dir, "marine_species_bering_sea.csv"))

# ---- Figure 4: Average Location of Three Fish and Shellfish Species in the Southeast, 1989–2019 ----

f4_path <- file.path(raw_dir, "marine-species_fig-4.csv")
f4_meta <- read_epa_preamble(f4_path)
f4_raw  <- read_epa_csv(f4_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f4_raw,
  id_cols          = character(),
  expected_headers = c("", "Smooth butterfly ray", "", "", "Banded drum", "", "", "Atlantic croaker", "", ""),
  what             = "marine-species_fig-4.csv"
)

f4 <- reshape_species(f4_raw, "marine-species_fig-4.csv")
write_csv_stable(f4, file.path(out_dir, "marine_species_southeast.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

# One entry per output column, in order, taken from the data frame so it cannot
# drift. Descriptions are looked up by column name; an unknown column stops the build.
COLUMN_DOCS <- list(
  year     = c("integer", "Calendar year of the observation."),
  region   = c("string",  "Survey region (Figure 1 only)."),
  species  = c("string",  "Fish or shellfish species (Figures 2-4)."),
  variable = c("string",  "Measure: latitude, depth, longitude, or change_in_latitude."),
  value    = c("number",  "Value of the measure, in the unit given by the unit column, as published by EPA."),
  unit     = c("string",  "Unit of value: miles, feet, or degrees.")
)
describe <- function(df) lapply(names(df), function(nm) {
  d <- COLUMN_DOCS[[nm]]
  if (is.null(d)) stop("No documentation for column ", sQuote(nm), call. = FALSE)
  col(nm, d[1], d[2])
})

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "marine_species_latitude_depth.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "marine-species_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "windows-1252",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(f1)
    ),
    list(
      file            = "marine_species_northeast.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "marine-species_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "windows-1252",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = describe(f2)
    ),
    list(
      file            = "marine_species_bering_sea.csv",
      figure          = "Figure 3",
      figure_title    = f3_meta$title,
      source_file     = "marine-species_fig-3.csv",
      source_sha256   = file_sha256(f3_path),
      source_encoding = "windows-1252",
      data_source     = f3_meta$data_source,
      web_update      = f3_meta$web_update,
      unit            = f3_meta$units,
      rows            = nrow(f3),
      columns         = describe(f3)
    ),
    list(
      file            = "marine_species_southeast.csv",
      figure          = "Figure 4",
      figure_title    = f4_meta$title,
      source_file     = "marine-species_fig-4.csv",
      source_sha256   = file_sha256(f4_path),
      source_encoding = "windows-1252",
      data_source     = f4_meta$data_source,
      web_update      = f4_meta$web_update,
      unit            = f4_meta$units,
      rows            = nrow(f4),
      columns         = describe(f4)
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
