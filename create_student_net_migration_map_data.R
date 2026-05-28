library(readxl)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(readr)
library(tibble)

dir.create("data", showWarnings = FALSE)

file_path <- "data_raw/abs_migration_visa_state.xlsx"

state_sheets <- tibble::tribble(
  ~sheet, ~state, ~state_name,
  "Table 4.2", "NSW", "New South Wales",
  "Table 4.3", "VIC", "Victoria",
  "Table 4.4", "QLD", "Queensland",
  "Table 4.5", "SA", "South Australia",
  "Table 4.6", "WA", "Western Australia",
  "Table 4.7", "TAS", "Tasmania",
  "Table 4.8", "NT", "Northern Territory",
  "Table 4.9", "ACT", "Australian Capital Territory"
)

extract_student_net_by_year <- function(sheet, state, state_name) {
  raw_dat <- readxl::read_excel(
    path = file_path,
    sheet = sheet,
    skip = 14
  )

  names(raw_dat)[1:3] <- c("direction", "visa_type", "visa_group")

  year_cols <- names(raw_dat)[
    stringr::str_detect(names(raw_dat), "^20[0-9]{2}-[0-9]{2}")
  ]

  raw_dat |>
    tidyr::fill(direction, visa_type) |>
    dplyr::filter(
      .data$visa_type == "Temporary visas",
      .data$visa_group == "Student"
    ) |>
    dplyr::mutate(
      direction = dplyr::case_when(
        stringr::str_detect(
          stringr::str_to_lower(.data$direction),
          "arrivals"
        ) ~ "arrivals",
        stringr::str_detect(
          stringr::str_to_lower(.data$direction),
          "departures"
        ) ~ "departures",
        TRUE ~ .data$direction
      )
    ) |>
    dplyr::select(direction, dplyr::all_of(year_cols)) |>
    tidyr::pivot_longer(
      cols = -direction,
      names_to = "financial_year",
      values_to = "value"
    ) |>
    dplyr::mutate(
      financial_year = stringr::str_extract(
        .data$financial_year,
        "\\d{4}-\\d{2}"
      ),
      value = readr::parse_number(as.character(.data$value))
    ) |>
    tidyr::pivot_wider(
      names_from = direction,
      values_from = value
    ) |>
    dplyr::mutate(
      state = state,
      state_name = state_name,
      student_arrivals = .data$arrivals,
      student_departures = .data$departures,
      net_student_migration = .data$student_arrivals -
        .data$student_departures,
      year_start = as.integer(stringr::str_sub(.data$financial_year, 1, 4))
    ) |>
    dplyr::select(
      state,
      state_name,
      financial_year,
      year_start,
      student_arrivals,
      student_departures,
      net_student_migration
    )
}

student_net_migration_by_year <- purrr::pmap_dfr(
  state_sheets,
  extract_student_net_by_year
)

readr::write_csv(
  student_net_migration_by_year,
  "data/student_net_migration_by_year.csv"
)

print(student_net_migration_by_year)