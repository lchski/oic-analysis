deputy_appointment_orders <- orders %>%
  filter(str_detect(text, coll("appointment", ignore_case = TRUE))) %>%
  filter(str_detect(text, coll("deputy", ignore_case = TRUE))) %>%
  filter(str_detect(text, coll("minister", ignore_case = TRUE))) %>%
  filter(str_detect(text, coll("during pleasure", ignore_case = TRUE)))

deputy_appointment_order_attachments <- attachments %>%
  filter(id %in% (deputy_appointment_orders %>%
           select(pcNumber, attachments) %>%
           unnest_longer(attachments) %>%
           filter(! is.na(attachments)) %>%
           pull(attachments) %>%
           as.integer)
  )
