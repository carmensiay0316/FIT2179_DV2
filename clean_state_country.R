library(xml2)
library(dplyr)
library(readr)
library(tibble)
library(tidyr)

xlsx_path <- "data_raw/december_2025_latest_data.xlsx"

dir.create("data", showWarnings = FALSE)

tmp_dir <- tempfile()
dir.create(tmp_dir)

unzip(
  xlsx_path,
  files = c(
    "xl/pivotCache/pivotCacheDefinition1.xml",
    "xl/pivotCache/pivotCacheRecords1.xml"
  ),
  exdir = tmp_dir
)

cache_def_path <- file.path(tmp_dir, "xl/pivotCache/pivotCacheDefinition1.xml")
cache_record_path <- file.path(tmp_dir, "xl/pivotCache/pivotCacheRecords1.xml")

ns <- c(x = "http://schemas.openxmlformats.org/spreadsheetml/2006/main")

cache_def <- read_xml(cache_def_path)
cache_records <- read_xml(cache_record_path)

cache_fields <- xml_find_all(cache_def, ".//x:cacheField", ns)
field_names <- xml_attr(cache_fields, "name")

get_shared_items <- function(field_node) {
  items <- xml_find_all(field_node, "./x:sharedItems/*", ns)
  if (length(items) == 0) {
    return(character())
  }
  xml_attr(items, "v")
}

shared_items <- lapply(cache_fields, get_shared_items)

record_nodes <- xml_find_all(cache_records, ".//x:r", ns)

extract_record <- function(record_node) {
  cells <- xml_children(record_node)
  cell_type <- xml_name(cells)
  cell_value <- xml_attr(cells, "v")
  output <- rep(NA_character_, length(field_names))
  for (i in seq_along(cells)) {
    if (cell_type[i] == "x") {
      lookup_index <- as.integer(cell_value[i]) + 1
      output[i] <- shared_items[[i]][lookup_index]
    } else {
      output[i] <- cell_value[i]
    }
  }
  output
}

raw_matrix <- vapply(
  record_nodes,
  extract_record,
  FUN.VALUE = character(length(field_names))
)

raw_data <- as_tibble(as.data.frame(t(raw_matrix), stringsAsFactors = FALSE))
names(raw_data) <- field_names

clean_raw <- raw_data |>
  mutate(
    Year = as.integer(Year),
    DATA_YTD_Enrolments = as.numeric(DATA_YTD_Enrolments)
  )

state_lookup <- tribble(
  ~state_code, ~state_name,
  "ACT", "Australian Capital Territory",
  "NSW", "New South Wales",
  "NT",  "Northern Territory",
  "QLD", "Queensland",
  "SA",  "South Australia",
  "TAS", "Tasmania",
  "VIC", "Victoria",
  "WA",  "Western Australia"
)

state_country_year <- clean_raw |>
  transmute(
    state_code = State,
    region = Region,
    nationality = Nationality,
    year = Year,
    enrolments = DATA_YTD_Enrolments
  ) |>
  filter(
    state_code %in% state_lookup$state_code,
    !is.na(nationality),
    !is.na(year),
    !is.na(enrolments)
  ) |>
  group_by(state_code, region, nationality, year) |>
  summarise(
    enrolments = sum(enrolments, na.rm = TRUE),
    .groups = "drop"
  ) |>
  left_join(state_lookup, by = "state_code") |>
  select(
    state_code,
    state_name,
    region,
    nationality,
    year,
    enrolments
  ) |>
  arrange(state_code, nationality, year)

state_country_2025 <- state_country_year |>
  filter(year == 2025) |>
  group_by(state_code, state_name) |>
  mutate(
    state_total = sum(enrolments, na.rm = TRUE)
  ) |>
  ungroup() |>
  group_by(state_code, state_name) |>
  arrange(desc(enrolments), nationality, .by_group = TRUE) |>
  mutate(
    rank_in_state = row_number(),
    share_of_state = enrolments / state_total
  ) |>
  ungroup()

state_country_2025_top20 <- state_country_2025 |>
  filter(rank_in_state <= 20)

state_totals_2025 <- state_country_2025 |>
  distinct(state_code, state_name, state_total) |>
  arrange(state_code)

state_country_year_wide <- state_country_year |>
  pivot_wider(
    names_from = year,
    values_from = enrolments,
    values_fill = 0
  ) |>
  arrange(state_code, nationality)

write_csv(
  state_country_year,
  "data/state_country_year_long.csv"
)

write_csv(
  state_country_2025,
  "data/state_country_2025.csv"
)

write_csv(
  state_country_2025_top20,
  "data/state_country_2025_top20.csv"
)

write_csv(
  state_totals_2025,
  "data/state_totals_2025.csv"
)

write_csv(
  state_country_year_wide,
  "data/state_country_year_wide_check.csv"
)

print(state_totals_2025)

state_country_2025_top20 |>
  count(state_code, state_name) |>
  print()