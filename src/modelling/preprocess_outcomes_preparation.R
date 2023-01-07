source("preprocess_utils.R")

## Selecting specific outcomes from the whole UKB set

file_name = "../../../ukb51139_v2.csv"
df = fread(file_name, nrows = 1)
df_patid = fread(file_name, nrows = Inf, select = c("eid"))
df_death = fread(file_name, nrows = Inf, select = grep("X40000.|X40001.|X40002.|X40007.|X40010.",names(df),value=TRUE))
df_heartattack = fread(file_name, nrows = Inf, select = grep("X3894.",names(df),value=TRUE))
df_stroke = fread(file_name, nrows = Inf, select = grep("X4056.",names(df),value=TRUE))
df_angina = fread(file_name, nrows = Inf, select = grep("X3627.",names(df),value=TRUE))
df_LVEF = fread(file_name, nrows = Inf, select = grep("X24103.",names(df),value=TRUE))

df_outcomes = cbind(df_patid,df_death,df_heartattack,df_stroke,df_angina,df_LVEF)

dir.create("NeuroPM/outcomes_analysis")
fwrite(df_outcomes, "NeuroPM/outcomes_analysis/ukb_outcomes.csv")

## match subset subjects only to get outcomes
ukb_df = fread("NeuroPM/io/labels.csv", header=TRUE)
pat_ids = ukb_df$`df[, ignore_cols]`
outcomes_path = "NeuroPM/outcomes_analysis/ukb_outcomes.csv"
df_outcomes_selected = add_outcomes(pat_ids, outcomes_path)
write.csv(df_outcomes_selected, "NeuroPM/outcomes_analysis/ukb_num_norm_outcomes.csv", row.names = FALSE)