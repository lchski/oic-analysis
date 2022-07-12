library(tidyverse)
library(jsonlite)
library(rvest)
library(janitor)
library(lubridate)

oic_data_folder <- "../data/oic-data/"

# do this instead of map_dfr, since map_dfr + read_json nulls out the entire row if there's an empty `attachments` array
# NB: if you want to get at the attachments, use `unnest_longer`, NOT `unnest`: the latter removes rows with 0 attachments
# TODO: switch to nested folder?
order_tables_raw <- tibble(source_file = fs::dir_ls(paste0(oic_data_folder, "order-tables/"), glob = "*.json")) %>%
  mutate(data = map(source_file, read_json)) %>%
  unnest_wider(data)

orders <- order_tables_raw %>%
  select(pcNumber, htmlHash, attachments, html) %>%
  clean_names %>%
  separate(pc_number, into = c("year", "number"), convert = TRUE, remove = FALSE) %>%
  mutate(html_parsed = map(html, read_html)) %>%
  mutate(text = map_chr(html_parsed, html_text2)) %>%
  mutate(
    date = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = "//tr[2]/td[3]") %>%
           html_text2)),
    chapter = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = "//tr[2]/td[4]") %>%
           html_text2)),
    bill = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = "//tr[2]/td[5]") %>%
           html_text2)),
    department = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = "//tr[2]/td[6]") %>%
           html_text2)),
    act = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = '//td[text()="Act"]/following-sibling::td[@colspan=5]') %>%
           html_text2)),
    subject = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = '//td[text()="Subject"]/following-sibling::td[@colspan=5]') %>%
           html_text2)),
    precis = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = '//td[text()="Precis"]/following-sibling::td[@colspan=5 or @id="precis"]') %>%
           html_text2)),
    registration = map_chr(
      html_parsed,
      ~ (.x %>%
           html_element(xpath = '//td[text()="Registration"]/following-sibling::td[@colspan=5 or @id="registration"]') %>%
           html_text2))
  ) %>%
  separate(registration, into = c("registration_id", "registration_publication_date"), sep = " Publication Date: ") %>%
  mutate(registration_id = str_remove(registration_id, coll("Registration: "))) %>%
  separate(registration_id, into = c("registration_type", "registration_id"), sep = "\\/ ") %>%
  mutate(
    registration_type = str_remove(registration_type, fixed("/")),
    registration_type = str_trim(registration_type)
  ) %>%
  mutate(across(contains("date"), as_date)) %>%
  mutate(department_raw = department)

# TODO: how to split apart the strange "Dept" field...
# this approach _seems_ to work (including some tricky filters / nesting to retain cases where an order lacks a department, e.g., just ", " or "")
# BUT, if you compare these two queries, we get a different number of results:
#   orders %>% filter(map_lgl(department, ~ "PMO" %in% .))
#   orders %>% filter(str_detect(department_raw, "PMO"))
# maybe it's something to do with `str_split` on " "?
# we could do non-characters, but then a few departments have, e.g., "&" in the name
orders %>%
  mutate(
    department = if_else(str_detect(department, "[^, ]+", negate = TRUE), NA_character_, department),
    department = str_remove_all(department, fixed(",")),
    department = str_split(department, fixed(" "))
  ) %>%
  unnest(department, keep_empty = TRUE) %>%
  filter(is.na(department) | department != "") %>%
  group_by(pc_number) %>%
  nest(department = department) %>%
  ungroup

attachments_raw <- fs::dir_ls(paste0(oic_data_folder, "attachments/"), glob = "*.json") %>%
  map_dfr(read_json, .id = "source_file")

attachments <- attachments_raw %>%
  clean_names %>%
  type_convert %>%
  arrange(id) %>%
  rename(html = attachment_html) %>%
  mutate(html = paste0("<main>", html, "</main>")) %>% # because we save the innerHTML, oops
  mutate(html_parsed = map(html, read_html)) %>%
  mutate(text = map_chr(html_parsed, html_text2))
