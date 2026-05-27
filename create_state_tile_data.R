library(tidyverse)

students_state_2025 <- read_csv(
  "data/students_state_2025.csv",
  show_col_types = FALSE
)

state_tile_layout <- tribble(
  ~state, ~state_name, ~x, ~y,
  "WA",  "Western Australia", 1, 2,
  "NT",  "Northern Territory", 2, 1,
  "SA",  "South Australia", 2, 2,
  "QLD", "Queensland", 3, 1,
  "NSW", "New South Wales", 3, 2,
  "VIC", "Victoria", 3, 3,
  "TAS", "Tasmania", 3, 4,
  "ACT", "Australian Capital Territory", 4, 2
)

students_state_tile_2025 <- students_state_2025 |>
  left_join(state_tile_layout, by = "state") |>
  mutate(
    share = enrolments / sum(enrolments) * 100,
    enrolment_label = format(
      enrolments,
      big.mark = ",",
      scientific = FALSE
    ),
    share_label = paste0(round(share, 1), "%")
  ) |>
  select(
    state,
    state_name,
    x,
    y,
    enrolments,
    share,
    enrolment_label,
    share_label
  )

write_csv(
  students_state_tile_2025,
  "data/students_state_tile_2025.csv"
)

students_state_tile_2025