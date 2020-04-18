library(prodpad)
library(dplyr)
library(tidyr)
library(purrr)
pcli <- prodpad::prodpad()
fdbk <- get_feedback(pcli)

fdbk_link <- fdbk %>%
  unnest_longer(external_links) %>%
  dplyr::mutate(tmp = purrr::map_chr(external_links, ~ifelse(length(.x)< 4, .x["url"], .x[["url"]])))


all_ideas <- get_ideas(pcl)
all_fdbk <- get_feedback(pcl)
all_products <- get_products(pcl)

rsc_ideas <- get_ideas(pcl, "RStudio%20Connect")

fdbk_idea_link <- all_fdbk %>%
  pivot_longer(ideas, names_to = "idea_name", values_to = "idea_value") %>%
  tidyr::unnest_longer(idea_value) %>%
  tidyr::unnest_longer(idea_value) %>%
  filter(idea_value_id == "id") %>%
  mutate(idea_value = as.integer(idea_value))


joined_data <- rsc_ideas %>%
  left_join(
    fdbk_idea_link,
    by = c("id" = "idea_value")
  )

ranking <- joined_data %>%
  group_by(id, title, description) %>%
  tally()
