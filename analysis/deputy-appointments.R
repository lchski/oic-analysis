deputy_appointment_orders <- bind_rows(
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    # filter(str_detect(text, coll("during pleasure", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("deputy|associate", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("minister|secretary", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    # filter(str_detect(text, coll("during pleasure", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("secretary|Chief Human Resources Officer|Chief Information Officer|Comptroller General of Canada", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("president", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("agency|shared services|school of public service", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(act, coll("Public Service Employment Act", ignore_case = TRUE))) %>%
    filter(! str_detect(precis, regex("^Special Appointment Regulations|good behaviour|part-? ?time", ignore_case = TRUE))) %>%
    filter(! str_detect(precis, regex("Order excluding|decision to exclude", ignore_case = TRUE))) %>%
    filter(is.na(registration_type)),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("commissioner", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("revenue|customs|correction|coast", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("director", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("service|centre", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("intelligence|analysis", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, coll("senior advisor", ignore_case = TRUE))) %>%
    filter(str_detect(text, coll("privy council office", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("chief", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("statistician", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
    filter(str_detect(text, regex("executive director", ignore_case = TRUE))) %>%
    filter(is.na(registration_type)),
  orders %>%
    filter(str_detect(act, regex("^Special Appointment Regulaitons")))
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
    filter(str_detect(precis, regex("^Salary Order", ignore_case = TRUE))),
  orders %>%
    filter(str_detect(precis, regex("fix(ing)?( of)? the (salary|remuneration payable)", ignore_case = TRUE))) %>%
    filter(str_detect(precis, "Governor in Council"))
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
  mutate(attachments = map_chr(attachments, paste, collapse = ";")) %>%
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
  mutate(attachments = map_chr(attachments, paste, collapse = ";")) %>%
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
