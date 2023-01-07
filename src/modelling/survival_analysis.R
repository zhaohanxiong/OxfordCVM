# load dependencies
library(data.table)
library(ggplot2)
library(survival)
library(lubridate)
library(ggsurvfit)
library(gtsummary)
library(tidycmprsk)
library(condsurv)


ft_norm = data.frame(fread('NeuroPM/io/ukb_num_norm_ft_select.csv'))
ft_raw = data.frame(fread('NeuroPM/io/ukb_num_ft_select.csv'))
labels  = data.frame(fread('NeuroPM/io/labels_select.csv'))
outcomes = data.frame(fread('../../../ukb_outcomes.csv'))

pat_ids = labels$df...ignore_cols.
outcomes = outcomes[outcomes$eid %in% pat_ids,]

ids = c()
for (i in 1:length(pat_ids)) {
  ids[i] = match(pat_ids[i],outcomes$eid)
}

outcomes = outcomes[ids,]

## Time to event
cPCAAge = ft_raw$X21003.2.0
DeathAge = outcomes$X40007.0.0

TimeToEvent = DeathAge - cPCAAge

status = matrix(0, length(TimeToEvent), 1)
status[!is.na(TimeToEvent)] = 1

A = Surv(TimeToEvent, status) ~ 1
survfit2(Surv(TimeToEvent, status) ~ 1, data = TimeToEvent) %>% 
  ggsurvfit() +
  labs(
    x = "Days",
    y = "Overall survival probability"
  )