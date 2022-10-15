# https://github.com/lchski/oic-analysis/issues/2
# 
# OICs are registered in a sequence each year, starting at 0001.
# For each year, find the OICs missing between 0001 and max(OIC number from year).
#
# Many of these (particularly for past years) will make sense (see OIC database:
# “Of note, certain Acts (namely the Statutory Instruments Act, the Access to
# Information Act, the Privacy Act and the Investment Canada Act) contain provisions
# which prohibit the release of OICs pertaining to national security or military
# operations or those containing personal or commercially-sensitive information.”).
# But others are likely just scraping error (see lchski/oic-data#2)—this could help
# detect them, and arrange for a boutique scrape to round out the set.
#
# For more context on unpublished orders, some coverage in recent years:
# - https://ipolitics.ca/news/two-dozen-secret-cabinet-decisions-hidden-from-parliament-canadians
# - https://www.cbc.ca/news/politics/secret-orders-in-council-1.6467450

identify_missing_oics_per_year <- function(otc, ytc) {
  setdiff(
    1:max(otc %>% filter(year == ytc) %>% pull(number)),
    otc %>% filter(year == ytc) %>% pull(number)
  )
}

missing_oics_by_year <- tibble(year = 1990:2022) %>%
  mutate(
    missing_oics = map(year, ~ orders %>% identify_missing_oics_per_year(.x)),
    n_missing_oics = map_int(missing_oics, length)
  )

missing_oics_by_year %>%
  ggplot(aes(x = year, y = n_missing_oics)) +
  geom_point()

missing_oic_pc_numbers <- missing_oics_by_year %>%
  unnest_longer(missing_oics) %>%
  select(year, number = missing_oics) %>%
  mutate(pc_number = paste0(year, "-", str_pad(number, width = 4, side = "left", pad = "0"))) %>%
  select(pc_number)

missing_oic_pc_numbers %>%
  write_csv("data/out/missing-oic-pc-numbers.csv")
