deputy_appointment_orders <- bind_rows(
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, coll("during pleasure", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("deputy|associate", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("minister|secretary", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, coll("during pleasure", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("secretary", ignore_case = TRUE)))
) %>%
  distinct()

deputy_appointment_order_attachments <- attachments %>%
  filter(id %in% (deputy_appointment_orders %>%
           select(pc_number, attachments) %>%
           unnest_longer(attachments) %>%
           filter(! is.na(attachments)) %>%
           pull(attachments) %>%
           as.integer)
  )

salary_orders <- bind_rows(
  orders %>%
    filter(str_detect(precis, "^Salary Order"))
) %>%
  distinct()

salary_order_attachments <- attachments %>%
  filter(id %in% (salary_orders %>%
                    select(pc_number, attachments) %>%
                    unnest_longer(attachments) %>%
                    filter(! is.na(attachments)) %>%
                    pull(attachments) %>%
                    as.integer)
  )

deputy_appointment_orders %>%
  select(
    pc_number,
    attachments,
    text,
    date,
    act,
    precis
  ) %>%
  write_csv("data/out/deputy-head-analysis/deputy-appointment-orders.csv")

salary_orders %>%
  select(
    pc_number,
    attachments,
    text,
    date,
    act,
    precis
  ) %>%
  write_csv("data/out/deputy-head-analysis/salary-orders.csv")

deputy_appointment_order_attachments %>%
  select(
    id,
    html,
    text
  ) %>%
  write_csv("data/out/deputy-head-analysis/deputy-appointment-order-attachments.csv")

salary_order_attachments %>%
  select(
    id,
    html,
    text
  ) %>%
  write_csv("data/out/deputy-head-analysis/salary-order-attachments.csv")
