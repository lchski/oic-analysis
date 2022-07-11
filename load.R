library(tidyverse)
library(jsonlite)
library(rvest)

order_tables_raw <- fs::dir_ls("../data/oic-data/order-tables/", glob = "*.json") %>%
  map_dfr(read_json, .id = "source_file") %>%
  unnest(attachments) %>%
  group_by(pcNumber) %>%
  nest(attachments = attachments)

# do this instead of map_dfr, since map_dfr + read_json nulls out the entire row if there's an empty `attachments` array
# NB: if you want to get at the attachments, use `unnest_longer`, NOT `unnest`: the latter removes rows with 0 attachments
order_tables_raw <- tibble(source_file = fs::dir_ls("../data/oic-data/order-tables/", glob = "*.json")) %>%
  mutate(data = map(source_file, read_json)) %>%
  unnest_wider(data)

orders <- order_tables_raw %>%
  select(pcNumber, htmlHash, attachments, html) %>%
  mutate(html_parsed = map(html, read_html)) %>%
  mutate(text = map_chr(html_parsed, html_text2))
  
