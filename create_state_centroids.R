library(tidyverse)

students_state_2025 <- read_csv(
  "data/students_state_2025.csv",
  show_col_types = FALSE
)

state_locations <- tribble(
  ~state, ~state_name, ~longitude, ~latitude,
  "NSW", "New South Wales", 147.0, -32.0,
  "VIC", "Victoria", 144.5, -37.0,
  "QLD", "Queensland", 145.0, -22.5,
  "WA",  "Western Australia", 121.5, -26.0,
  "SA",  "South Australia", 135.5, -30.0,
  "TAS", "Tasmania", 146.5, -42.0,
  "NT",  "Northern Territory", 133.0, -19.5,
  "ACT", "Australian Capital Territory", 149.1, -35.3
)

students_state_centroids_2025 <- students_state_2025 |
  left_join(state_locations, by = "state") |
  select(state, state_name, longitude, latitude, enrolments)

write_csv(
  students_state_centroids_2025,
  "data/students_state_centroids_2025.csv"
)

students_state_centroids_2025