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

missing_oics_per_year <- function(otc, ytc) {
  setdiff(
    1:max(otc %>% filter(year == ytc) %>% pull(number)),
    otc %>% filter(year == ytc) %>% pull(number)
  )
}

tibble(year = 1990:2022) %>%
  mutate(
    missing_oics = map(year, ~ orders %>% missing_oics_per_year(.x)),
    n_missing_oics = map_int(missing_oics, length)
  )
