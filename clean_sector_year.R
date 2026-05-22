library(tidyverse)

sector_year_raw <- read_csv(
  "data/students_sector_year.csv",
  col_types = cols(.default = col_character())
)

sector_year_clean <- sector_year_raw |
  rename_with(~ str_to_lower(.x)) |
  rename_with(~ str_replace_all(.x, " ", "_")) |
  filter(
    !is.na(sector),
    sector != "Sector",
    sector != "Grand Total"
  ) |
  mutate(
    year = as.integer(year),
    enrolments = parse_number(enrolments)
  ) |
  filter(
    year >= 2019,
    year <= 2025,
    !is.na(enrolments)
  ) |
  select(sector, year, enrolments)

write_csv(sector_year_clean, "data/students_sector_year.csv")

sector_year_clean