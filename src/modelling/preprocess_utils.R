# load dependencies
library(data.table)

load_raw_ukb_patient_dataset = function(path_ukb_data, path_ukb_vars) {
  
  # This function takes two file paths, the path to the UKB patient
  # information spreadsheet, and the path to the variable list used in
  # the UKB. The datasets are read and loaded, and then slightly
  # tidied and returned
  
  # read data in
  df = fread(path_ukb_data, header=TRUE)
  df_vars = fread(path_ukb_vars, header=TRUE)
  
  # convert to dataframe
  df = data.frame(df)
  df_vars = data.frame(df_vars)
  
  # clean up some column names
  names(df) = gsub("X", "", names(df))
  names(df) = sub("\\.", "-", names(df))
  names(df) = sub("Record-Id", "Record.Id", names(df))
  
  # set record ID column
  df$Record.Id = paste0(df$Record.Id, df$eid)
  df$StudyName = "BB"

  # set blood pressure variables if not present already
  if (length(grep("BPSys", colnames(df))) == 0) {

    df[["BPSys-2.0"]] = ifelse(is.na(df[["4080-2.0"]]), df[["93-2.0"]], df[["4080-2.0"]])
    df[["BPDia-2.0"]] = ifelse(is.na(df[["4079-2.0"]]), df[["94-2.0"]], df[["4079-2.0"]])

  }
  
  # add sex information
  df[["Sex"]] = as.numeric(df[["31-0.0"]])
  
  # change some data types
  df_vars$Field = as.character(df_vars$Field)
  df_vars$FieldID = as.character(df_vars$FieldID)
  
  return(list(ukb_data = df, ukb_vars = df_vars))
  
}

get_ukb_subset_column_names = function(df, df_vars,
                                       subset_option="all") {
  
  # Variable extraction key values compied by Winok
  # This function uses the ukb patient spreadsheet and 
  # extracts the columns needed for further analysis, we then subset
  # these variables depending on the subset_option (all, cardiac, brain,
  # cardiac + brain + carotid ultrasound) and output the subseted set 
  # of column names 

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

  # Centre location
  loc_var = c("54-0.0", "54-1.0", "54-2.0", "54-3.0")
  
  # Demographic
  Sex = "31-0.0"
  Age = grep("21003-2", names(df), value=TRUE)
  
  # blood pressure variables (in addition)
  #bp_var1 = grep("12674", names(df), value=TRUE) # systolic brachial PWA
  #bp_var2 = grep("12675", names(df), value=TRUE) # diastolic brachial PWA 
  #bp_var3 = grep("12677", names(df), value=TRUE) # central systolic PWA
  #bp_var4 = grep("12697", names(df), value=TRUE) # systolic brachial 
  #bp_var5 = grep("12698", names(df), value=TRUE) # diastolic brachial
  #bp_var6 = grep("^93-",  names(df), value=TRUE) # sys manual
  #bp_var7 = grep("^94-",  names(df), value=TRUE) # dia manual
  bp_var8 = grep("^4080",  names(df), value=TRUE) # sys automated
  bp_var9 = grep("^4079",  names(df), value=TRUE) # dia automated
  bp_var = c(bp_var8, bp_var9)
  bp_var = bp_var[!grepl("-3.|-4.", bp_var)]

  # medication
  med_bp1 = grep("6153", names(df), value=TRUE) # cholesterol, blood pressure, diabetes
  med_bp2 = grep("6177", names(df), value=TRUE) # cholesterol, blood pressure, diabetes
  med_bp = c(med_bp1, med_bp2)
  med_bp = med_bp[!grepl("-3.|-4.", med_bp)]
  
  # history of heart attack, angina, stroke
  Event = grep("6150", names(df), value=TRUE)
  Event = Event[!grepl("-3.|-4.", Event)]
  
  # other, date of imaging visit 
  StudyDate = grep("^53-", names(df), value=TRUE)
  
  # diagnosis variables
  bb_dis_vars = df_vars$FieldID[df_vars$Category > 42 & 
                                  df_vars$Category < 51]
  bb_dis_vars = bb_dis_vars[seq(1, length(bb_dis_vars), 2)] # even numbers contain dates
  bb_dis_vars = grep(
                    paste0("^", paste0(bb_dis_vars, collapse="-|^"), "-"), 
                    names(df), 
                    value=TRUE)
  bb_dis_vars = c(bb_dis_vars, 
                  grep("^40000-|^40001-|^40002-|^40007-", 
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
  bb_BMR_vars = df_vars$FieldID[df_vars$Category==110 |  # 17 features
                                df_vars$Category==112 |  # 2 features
                                df_vars$Category==1102 | # 14 features
                                df_vars$Category==109 |  # 15 features
                                df_vars$Category==134 |  # 428 features
                                df_vars$Category==135 |  # 241 features
                                df_vars$Category==1101   # 138 features
                                ]
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
  bb_CMR_vars = c(bb_CMR_vars,
                  c("LVM__g_","LVEDV__mL_","RVEDV__mL_","LVEF","RVEF"))

  # abdominal MR variables
  bb_AMR_vars = df_vars$FieldID[df_vars$Category==126 | df_vars$Category==149]
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
  bb_bodycomp_vars = df_vars$FieldID[df_vars$Category==124 |    # 12 features
                                     df_vars$Category==125 |    # 48 features
                                     df_vars$Category==100009 | # 63 features
                                     df_vars$Category==170
                                    ]
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
  bb_blood_vars = df_vars$FieldID[df_vars$Category==100081 | # 30 features
                                  df_vars$Category==17518 |  # 28 features
                                  df_vars$Category==100083   # 7 features
                                 ]
  bb_blood_vars = grep(
                      paste0("^", paste0(bb_blood_vars, collapse="-|^"), "-"),
                      names(df),
                      value=TRUE)
  excl = grep("^30505-|^30515-|^30525-|^30535-", bb_blood_vars, value=TRUE)
  bb_blood_vars = bb_blood_vars[!bb_blood_vars %in% excl]
  
  # Combine variables together based on input option
  if (subset_option == "custom") {

    vars_subset_cols = c(bp_var,med_bp,loc_var,Sex,Age,Event,
                         bb_CMR_vars,bb_BMR_vars,
                         bb_bodycomp_vars,bb_blood_vars)

  } else if (subset_option == "all") {
    
    # all
    vars_subset_cols = c(bp_var,med_bp,loc_var,Sex,Age,Event,
                         bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,bb_car_vars,
                         bb_bodycomp_vars,bb_art_vars,bb_blood_vars,
                         bb_spir_vars,bb_ecgrest_vars)
    
  } else if (subset_option == "cardiac") {
    
    # cardiac
    vars_subset_cols = c(bp_var,med_bp,Sex,Age,Event,
                         bb_CMR_vars,bb_art_vars,bb_car_vars)
    
  } else if (subset_option == "brain") {
    
    # brain
    vars_subset_cols = c(bb_BMR_vars,bp_var,med_bp,Sex,Age,Event)
    
  } else if (subset_option == "cardiac + brain + carotid ultrasound") {
    
    # cardiac + brain + carotid ultrasound
    vars_subset_cols = c(bb_CMR_vars,bb_BMR_vars,bp_var,med_bp,
                         bb_art_vars,bb_car_vars,Sex,Age,Event)
    
  } else {
    warning("Wrong Subset Option Error")
  }
  
  # write variable groups to output by arranging by group and writing to csv
  vars = c(bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,bb_art_vars,
           bb_car_vars,bb_blood_vars,bb_spir_vars,bb_ecgrest_vars,
           bp_var,med_bp,Sex,Age,Event)
  vars = paste0("X", gsub("-", "\\.", vars))
  var_groups = c(rep("Cardiac_MR",         length(bb_CMR_vars)),
                 rep("Brain_MR",           length(bb_BMR_vars)),
                 rep("Abdominal_MR",       length(bb_AMR_vars)),
                 rep("Body_Composition",   length(bb_bodycomp_vars)),
                 rep("Arterial_Stiffness", length(bb_art_vars)),
                 rep("Carotid_Ultrasound", length(bb_car_vars)),
                 rep("Blood",              length(bb_blood_vars)),
                 rep("Spirometry",         length(bb_spir_vars)),
                 rep("ECG",                length(bb_ecgrest_vars)),
                 rep("Blood_Pressure",     length(bp_var)),
                 rep("Medication",         length(med_bp)),
                 rep("Demographics",       length(c(Sex, Age))),
                 rep("Event",              length(Event))
                 )
  
  var_output = data.frame(ukb_var = vars, var_group = var_groups)
  
  # add back useful columns involving blood pressure
  vars_subset_cols = c("Record.Id","BPSys-2.0","BPDia-2.0","Sex",vars_subset_cols)
                         
  return(list(vars = vars_subset_cols, var_df = var_output))
  
}

get_ukb_subset_rows = function(df, subset_option="all") {

  # this function extracts the rows (patients) we want to analyse
  # and returns the indices of the rows. here we focuse on the blood
  # pressure mainly to ensure no missing values are in the subset
  
  # for prior events use latest data, ignore -3, remove all 1, 2, 3, keep -7, 4
  # note this is repeated again below for proper variable assignment
  events = apply(df[,grep("6150", colnames(df))], 1,
                 function(x) ifelse(all(is.na(x)),
                                    NA,
                                    unname(x[max(which(!is.na(x)))])
                                    ))
  
  if (subset_option == "all") {
    
    # all
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & !is.na(df[,"BPDia-2.0"]))
    
  } else if (subset_option == "women") {
    
    # women
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & !is.na(df[,"BPDia-2.0"]) & 
                        df[,"31-0.0"] == 0)
    
  } else if (subset_option == "men") {
    
    # men
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & !is.na(df[,"BPDia-2.0"]) & 
                        df[,"31-0.0"] == 1)
    
  } else if (subset_option == "no heart attack, angina, stroke") {
    
    # exclude those with heart attack/angina/stroke at time of imaging
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & !is.na(df[,"BPDia-2.0"]) & 
                        (events == -7 | events == 4))

  } else if (subset_option == "women no heart attack, angina, stroke") {
    
    # only women: exclude those with heart attack/angina/stroke at time 
    #             of imaging
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & !is.na(df[,"BPDia-2.0"]) & 
                        df[,"31-0.0"] == 0 &
                        (events == -7 | events == 4))
    
  } else {
    warning("Wrong Subset Option Error")
  }
  
  # final missing value cleaning
  subset_rows = subset_rows[!is.na(subset_rows)]
  
  return(subset_rows)
  
}

return_cols_rows_filter_df = function(df, cols, rows) {
  
  # given the UKB dataset and a set of columns and rows, subset the dataset
  # and returned the subsetted version.
  
  # only keep unique rows/columns, duplicate columns 
  cols = unique(cols)
  rows = unique(rows)

  # subset rows
  df = df[rows[rows <= nrow(df)], ]
  
  # subset columns
  df = df[, cols[cols %in% colnames(df)]]

  return(df)
  
}

return_collate_variables = function(df) {
  
  # given the UKB dataset, perform a set of custom column-collation steps, and
  # assign these into custom new columns
  
  # helper function which retrieves value from right-most column in a row
  get_latest_val = function(x_row) {
    x_row = ifelse(all(is.na(x_row)),
                   NA, unname(x_row[max(which(!is.na(x_row)))]))
    return(x_row)
  }
  
  # preprocess blood pressure variables, set upper and lower bound thresholds
  # for patients, use upper bound for background, lower bound for disease
  bp_sys = df[, grep("BPSys-2.0|12674|12677|12697|^93-|4080", colnames(df))]
  df$bp_sys_upper = apply(bp_sys, 1, function(x) max(x, na.rm = TRUE))
  df$bp_sys_lower = apply(bp_sys, 1, function(x) min(x, na.rm = TRUE))
  
  bp_dia = df[, grep("BPDia-2.0|12675|12698|^94-|4079", colnames(df))]
  df$bp_dia_upper = apply(bp_dia, 1, function(x) max(x, na.rm = TRUE))
  df$bp_dia_lower = apply(bp_dia, 1, function(x) min(x, na.rm = TRUE))
  
  # preprocess medication variables, ignore -1, -3, remove all 2, keep rest
  df_med1 = df[, grep("6153", colnames(df))]
  df_med1[df_med1 == -1] = NA
  df_med1[df_med1 == -3] = NA
  df_med1 = apply(df_med1, 1, function(x) get_latest_val(x))
  
  df_med2 = df[, grep("6177", colnames(df))]
  df_med2[df_med2 == -1] = NA
  df_med2[df_med2 == -3] = NA
  df_med2 = apply(df_med2, 1, function(x) get_latest_val(x))

  df$bp_medication = apply(cbind(df_med1, df_med2), 1,
                                                function(x) get_latest_val(x))
  
  # for prior events use latest data, ignore -3, remove all 1, 2, 3, keep -7, 4
  df_6150 = df[, grep("6150", colnames(df))]
  df_6150[df_6150 == -3] = NA

  df$events = apply(df_6150, 1, function(x) get_latest_val(x))
  
  # remove columns which were used for collation
  df = df[, !grepl(paste0("12674|12677|12697|^93-|4080|",
                          "12675|12698|^94-|4079|6153|6177|6150"), colnames(df))]

  return(df)
  
}

return_remove_outlier = function(data) {
  
  # given a matrix, remove values in each column (representing each feature)
  # which are more than 3 standard deviations away from the mean, assuming
  # the values are normally distributed. values are removed by setting to NA
  
  # use z_score to remove values which are more than 3 standard deviations
  # away from the mean (not within 99.7% of values), performed by column
  data = apply(data, 2, function(x) {
    
                            # compute mean and sd
                            mean_val = mean(x, na.rm=TRUE)
                            std = sd(x, na.rm=TRUE)
                            z_score = abs(x - mean_val)/std
                            
                            # set outliers as NA
                            x[z_score > 3] = NA
                            return(x)
                          
                        })
  
  return(data)
  
}

return_clean_df = function(df, threshold_col, threshold_row, ignore_cols = c()) {
  
  # apply filtering to clean the dataset and remove rows (patients) with many
  # missing values from the dataset and return the fully cleaned dataset
  # the thresholds are the upper boundaries for how many missing data
  # we allow in each column/row (thresholds are not in percentages)
  # this function also includes an array defining character columns which
  # can be masked out for further cleaning of 0/NA values
  
  # display % missing values before cleaning
  print(sprintf("Percentage NA Before Cleaning: %0.1f%%", 
                                          sum(is.na(df))/prod(dim(df))*100))
  
  # turn empty string cells in to NA
  df[df == ""] = NA

  # keep columns with under 50% missing data
  df = df[, colMeans(is.na(df)) <= threshold_col]

  # keep rows with under 5% missing data
  df = df[rowMeans(is.na(df)) <= threshold_row, ]
  
  # only perform cleaning on numeric columns
  if (length(ignore_cols) > 0) {
    
    # assign numeric columns only to new temp dataframe
    temp = df[, -ignore_cols]
    
    # filter out any column which are all 0s, if column is full of 0s, this 
    # will break the PCA algorithm. Mask out NAs when finding zeros
    # need to filter out character columns, and leave only numeric ones
    zero_cols = apply(temp, 2, function(x) all(x[!is.na(x)] == 0))
    temp = temp[, !zero_cols]
    
    # reassign via column concatenation, moving character columns to the front
    df = cbind(df[, ignore_cols], temp)
    
  }
  
  # display % missing values before cleaning
  print(sprintf("Percentage NA After Cleaning: %0.1f%%", 
                                          sum(is.na(df))/prod(dim(df))*100))

  return(df)
  
}

return_ukb_target_background_labels = function(df_subset,
                                               target_criteria="> 140/80") {
  
  # given the filtered/subsetted ukb df, create a vector containing whether
  # a given row is a background (1), target (2), or between (0), depending
  # on the criteria provided for blood pressure. then append this new vector
  # in between at the 4th column of the original dataframe

  # define all as between first
  bp_label_vector = rep(0, nrow(df_subset))
  
  # for prior events, remove 4 (high BP) from background group
  # keep only patients labeled with -7 in background, and -7 & 4 in disease
  if (target_criteria == "> 140/80") {
    
    target_rows = which(df_subset$`BPSys-2.0` > 140 | df_subset$`BPDia-2.0` > 80)
    
  } else if (target_criteria == "> 160/100") {
    
    target_rows = which(df_subset$`BPSys-2.0` > 160 | df_subset$`BPDia-2.0` > 100)
    
  } else if (target_criteria == "event at time of imaging") {
    
    # Target: event at time of imaging. Background: no event, no event on follow
    #target_rows = which(df_subset[,"6150-0.0"] > 0 & df_subset[,"6150-0.0"] < 4)
    #background_rows = which(df_subset[,"6150-0.0"] < 0 | df_subset[,"6150-0.0"] == 4)
    
  } else if (target_criteria == "no event at time of imaging, but at follow-up") {
    
    # Target: no event at time of imaging, but at follow-up.
    # Background: no event, no event on follow-up
    #target_rows = which(df_subset[,"6150-0.0"] > 0 & df_subset[,"6150-0.0"] < 4)
    #background_rows = which(df_subset[,"6150-0.0"] < 0 | df_subset[,"6150-0.0"] == 4)
    
  } else {
    warning("Wrong Criteria Option Error")
  }
  
  # define background rows
  background_rows = which(df_subset$bp_sys_upper < 120 &
                          df_subset$bp_dia_upper < 80 &
                          df_subset$events == -7 &
                          df_subset$bp_medication != 2)
  
  # clean missing value
  background_rows = background_rows[!is.na(background_rows)]
  target_rows = target_rows[!is.na(target_rows)]
  
  # define indices which are background or target
  bp_label_vector[background_rows] = 1
  bp_label_vector[target_rows] = 2
  
  # add this new column to df, insert into 4th column index position
  df_subset = cbind(df_subset[,1:4],
                    bp_group = bp_label_vector,
                    df_subset[5:ncol(df_subset)])
  
  return(df_subset)
  
}

return_remove_single_value_columns = function(data) {
  
  # this function removes columns which have only 1 value (no variation)

  # find which columns have all singular (non-unique) values for all samples
  keep_cols = apply(data, 2, function(c)
                                  length(unname(table(c[!is.na(c)]))) > 1)
  
  # subset data with columns that do indeed have different values for samples
  keep_cols = which(unname(keep_cols))
  data = data[, keep_cols]
  
  return(data)
  
}

return_data_harmonized = function(data, data_group) {
  
  # given a dataframe and group, perform data harmonization using the ComBat
  # method to harmonize and standardize the different groups
  
  # extract the columns in the data belong to the group
  group = data[, data_group[data_group %in% colnames(data)]]
  
  # take the right most column (for now)
  group = group[, ncol(group)]
  
  # convert to categorical
  group = as.factor(group)
  
  # remove the group from data if not already
  data = data[, !(colnames(data) %in% data_group)]

  # use ComBat data harmonization
  # https://cran.r-project.org/web/packages/ez.combat/ez.combat.pdf
  data = ez.combat(df = data, batch.var = group, use.eb = FALSE)
  
  return(data)
  
}

return_normalize_zscore = function(data) {
  
  # given a matrix of numbers perform mean and standard deviation normalization
  # for each column, which represents 1 feature, of the dataframe, these cols
  # should all be numerical
  
  # compute mean and standard deviation of each column
  data_means = colMeans(data, na.rm = TRUE)
  data_std = apply(data, 2, function(x) sd(x, na.rm = TRUE))
  
  # subtract mean and divide by standard deviation
  data = sweep(data, 2, data_means, "-")
  data = sweep(data, 2, data_std, "/")

  return(data)
  
}

return_remove_large_zscores = function(data, sd_threshold) {
  
  # this function removes large z-scores, sets them to NA
  # note that this only works if the input data is already normalized
  # using mean/standard deviation normalization such that it has a 
  # mean of 0 and standard deviation of 1
  
  # remove large z scores
  data[abs(data) > sd_threshold] = NA
  
  return(data)
  
}

return_imputed_data = function(data, method="median") {
  
  # given an input data matrix, and a method selected for imputation
  # perform imputation and return the dataset
  
  # different workflow depending on different imputation method
  if (any(method == c("median", "mode", "mean"))) {
   
    # mean/mode/median imputation (very simple)
    if (method == "mean") {
      
      data = apply(data, 2, function(x) {
                                  x[is.na(x)] = mean(x, na.rm=TRUE)
                                  return(x)
                                })
      
    } else if (method == "mode") {
      
      data = apply(data, 2, function(x) {
                                  x[is.na(x)] = mode(x)
                                  return(x)
                                })
    
    } else if (method == "median") {

      data = apply(data, 2, function(x) {
                                  x[is.na(x)] = median(x, na.rm=TRUE)
                                  return(x)
                                })
      
    }
    
  # regression imputation
  } else if (method == "regression") {

    x = 0
    
  } else {
    warning("Wrong Imputation Method Provided")
  }
  
  return(data)
  
}

return_remove_low_sd = function(data) {
  
  # this function removes variables which has low standard deviation
  # the input variables must be z-score normalized
  # there should also not be any missing values in the data frame
  
  # compute the standard deviation of each column
  sds = apply(data, 2, function(x) sd(x))
  
  # only keep the variables with sufficient standard deviation
  data = data[, sds > 0.5]
  
  return(data)
  
}

edit_ukb_columns = function(ukb_data, keep_cols = c(), remove_cols = c()) {

  # given a ukb dataset
  # this function takes in a dataframe and 2 vectors of column names
  # and adds/removes these columns from the data frame

  # subset away first 4 columns as these contain important labels
  data = ukb_data[, 6:ncol(ukb_data)]

  # index dataframe (if not empty input)
  if (length(keep_cols) > 0) {
    data = data[, keep_cols]
  }

  # inverse index dataframe (if not empty input)
  if (length(remove_cols) > 0) {
    to_remove = c()
    for (i in 1:length(remove_cols)) {
      to_remove = c(to_remove, grep(remove_cols[i], colnames(data)))
    }
    data = data[, -to_remove]
  }

  # re-combine new subset of columns with dataframe
  ukb_data = cbind(ukb_data[, 1:5], data)

  return(ukb_data)
  
}

remove_ukb_duplicate_instances = function(data) {

  # this function only keep latest instance of each variable 

  # sort by ascending such that instance 0 comes first
  varnames = sort(colnames(data))

  # filter out all instance information from variable names
  v_names = ifelse(grepl("\\-", varnames),
                   substring(varnames, 1, regexpr("\\-", varnames)-1),
                   varnames)

  # find and remove duplicates (first instance after sorting)
  varnames = varnames[!duplicated(v_names, fromLast = TRUE)]
  data = data[, varnames]

  return(data)

}

return_covariates = function(data, covariates) {
  
  # this function returns the covariate columns of the dataset provided
  
  # extract columns defined as covariates
  data = data[, covariates[covariates %in% colnames(data)]]
  
  return(data)
  
}
