
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
  df$Record.Id = paste0(paste0("BB", df$Record.Id), df$eid)
  df$StudyName = "BB"

  # set blood pressure variables if not present already
  if (length(grep("BPSys", colnames(df))) == 0) {

    df[["BPSys-1.0"]] = df[["4080-0.0"]]
    df[["BPSys-2.0"]] = df[["4080-0.1"]]
    df[["BPDia-1.0"]] = df[["4079-0.0"]]
    df[["BPDia-2.0"]] = df[["4079-0.1"]]

  }
  
  # change some data types
  df_vars$Field = as.character(df_vars$Field)
  df_vars$FieldID = as.character(df_vars$FieldID)
  
  return(list(ukb_data = df, ukb_vars = df_vars))
  
}

get_ukb_subset_column_names = function(df, df_vars,
                                       subset_option="all") {
  
  # Code written by Winok
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
  
  # Demographic
  Sex = "31-0.0"
  Age = grep("^21003-", names(df), value=TRUE)
  Event = "6150-0.0"
  
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
  cardiac_seg = read.csv(paste0("../../../UK Biobank Imaging ",
                                "Enhancement Cardiac Phenotypes.csv"))
  bb_CMR_vars = c(bb_CMR_vars,
                  names(cardiac_seg)[2:length(names(cardiac_seg))])

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
  bb_art_vars = c() # set to empty as current ukb data does not have 
                    # these columns
  
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
  
  # Combine variables together
  vars = c("eid", "12187-2.0", Age, Sex, StudyDate, BPSys, BPSys2, BPDia, Event,
           BPDia2,bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,
           bb_art_vars,bb_blood_vars,bb_car_vars, bb_spir_vars,
           bb_ecgrest_vars,bb_dis_vars,bb_med_vars) # bb_antro_vars
  vars = vars[!vars %in% c(bulkvars, stratavars)]
  
  vars_2 = c(grep("\\-2.0",
                      c(Age, StudyDate,Event,BPSys,BPSys2,BPDia,BPDia2,
                        bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,
                        bb_art_vars,bb_blood_vars,bb_car_vars,
                        bb_ecgrest_vars), # bb_antro_vars
                  value=TRUE),
             grep("\\-2.", bb_CMR_vars, value=TRUE),
             bb_spir_vars, bb_dis_vars, bb_med_vars)
  vars_2 = vars[!vars_2 %in% c(bulkvars, stratavars)]
  
  # takes column names from the ukb and further subset depending 
  # on input option
  if (subset_option == "all") {
    
    # all
    vars_subset_cols = vars_2[vars_2 %in% c(
                                  bb_CMR_vars,bb_BMR_vars,
                                  bb_AMR_vars,
                                  bb_bodycomp_vars,bb_art_vars,
                                  bb_car_vars,bb_blood_vars,bb_spir_vars,
                                  bb_ecgrest_vars,Sex,Age,Event)]
    
  } else if (subset_option == "cardiac") {
    
    # cardiac
    vars_subset_cols = vars_2[vars_2 %in% c(
                                    bb_CMR_vars, bb_art_vars, bb_car_vars)]
    
  } else if (subset_option == "brain") {
    
    # brain
    vars_subset_cols = vars_2[vars_2 %in% bb_BMR_vars]
    
  } else if (subset_option == "cardiac + brain + carotid ultrasound") {
    
    # cardiac + brain + carotid ultrasound
    vars_subset_cols = vars_2[vars_2 %in% c(bb_CMR_vars,bb_BMR_vars,
                                            bb_art_vars,bb_car_vars,Sex,Age)]
    
  } else {
    warning("Wrong Subset Option Error")
  }
  
  # add back useful columns involving blood pressure
  vars_subset_cols = c("Record.Id","BPSys-2.0","BPDia-2.0",vars_subset_cols)
                         
  return(vars_subset_cols)
  
}

get_ukb_subset_rows = function(df, subset_option="all") {

  # Code written by Winok
  # this function extracts the rows (patients) we want to analyse
  # and returns the indices of the rows. here we focuse on the blood
  # pressure mainly to ensure no missing values are in the subset
  
  if (subset_option == "all") {
    
    # all
    subset_rows = which(!is.na(df[,"BPSys-2.0"]))
    
  } else if (subset_option == "women") {
    
    # women
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & df[,"31-0.0"] == 0)
    
  } else if (subset_option == "men") {
    
    # men
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & df[,"31-0.0"] == 1)
    
  } else if (subset_option == "no heart attack, angina, stroke") {
    
    # exclude those with heart attack/angina/stroke at time of imaging
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & 
                              (!(df[,"6150-0.0"] > 0 & df[,"6150-0.0"] < 4)))

  } else if (subset_option == "women no heart attack, angina, stroke") {
    
    # only women: exclude those with heart attack/angina/stroke at time 
    #             of imaging
    subset_rows = which(!is.na(df[,"BPSys-2.0"]) & df[,"31-0.0"] == "0" &
                              (!(df[,"6150-0.0"] > 0 & df[,"6150-0.0"] < 4)))
    
  } else {
    warning("Wrong Subset Option Error")
  }
  
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

return_remove_low_variance_columns = function(data, char_cols = c()) {

  # this function removes columns which have extremely low variance meaning
  # that they could potentially be columns which only contain either 1 single
  # value or very narrow range of values.

  # only perform cleaning on numeric columns
  if (length(char_cols) > 0) {
    
    # assign numeric columns only to new temp dataframe
    temp = data[, -char_cols]

    # find which columns have no variation in value (only 1 unique value)
    low_var_cols = apply(temp, 2, function(x) var(x, na.rm=TRUE) == 0)

    # reassign via column concatenation, moving character columns to the front
    data = cbind(data[, char_cols], temp[, which(!unname(low_var_cols))])

  } else {

    # find which columns have no variation in value (only 1 unique value)
    low_var_cols = apply(data, 2, function(x) var(x, na.rm=TRUE) == 0)

    # remove low variance columns
    data = data[, which(!unname(low_var_cols))]

  }

  return(data)

}

return_clean_df = function(df, threshold_col, threshold_row, char_cols = c()) {
  
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
  if (length(char_cols) > 0) {
    
    # assign numeric columns only to new temp dataframe
    temp = df[, -char_cols]
    
    # filter out any column which are all 0s, if column is full of 0s, this 
    # will break the PCA algorithm. Mask out NAs when finding zeros
    # need to filter out character columns, and leave only numeric ones
    zero_cols = apply(temp, 2, function(x) all(x[!is.na(x)] == 0))
    temp = temp[, !zero_cols]
    
    # reassign via column concatenation, moving character columns to the front
    df = cbind(df[, char_cols], temp)
      
  }
  
  # display % missing values before cleaning
  print(sprintf("Percentage NA After Cleaning: %0.1f%%", 
                                          sum(is.na(df))/prod(dim(df))*100))

  return(df)
  
}

return_ukb_target_background_labels = function(df_subset, target_criteria="> 140/80") {
  
  # given the filtered/subsetted ukb df, create a vector containing whether
  # a given row is a background (1), target (2), or between (0), depending
  # on the criteria provided for blood pressure. then append this new vector
  # in between at the 4th column of the original dataframe
  
  # define all as between first
  bp_label_vector = rep(0, nrow(df_subset))
  
  if (target_criteria == "> 140/80") {

    # > 140/80
    target_rows = which(df_subset[,"BPSys-2.0"] > 140 | df_subset[,"BPDia-2.0"] > 90)
    background_rows = which(df_subset[,"BPSys-2.0"] < 120 & df_subset[,"BPDia-2.0"] < 80)
    
  } else if (target_criteria == "> 160/100") {
    
    # > 160/100
    target_rows = which(df_subset[,"BPSys-2.0"] > 160 | df_subset[,"BPDia-2.0"] > 100)
    background_rows = which(df_subset[,"BPSys-2.0"] < 120 & df_subset[,"BPDia-2.0"] < 80)
    
  } else if (target_criteria == "event at time of imaging") {
    
    # target: event at time of imaging. 
    # Background: no event, no event on follow
    target_rows = which(df_subset[,"6150-0.0"] > 0 & df_subset[,"6150-0.0"] < 4)
    background_rows = which(df_subset[,"6150-0.0"] < 0 | df_subset[,"6150-0.0"] == 4)
    
  } else if (target_criteria == "no event at time of imaging, but at follow-up") {
    
    # target: no event at time of imaging, but at follow-up. 
    # Background: no event, no event on follow-up, low BP
    target_rows = which(df_subset[,"6150-0.0"] > 0 & df_subset[,"6150-0.0"] < 4)
    background_rows = which(df_subset[,"6150-0.0"] < 0 | df_subset[,"6150-0.0"] == 4)
    
  } else {
    warning("Wrong Criteria Option Error")
  }
  
  # define indices which are background or target
  bp_label_vector[background_rows] = 1
  bp_label_vector[target_rows] = 2
  
  # add this new column to df, insert into 4th column index position
  df_subset = cbind(df_subset[,1:3],
                    bp_group = bp_label_vector,
                    df_subset[4:ncol(df_subset)])
  
  return(df_subset)
  
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

return_remove_large_zscores = function(data) {
  
  # this function removes large z-scores, sets them to NA
  
  # remove large z scores
  data[abs(data) > 5] = NA
  
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
    
    # TO DO
    #library(mi)
    #data = mi(ukb_df)
    x = 0
    
  } else {
    warning("Wrong Imputation Method Provided")
  }
  
  return(data)
  
}

return_covariates = function(data, covariates) {
  
  # this function returns the covariate columns of the dataset provided
  
  # extract columns defined as covariates
  data = data[, covariates]
  
  return(data)
  
}
