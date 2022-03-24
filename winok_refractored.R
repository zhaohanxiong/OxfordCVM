library(xlsx)
library(dplyr)
library(ggplot2)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# The code below is refactored from the DP_prep_par.R
#     This script generates the variables column names we want 
#     to keep for further analysis
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

### Load data
# read data in
df = read.csv("../bb_data.csv", 
        header=TRUE, stringsAsFactors=FALSE)
df_vars = read.csv("../bb_variablelist.csv", 
              header=TRUE, stringsAsFactors=FALSE)

# clean up some column names
names(df) = gsub("X", "", names(df))
names(df) = sub("\\.", "-", names(df))
names(df) = sub("Record-Id", "Record.Id", names(df))

df$Record.Id = paste0("BB", df$Record.Id)
df$StudyName = "BB"

# change some data types
df_vars$Field = as.character(df_vars$Field)
df_vars$FieldID = as.character(df_vars$FieldID)

### Get variable names
# get the bulk variables
bulkvars = df_vars$FieldID[
              df_vars$ItemType=="Bulk"|
              df_vars$ItemType=="Samples"|
              df_vars$ItemType=="Records"]
bulkvars = grep(
              paste0("^", paste0(bulkvars, collapse = "-|^") ,"-"),
              names(df), 
              value=TRUE)

# only include primary variables - exclude auxiliary and supplementary 
# variables
stratavars = df_vars$FieldID[
                df_vars$Strata=="Auxiliary"|
                df_vars$Strata=="Supporting"]
stratavars = grep(
                paste0("^", paste0(stratavars, collapse="-|^"), "-"), 
                names(df), 
                value=TRUE)

# Demographic
Sex = "31-0.0"
Age = grep("^21003-", names(df), value=TRUE)

# other, date of imaging visit 
StudyDate = grep("^53-", names(df), value=TRUE)

# blood pressure variables
BPSys = grep("^4080-", names(df), value=TRUE)
BPSys2 = grep("^93-", names(df), value=TRUE)
BPDia = grep("^4079-", names(df), value=TRUE)
BPDia2 = grep("94-2.0", names(df), value=TRUE)

# diagnosis variables
bb_dis_vars = df_vars$FieldID[df_vars$Category > 42 & 
                              df_vars$Category < 51]
bb_dis_vars = bb_dis_vars[seq(1, length(bb_dis_vars), 2)] # even numbers contain dates
bb_dis_vars = grep(
                paste0("^", paste0(bb_dis_vars, collapse="-|^"), "-"), 
                names(df), 
                value=TRUE)
bb_dis_vars = c(bb_dis_vars, 
                grep(
                  "^40000-|^40001-|^40002-|^40007-", 
                  names(df), 
                  value=TRUE)
                ) # add cause of death

## medication variables
bb_med_vars = df_vars$FieldID[df_vars$Category=="100045"]
bb_med_vars = grep(
                paste0("^", paste0(bb_med_vars, collapse="-|^"), "-"),
                names(df),
                value=TRUE)

# brain MR variables
bb_BMR_vars = df_vars$FieldID[df_vars$Category==110 |
                              df_vars$Category==112 |
                              df_vars$Category==1102 |
                              df_vars$Category==109 |
                              df_vars$Category==134 |
                              df_vars$Category==135 |
                              df_vars$Category==1101] 
bb_BMR_vars = grep(
                paste0("^", paste0(bb_BMR_vars, collapse="-|^"), "-"),
                names(df),
                value=TRUE)
excl = grep( 
          paste0("^", 
            paste0(c("20216","25756","25757","25757",
                     "25758","25759","25746"), collapse="-|^"),
            "-"), 
          bb_BMR_vars, value=TRUE) # exclude certain variables
bb_BMR_vars = bb_BMR_vars[!bb_BMR_vars %in% excl]
bb_BMR_vars = bb_BMR_vars[!bb_BMR_vars %in% bulkvars]

# cardiac MR variables
# removed all blood pressure related variables, kept cardiac 
# structure and heart rate variables, kept pulse pressure
bb_CMR_vars = grep(
                "^22426-|^22425-|^22424-|^22420-|^22421-|^22422-
                 |^22423-|^12702-|^12682-|^12673-|^12679-|^12676-
                 |^12686-|^12685-|^22427-",
                names(df),
                value=TRUE)
bb_CMR_vars = bb_CMR_vars[!bb_CMR_vars %in% bulkvars]
cardiac_seg = read.csv("../ukbreturn1886/UK Biobank Imaging Enhancement Cardiac Phenotypes.csv")
bb_CMR_vars = c(bb_CMR_vars,
                names(cardiac_seg)[2:length(names(cardiac_seg))])

# abdominal MR variables
bb_AMR_vars = df_vars$FieldID[df_vars$Category==126 | 
                              df_vars$Category==149]
bb_AMR_vars = grep(
                paste0("^", paste0(bb_AMR_vars, collapse="-|^"), "-"),
                names(df),
                value=TRUE)
excl = grep(
          paste0("^", paste0(c("22412", "22414"), collapse="-|^"), "-"),
          bb_AMR_vars,
          value=TRUE) # exclude certain variables
bb_AMR_vars = bb_AMR_vars[!bb_AMR_vars %in% excl]
bb_AMR_vars= bb_AMR_vars[!bb_AMR_vars %in% bulkvars]

# Body composition variables
bb_bodycomp_vars = df_vars$FieldID[df_vars$Category==124 |
                                   df_vars$Category==125 |
                                   df_vars$Category==100009 |
                                   df_vars$Category==170]
bb_bodycomp_vars = grep(
                      paste0("^", 
                          paste0(bb_bodycomp_vars, collapse="-|^"), 
                          "-"), 
                      names(df),
                      value=TRUE)

# arterial stiffness variables
bb_art_vars = df_vars$FieldID[df_vars$Category==100007]
excl = grep("^4186-|^2404-|^2405-", bb_art_vars, value=TRUE)
bb_art_vars = bb_art_vars[!bb_art_vars %in% excl]
bb_art_vars = bb_art_vars[!bb_art_vars %in% bulkvars]

# carotid ultrasound variables
bb_car_vars = df_vars$FieldID[df_vars$Category==101]

bb_car_vars = grep(
                paste0("^", paste0(bb_car_vars,collapse="-|^") ,"-"),
                names(df),
                value=TRUE)
excl = grep(
          paste("^", 
                paste(c("22682","22683","22684","22685","12291","12292"), 
                  collapse="-|^"),
                "-"),
          bb_car_vars,
          value=TRUE)
bb_car_vars = bb_car_vars[!bb_car_vars %in% excl]
bb_car_vars = bb_car_vars[!bb_car_vars %in% bulkvars]

# spirometry variables
bb_spir_vars = grep(
                  "^20151-|^20150-|^20153-|^20258-|^20156-|^20154-",
                  names(df),
                  value=TRUE)

# ECG variables
bb_ecgrest_vars = grep(
                    "^12336-|^12338-|^22334-|^22330-|^22338-|^12340-|
                     ^22331-|^22332-|^22333-|^22335-|^22336-|^22337-",
                    names(df),
                    value=TRUE)

# percentages of blood are coded with tens, the other variables
# refer to the methods of sample analysis
bb_blood_vars = df_vars$FieldID[df_vars$Category==100081 |
                                df_vars$Category==17518 |
                                df_vars$Category==100083]
bb_blood_vars = grep(
                  paste0("^", paste0(bb_blood_vars, collapse="-|^"), "-"),
                  names(df),
                  value=TRUE)
excl = grep("^30505-|^30515-|^30525-|^30535-", bb_blood_vars, value=TRUE)
bb_blood_vars = bb_blood_vars[!bb_blood_vars %in% excl]

# antropometric variables
#range = number_range(46, 51)
#bb_antro_vars = grep(range, names(df), value=TRUE)

### Combine variables together
vars = c("eid", "12187-2.0", Age, Sex, StudyDate, BPSys, BPSys2, BPDia,
         BPDia2,bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,
         bb_art_vars,bb_blood_vars,bb_car_vars, bb_spir_vars,
         bb_ecgrest_vars,bb_dis_vars,bb_med_vars) # bb_antro_vars
vars = vars[!vars %in% c(bulkvars, stratavars)]

vars_2 = c(grep("\\-2.0",
                c(Age, StudyDate,BPSys,BPSys2,BPDia,BPDia2,
                  bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,
                  bb_art_vars,bb_blood_vars,bb_car_vars,
                  bb_ecgrest_vars), # bb_antro_vars
                value=TRUE),
           grep("\\-2.", bb_CMR_vars, value=TRUE),
           bb_spir_vars, bb_dis_vars, bb_med_vars)
vars_2 = vars[!vars_2 %in% c(bulkvars, stratavars)]

# all
variables.a = vars_2[vars_2 %in% c(bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,
                                   bb_bodycomp_vars,bb_art_vars,
                                   bb_car_vars,bb_blood_vars,bb_spir_vars,
                                   bb_ecgrest_vars,Sex,Age)]

# # cardiac
# variables.b = vars_2[vars_2 %in% c(bb_CMR_vars, bb_art_vars, bb_car_vars)]
# 
# # brain
# variables.c = vars_2[vars_2 %in% bb_BMR_vars]
# 
# # cardiac + brain + carotid ultrasound
# variables.d = vars_2[vars_2 %in% c(bb_CMR_vars,bb_BMR_vars,
#                                    bb_art_vars,bb_car_vars,Sex,Age)]

### population variables
# all (get all data without missing blood pressure values)
data_prep.1 = df[df$Record.Id %in%  # df[!is.na(df$`BPSys-2.0`), ]
                   df$Record.Id[!is.na(df$`BPSys-2.0`)], ]

# # only women
# data_prep.2 = df[df$Record.Id %in% 
#                    df$Record.Id[!is.na(df$`BPSys-2.0`) & df[,Sex]=="0"]
#                  , ]
# 
# # only men
# data_prep.3 = df[df$Record.Id %in% 
#                    df$Record.Id[!is.na(df$`BPSys-2.0`) & df[,Sex]=="1"]
#                  , ]
# 
# # exclude those with heart attack/angina/stroke at time of imaging
# data_prep.4 = df[df$Record.Id %in% 
#                    df$Record.Id[
#                          !is.na(df$`BPSys-2.0`) & 
#                          (df$`6150-2.0` < 0 |
#                           df$`6150-2.0` > 3 |
#                           is.na(df$`6150-2.0`)) & 
#                          (df$diag_min_datedif > 0 | 
#                           is.na(df$diag_min_datedif))
#                       ]
#                  , ]
# 
# # only women: exclude those with heart attack/angina/stroke at 
# # time of imaging
# data_prep.5 = df[df$Record.Id %in% 
#                    df$Record.Id[
#                      !is.na(df$`BPSys-2.0`) & 
#                      df[,Sex]=="0" & 
#                     (df$`6150-2.0` < 0 | 
#                      df$`6150-2.0` > 3 | 
#                      is.na(df$`6150-2.0`)) & 
#                     (df$diag_min_datedif > 0 | 
#                       is.na(df$diag_min_datedif))
#                     ]
#                  , ]

### target/background criteria (patient IDs of each group)
# > 140/80
target_Record.Id.1 = df$Record.Id[df$`BPSys-2.0` > 140 | 
                                       df$`BPDia-2.0` > 90]
background_Record.Id.1 = df$Record.Id[df$`BPSys-2.0` < 120 & 
                                           df$`BPDia-2.0` < 80]
between_Record.Id.1 = df$Record.Id[
                          -which(df$Record.Id %in% 
                                   c(as.character(background_Record.Id.1),
                                     as.character(target_Record.Id.1))
                                 )
                          ]

# # > 160/100
# target_Record.Id.2 = df$Record.Id[df$`BPSys-2.0` > 160 |
#                                   df$`BPDia-2.0` > 100]
# background_Record.Id.2 = df$Record.Id[df$`BPSys-2.0` < 120 &
#                                       df$`BPDia-2.0` < 80]
# between_Record.Id.2 = df$Record.Id[
#                           -which(df$Record.Id %in%
#                                    c(as.character(background_Record.Id.2),
#                                      as.character(target_Record.Id.2))
#                                  )
#                           ]
# 
# # target: event at time of imaging. Background: no event, no event on follow
# target_Record.Id.3 = df$Record.Id[df$`6150-2.0` > 0 & df$`6150-2.0` < 4]
# background_Record.Id.3 = df$Record.Id[(df$`6150-2.0` < 0 |
#                                        df$`6150-2.0` == 4) &
#                                       (df$`6150-3.0` < 0 |
#                                        df$`6150-3.0`==4)]
# between_Record.Id.3 = df$Record.Id[
#                           -which(df$Record.Id %in%
#                                    c(as.character(background_Record.Id.3),
#                                      as.character(target_Record.Id.3))
#                                  ) 
#                           ]
# 
# # target: no event at time of imaging, but at follow-up. Background: no event,
# # no event on follow-up, low BP
# target_Record.Id.4 = df$Record.Id[
#                           (df$`6150-2.0` > 0 & df$`6150-2.0` < 4) &
#                           (df$`6150-3.0` > 0 | df$`6150-3.0` < 4)]
# background_Record.Id.4 = df$Record.Id[
#                                 (df$`6150-2.0` < 0 | df$`6150-2.0` == 4) &
#                                 (df$`6150-3.0`<0|df$`6150-3.0` == 4)]
# between_Record.Id.4 = df$Record.Id[
#                             -which(df$Record.Id %in%
#                                      c(as.character(background_Record.Id.4),
#                                        as.character(target_Record.Id.4))
#                                    )
#                             ]

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# The code below is refactored from the DP_prep2.R
#     This script obtains a filtered dataset based on the variables
#     generated in the script above, and also filters the dataset for 
#     to remove rows with missing values.
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
DP_prep_cross3 <- function(data_dp,
                           vars_included,
                           target_Record.Id,
                           background_Record.Id,
                           cov,
                           perc_mis = 5) {
  
  # This function cleans up the raw UKB data, removes columns
  # with too many missing data, keeps only the relevant variables
  # defined above, and also arranges the blood pressure groups
  # into 0 = between, 2 = diseased (target), 1 = background
  
  # exclude columns with majority NA, for studies separately
  for (study in unique(data_dp$StudyName)) {

    a = which(colMeans(is.na(
                data_dp[data_dp$StudyName == study, 
                        which(names(data_dp) %in% vars_included)]
                )) > 0.5)
          
    if (length(a) > 0) {
      data_dp = data_dp[, -which(names(data_dp) %in% names(a))]
    }
    
    # exclude columns with only NA, for studies separately
    b = which(colSums(
                  is.na(data_dp[data_dp$StudyName == study, ]) |
                  data_dp[data_dp$StudyName == study, ] == 0
                ) == nrow(data_dp[data_dp$StudyName == study, ])
              )
    
    if (length(b) > 0) {
      data_dp = data_dp[, -which(names(data_dp) %in% names(b))]
    }
    
  }
  
  # remove rows with more than ... missing data
  # exclude subjects with >??% missing data (default=5%)
  c = apply(data_dp, MARGIN = 1, function(x) sum(is.na(x)))
  d = c < (length(c)/100*perc_mis)
  data_dp = data_dp[d, ]
  
  # code bp_group
  data_dp$bp_group = 0
  data_dp$bp_group[data_dp$Record.Id %in% target_Record.Id] = 2
  data_dp$bp_group[data_dp$Record.Id %in% background_Record.Id] = 1
  
  colnames = names(data_dp)[names(data_dp) %in% vars_included]
  data_dp = data_dp[,c("Record.Id", "StudyName", colnames, "bp_group")]
  
  list = list("data" = data_dp)
  
  if(missing(cov) == FALSE) {
    
    ## delete subjects with missing data for covariates
    data_dp = data_dp[complete.cases(data_dp[, cov]), ]
    cov_2 = data_dp[, cov]
    list[[cov]] = cov_2
    
  }
  
  return(list)
  
}

bb_subset <- function(dataset,
                      n_target=1000,
                      n_background=1000,
                      n_between=200) {
  
  # This function subsets the data by extracting N samples from each
  # of the groups target, background, and between
  
  target_Record.Id = dataset$Record.Id[dataset$bp_group == 2]
  background_Record.Id = dataset$Record.Id[dataset$bp_group == 1]
  between_Record.Id = dataset$Record.Id[dataset$bp_group == 0]
  
  # get the first N data by sorting entire dataset by target
  c = sort(apply(dataset[dataset$Record.Id %in% target_Record.Id, ], 
                 MARGIN = 1, 
                 function(x) sum(is.na(x))
                 )
           )
  d = dataset[names(c[1:n_target]), "Record.Id"]
  
  # get the first N data by sorting entire dataset by background
  f = sort(apply(dataset[dataset$Record.Id %in% background_Record.Id, ], 
                 MARGIN = 1,
                 function(x) sum(is.na(x))
                 )
           )
  g = dataset[names(f[1:n_background]), "Record.Id"]
  
  # get the first N data by sorting entire dataset by between
  i = sort(apply(dataset[dataset$Record.Id %in% between_Record.Id, ],
                 MARGIN = 1,
                 function(x) sum(is.na(x))
                 )
           )
  j = dataset[names(i[1:n_between]), "Record.Id"]
  
  # combine the 3 individual sets
  Record.Id_subset = dataset[dataset$Record.Id %in% 
                              c(as.character(d),
                                as.character(g),
                                as.character(j))
                             ,]

  return(Record.Id_subset)

}

bb_DP_prep2 = function(dataset,
                       target_Record.Id,
                       background_Record.Id,
                       between_Record.Id,
                       variables, 
                       n_target=1000, n_background=1000, n_between=200) {

  # this function uses the two functions above DP_prep_cross3 and 
  # bb_subset to process the raw data given a set of variables,
  # background, and targets
  
  target_Record.Id = target_Record.Id[!is.na(target_Record.Id)]
  background_Record.Id = background_Record.Id[!is.na(background_Record.Id)]
  between_Record.Id = between_Record.Id[!is.na(between_Record.Id)]
  
  data_dp = DP_prep_cross3(dataset, variables, 
                           target_Record.Id, 
                           background_Record.Id)

  data = list("fulldata" = data_dp$data)
  data$cov = data_dp$cov
  
  # take the 1000 target and 1000 background subjects 
  # with most complete data + 200 in between
  data$sub = bb_subset(data$fulldata, n_target, n_background, n_between)

  return(data)
  
}

write2neuroPM = function(dat, dat_filename) {
  
  # this function writes dataframes/vectors to the format
  # required by the neuroPM toolbox
  
  write.table(formatC(as.matrix(dat), format = "e", digits = 7),
              dat_filename,
              row.names=FALSE, col.names=FALSE, quote=FALSE,
              sep="\t")

}

# 1.a.1 = all subjects, all variables, 140/90 vs <120/80
# produce full filtered dataset and subset of filtered dataset
model1.a.1 = bb_DP_prep2(data_prep.1,
                         target_Record.Id.1,
                         background_Record.Id.1,
                         between_Record.Id.1,
                         variables.a)

dat_out = model1.a.1$sub[,3:ncol(model1.a.1$sub)]
dat_out[is.na(dat_out)] = -999999

# write to output for neuroPM toolbox
if (FALSE) {
  write2neuroPM(dat_out,
                "../NeuroPM_cPCA_files/cPCA_data.txt")
  write2neuroPM(which(dat_out$bp_group == 1),
                "../NeuroPM_cPCA_files/cPCA_background.txt")
  write2neuroPM(which(dat_out$bp_group == 2),
                "../NeuroPM_cPCA_files/cPCA_target.txt")
}

stop("Break in Script, comment to disable")
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# The code below is refactored from the DP_results.R
#   Plots a bunch of results based on what variables we want to see
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# read in neuroPM toolbox output
pseudotimes = read.table("../NeuroPM_cPCA_files/subset run/cTI_IDs_pseudotimes_pseudopaths_cPCA_data.txt")
#pseudotimes = read.table("../NeuroPM_cPCA_files/cTI_IDs_pseudotimes_pseudopaths_cPCA_data.txt")
names(pseudotimes) = c("row.id","V1_pseudotimes","traj1","traj2")

# merge with UKB data
#pseudotimes = merge(pseudotimes, df, all.x=TRUE, by = "Record.Id")
pseudotimes = cbind(pseudotimes, model1.a.1$sub) # temp temp temp!

# plot per bp_group
pdf("p1.pdf", width = 20, height = 10)
ggplot(pseudotimes, aes(y=V1_pseudotimes,
                          x=as.factor(bp_group),
                          fill=as.factor(bp_group))) + 
    geom_boxplot() + 
    geom_point(aes(fill=as.factor(bp_group)),
               position=position_jitterdodge()) + 
    scale_fill_discrete(breaks=c("0","1","2"),
                        labels=c("Other","Healthy","Disease")) + 
    ggtitle("all subjects all variables: disease category and BP") + 
    theme(legend.title = element_blank(),
          axis.text.x = element_blank(),
          axis.title.x=element_blank())
dev.off()

# table with multiple outcome measures
outvars = bb_BMR_vars

table = NULL
for (outvar in outvars){
  formula = as.formula(paste0("`", outvar, "`" , "~", "V1_pseudotimes"))
  linMod = glm(formula, data = pseudotimes)
  
  # Summary of the analysis
  b = unname(summary(linMod)$coefficients["V1_pseudotimes",])
  c = c(outvar, b)
  if (c[5] < 0.05){
    table = rbind(table,c)
  }
}

colnames(table) = c("Variable", "Estimate", "Std.Error", "t value", "Pr(>|t|")
table = as.data.frame(table)
rownames(table) = table$Variable
print(table)

r = cor(pseudotimes[, "V1_pseudotimes"],
        pseudotimes[, outvar], 
        use = "pairwise.complete.obs")
f = ggplot(pseudotimes, aes_string(x = "V1_pseudotimes", y = outvar)) +
    geom_point()+
    geom_smooth(method = "lm")+
    theme(legend.position = "top")+
    ggtitle(paste("r=", r))
print(f)

table$Variable=gsub("-2.0","",table$Variable)
table$Variable=gsub("-0.0","",table$Variable)

for (var in table$Variable){
  if(var %in% variablelist$FieldID){
    table$Variable[table$Variable==var] = rename2(variablelist,
                                                  var, 
                                                  "FieldID", 
                                                  "Field")
  }
}
