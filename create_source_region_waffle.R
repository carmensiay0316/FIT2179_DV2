library(tidyverse)

students_country_2025 <- read_csv(
  "data/students_country_2025_top20.csv",
  col_types = cols(.default = col_character())
) |>
  mutate(
    enrolments = parse_number(enrolments)
  )

country_region <- tribble(
  ~country, ~region,
  "China", "North-East Asia",
  "India", "Southern and Central Asia",
  "Nepal", "Southern and Central Asia",
  "Philippines", "South-East Asia",
  "Vietnam", "South-East Asia",
  "Colombia", "Americas",
  "Bangladesh", "Southern and Central Asia",
  "Pakistan", "Southern and Central Asia",
  "Indonesia", "South-East Asia",
  "Brazil", "Americas",
  "Thailand", "South-East Asia",
  "Sri Lanka", "Southern and Central Asia",
  "Malaysia", "South-East Asia",
  "Korea, Republic of (South)", "North-East Asia",
  "Bhutan", "Southern and Central Asia",
  "Taiwan", "North-East Asia",
  "Japan", "North-East Asia",
  "Hong Kong SAR", "North-East Asia",
  "Kenya", "Africa",
  "Mongolia", "North-East Asia"
)

source_region_summary_2025 <- students_country_2025 |>
  left_join(country_region, by = "country") |>
  mutate(
    region = replace_na(region, "Other")
  ) |>
  group_by(region) |>
  summarise(
    enrolments = sum(enrolments, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    share = enrolments / sum(enrolments) * 100,
    tiles = round(share)
  ) |>
  arrange(desc(enrolments))

difference <- 100 - sum(source_region_summary_2025$tiles)

if (difference != 0) {
  source_region_summary_2025$tiles[1] <-
    source_region_summary_2025$tiles[1] + difference
}

source_region_waffle_2025 <- source_region_summary_2025 |>
  uncount(tiles) |>
  mutate(
    tile_id = row_number(),
    x = (tile_id - 1) %% 10,
    y = 9 - ((tile_id - 1) %/% 10),
    enrolment_label = format(
      enrolments,
      big.mark = ",",
      scientific = FALSE
    ),
    share_label = paste0(round(share, 1), "%")
  )

write_csv(
  source_region_summary_2025,
  "data/source_region_summary_2025.csv"
)

write_csv(
  source_region_waffle_2025,
  "data/source_region_waffle_2025.csv"
)

source_region_summary_2025