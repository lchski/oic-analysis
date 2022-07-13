source("load.R")

orders %>%
  select(-html, -html_parsed) %>%
  write_csv("data/out/orders.csv")

attachments %>%
  select(-source_file, -html, -html_parsed) %>%
  write_csv("data/out/attachments.csv")
