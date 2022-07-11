library(tidyverse)
library(jsonlite)
library(rvest)

oic_data_folder <- "../data/oic-data/"

# do this instead of map_dfr, since map_dfr + read_json nulls out the entire row if there's an empty `attachments` array
# NB: if you want to get at the attachments, use `unnest_longer`, NOT `unnest`: the latter removes rows with 0 attachments
# TODO: switch to nested folder?
order_tables_raw <- tibble(source_file = fs::dir_ls(paste0(oic_data_folder, "order-tables/"), glob = "*.json")) %>%
  mutate(data = map(source_file, read_json)) %>%
  unnest_wider(data)

orders <- order_tables_raw %>%
  select(pcNumber, htmlHash, attachments, html) %>%
  mutate(html_parsed = map(html, read_html)) %>%
  mutate(text = map_chr(html_parsed, html_text2))
  
