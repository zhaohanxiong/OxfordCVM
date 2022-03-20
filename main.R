library(xlsx)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# The code below is refactored from the DP_prep_par.R
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
cardiac_seg = read.csv("../ukbreturn1886/UK Biobank 
                                      Enhancement Cardiac Phenotypes.csv")
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

# cardiac
variables.b = vars_2[vars_2 %in% c(bb_CMR_vars, bb_art_vars, bb_car_vars)]

# brain
variables.c = vars_2[vars_2 %in% bb_BMR_vars]

# cardiac + brain + carotid ultrasound
variables.d = vars_2[vars_2 %in% c(bb_CMR_vars,bb_BMR_vars,
                                   bb_art_vars,bb_car_vars,Sex,Age)]

### population variables
# all
data_prep.1 = df[df$Record.Id %in% 
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

### target/background criteria
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
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
DP_prep_cross3 <- function(data_dp,
                           vars_included,
                           target_Record.Id,
                           background_Record.Id,
                           perc_mis,
                           cov) {
  
  if(missing(perc_mis)) perc_mis = 5
  
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
  
} ## also exclude subjects with >??% missing data (default=5%)

bb_subset <- function(dataset,
                      n_target=1000,
                      n_background=1000,
                      n_between=200){
  
  target_Record.Id = dataset$Record.Id[dataset$bp_group == 2]
  background_Record.Id = dataset$Record.Id[dataset$bp_group == 1]
  between_Record.Id = dataset$Record.Id[dataset$bp_group == 0]
  
  c = sort(apply(dataset[dataset$Record.Id %in% target_Record.Id, ], 
                 MARGIN = 1, 
                 function(x) sum(is.na(x))
                 )
           )
  d = dataset[names(c[1:n_target]), "Record.Id"]
  
  f = sort(apply(dataset[dataset$Record.Id %in% background_Record.Id, ], 
                 MARGIN = 1,
                 function(x) sum(is.na(x))
                 )
           )
  g = dataset[names(f[1:n_background]), "Record.Id"]
  
  i = sort(apply(dataset[dataset$Record.Id %in% between_Record.Id, ],
                 MARGIN = 1,
                 function(x) sum(is.na(x))
                 )
           )
  j = dataset[names(i[1:n_between]), "Record.Id"]
  
  Record.Id_subset = dataset$Record.Id[dataset$Record.Id %in% 
                                        c(as.character(d),
                                          as.character(g),
                                          as.character(j))
                                       ]
 
  return(Record.Id_subset)

}

bb_DP_prep2 = function(dataset,
                       target_Record.Id,
                       background_Record.Id,
                       between_Record.Id,
                       variables, 
                       n_target=1000, n_background=1000, n_between=200) {

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

## 1.a.1 = all subjects, all variables, 140/90 vs <120/80
model1.a.1 = bb_DP_prep2(data_prep.1, 
                         target_Record.Id.1, background_Record.Id.1, 
                         between_Record.Id.1, variables.a)
#View(model1.a.1$fulldata)

write.xlsx(model1.a.1$sub, "data_sub.xlsx")





















