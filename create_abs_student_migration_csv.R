library(tidyverse)
library(readxl)

abs_file <- "data_raw/abs_migration_visa_state.xlsx"

dir.create("data", showWarnings = FALSE)

sheet_lookup <- tribble(
  ~sheet, ~state, ~state_abbr,
  "Table 4.1", "Australia", "AUS",
  "Table 4.2", "New South Wales", "NSW",
  "Table 4.3", "Victoria", "VIC",
  "Table 4.4", "Queensland", "QLD",
  "Table 4.5", "South Australia", "SA",
  "Table 4.6", "Western Australia", "WA",
  "Table 4.7", "Tasmania", "TAS",
  "Table 4.8", "Northern Territory", "NT",
  "Table 4.9", "Australian Capital Territory", "ACT"
)

clean_one_sheet <- function(sheet_name, state_name, state_abbr) {
  raw <- read_excel(
    abs_file,
    sheet = sheet_name,
    col_names = FALSE,
    col_types = "text"
  )

  names(raw) <- paste0("col_", seq_along(raw))

  raw <- raw |>
    mutate(
      across(
        everything(),
        ~ if_else(
          is.na(.x),
          NA_character_,
          str_squish(.x)
        )
      )
    )

  header_row <- raw |>
    mutate(row_id = row_number()) |>
    filter(str_detect(col_1, "Direction")) |>
    slice(1) |>
    pull(row_id)

  header_values <- as.character(unlist(raw[header_row, ]))

  year_position <- !is.na(header_values) &
    str_detect(header_values, "^\\d{4}-\\d{2}$")

  year_cols <- names(raw)[year_position]
  year_labels <- header_values[year_position]

  student_rows <- raw |>
    mutate(
      direction = case_when(
        str_detect(col_1, "Overseas migrant arrivals") ~ "Arrivals",
        str_detect(col_1, "Overseas migrant departures") ~ "Departures",
        TRUE ~ NA_character_
      )
    ) |>
    fill(direction) |>
    filter(
      col_3 %in% c(
        "Student - vocational education and training",
        "Student - higher education",
        "Student - other"
      )
    ) |>
    select(
      direction,
      visa_group = col_3,
      all_of(year_cols)
    )

  names(student_rows)[-(1:2)] <- year_labels

  student_rows |>
    pivot_longer(
      cols = -c(direction, visa_group),
      names_to = "year",
      values_to = "migration_count"
    ) |>
    mutate(
      state = state_name,
      state_abbr = state_abbr,
      migration_count = parse_number(migration_count),
      plot_value = if_else(
        direction == "Departures",
        -migration_count,
        migration_count
      ),
      visa_group = str_replace(
        visa_group,
        "Student - vocational education and training",
        "Student - VET"
      )
    ) |>
    filter(!is.na(migration_count)) |>
    select(
      state,
      state_abbr,
      year,
      direction,
      visa_group,
      migration_count,
      plot_value
    )
}

abs_student_migration_flow <- map_dfr(
  seq_len(nrow(sheet_lookup)),
  \(i) clean_one_sheet(
    sheet_lookup$sheet[i],
    sheet_lookup$state[i],
    sheet_lookup$state_abbr[i]
  )
)

write_csv(
  abs_student_migration_flow,
  "data/abs_student_migration_flow.csv"
)

print(abs_student_migration_flow)
