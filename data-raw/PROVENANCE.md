# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-marine-species-distribution/index.html>  \
  sha256 `8e2a59b192870d7626ada0a35ce646844ab6d3065ae552b09c4f16cc8b6a4b45`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-06/marine-species_documentation.pdf>

## Figure data

- `marine-species_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/marine-species_fig-1.csv>  \
  sha256 `dc90d5df24aa7fb94f8c1d040152ac68eb95dc64f84603c6e861b5fbc0afe62c`  \
  encoding windows-1252, 49 data rows, columns: `Year`, `Multi-Region Average - Latitude`, `Multi-Region Average - Depth`, `Northeast (Spring) - Latitude`, `Northeast (Spring) - Depth`, `Eastern Bering Sea - Latitude`, `Eastern Bering Sea - Depth`, `Southeast (Spring) - Latitude`, `Southeast (Spring) - Depth`  \
  title: Figure 1. Change in Latitude and Depth of Marine Species, 1974–2022  \
  data source: NOAA, 2024; web update: June 2024; units: miles (average distance moved); feet (average change in depth)

- `marine-species_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/marine-species_fig-2.csv>  \
  sha256 `43512df7f592ad77098af00973ae63b901d7f0db98b19022da84e0589f7a8530`  \
  encoding windows-1252, 50 data rows, columns: ``, `American lobster`, ``, ``, `Black sea bass`, ``, ``, `Red hake`, ``, ``  \
  title: Figure 2. Average Location of Three Fish and Shellfish Species in the Northeast, 1974–2022  \
  data source: NOAA, 2024; web update: June 2024; units: degrees; degrees; miles

- `marine-species_fig-3.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/marine-species_fig-3.csv>  \
  sha256 `b00ee076eb3b40b86e676d111b7815d97ec6b784e770319c783667980afea68d`  \
  encoding windows-1252, 39 data rows, columns: ``, `Snow crab`, ``, ``, `Walleye pollock`, ``, ``, `Pacific halibut`, ``, ``  \
  title: Figure 3. Average Location of Three Fish and Shellfish Species in the Bering Sea, 1985–2022  \
  data source: NOAA, 2024; web update: June 2024; units: degrees; degrees; miles

- `marine-species_fig-4.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-06/marine-species_fig-4.csv>  \
  sha256 `b67d09f202957163c90eec6df0b5abc6e5ce7fa25238a49153027d7dccf52c10`  \
  encoding windows-1252, 32 data rows, columns: ``, `Smooth butterfly ray`, ``, ``, `Banded drum`, ``, ``, `Atlantic croaker`, ``, ``  \
  title: Figure 4. Average Location of Three Fish and Shellfish Species in the Southeast, 1989–2019  \
  data source: NOAA, 2024; web update: June 2024; units: degrees; degrees; miles
