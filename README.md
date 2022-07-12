# Order in Council analysis

## Requirements

- Depends on [data repository (`lchski/oic-data`)](https://github.com/lchski/oic-data)
- Update the `oic_data_folder` variable in `load.R` to point toward your copy of the data repository

## Usage

- `source("load.R")` will load and parse the data—it may take some time
- `orders` contains the list of all orders published on [orders-in-council.canada.ca](https://orders-in-council.canada.ca/).
  - The `orders.html_parsed` column parses the raw HTML (`orders.html`) using [`read_html`](https://xml2.r-lib.org/reference/read_xml.html). Use a `map` function to further process this (see `orders.text` as an example).
  - The `orders.text` column applies [`html_text2`](https://rvest.tidyverse.org/reference/html_text.html) to extract parsed text. (Depending what you’re looking to do, this likely suffices—or use selectors like [`html_element`](https://rvest.tidyverse.org/reference/html_element.html) on `orders.html_parsed` to extract more specific information.)
- `attachments` contains order attachments. These provide additional information, beyond that in the order precis.
  - Orders from around `2002-1867` onward have at least one attachment. These are referenced in the `orders.attachments` column—these correspond to values in the `attachments.id` column.
  - `attachments.html`, `attachments.html_parsed`, and `attachments.text` are computed the same way as those columns on the `orders` table.
