library(tidyverse)

students_state_2025 <- read_csv("data/students_state_2025.csv", show_col_types = FALSE) # nolint

students_state_2025_map <- students_state_2025 |
  mutate(
    state_name = case_when(
      state == "NSW" ~ "New South Wales",
      state == "VIC" ~ "Victoria",
      state == "QLD" ~ "Queensland",
      state == "WA"  ~ "Western Australia",
      state == "SA"  ~ "South Australia",
      state == "TAS" ~ "Tasmania",
      state == "NT"  ~ "Northern Territory",
      state == "ACT" ~ "Australian Capital Territory",
      TRUE ~ state
    )
  ) |
  select(state_name, state_abbr = state, enrolments)

write_csv(students_state_2025_map, "data/students_state_2025_map.csv")

students_state_2025_map