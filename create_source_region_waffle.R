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
  "China", "East Asia",
  "India", "South Asia",
  "Nepal", "South Asia",
  "Philippines", "Southeast Asia",
  "Vietnam", "Southeast Asia",
  "Colombia", "South America",
  "Bangladesh", "South Asia",
  "Pakistan", "South Asia",
  "Indonesia", "Southeast Asia",
  "Brazil", "South America",
  "Thailand", "Southeast Asia",
  "Sri Lanka", "South Asia",
  "Malaysia", "Southeast Asia",
  "Korea, Republic of (South)", "East Asia",
  "Bhutan", "South Asia",
  "Taiwan", "East Asia",
  "Japan", "East Asia",
  "Hong Kong SAR", "East Asia",
  "Kenya", "Africa",
  "Mongolia", "East Asia"
)

source_region_summary_2025 <- students_country_2025 |>
  left_join(country_region, by = "country") |>
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

# Make sure total tiles = 100
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