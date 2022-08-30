
split_ukb_into_data_label = function(df) {
  
  # given the processed ukb df which has been filtered and cleaned, as well
  # as assigned labels, return two dataframes which separates the label
  # from the data in preparation for machine learning
  
  return(list(data = df[, 5:ncol(df)], label = df[, 1:4]))
  
}

normalize_dataset = function(df, NA_encode=-999999) {
  
  # given the filtered dataset from ukb, normalize the columns using mean
  # and standard deviation. note that in this dataframe specifically, the
  # NA values are encoded with -999999, but can be changed depending on
  # the number used.
  
  # re-assign NA-encoded values as NA
  df[df == NA_encode] = NA
  
  # normalize every column
  df = t((t(df) - colMeans(df, na.rm=TRUE)) / 
                              apply(df, 2, function(x) sd(x, na.rm=TRUE))
        )
  
  # re-assign missing values
  df[is.na(df)] = NA_encode
  
  return(df)
  
}

split_train_test = function(df_data, df_label, test_percentage = 0.25) {
  
  # given a dataframe (with rows as samples, and columns as features)
  # split the dataframe into train and test samples based on the input
  # argument which dictates the proportion of the dataset to assign to
  # testing
  
  # compute random vector of indices to assign for testing
  test_ind = sample(1:nrow(df_data), test_percentage * nrow(df_data))
  
  # return data/label for train/test
  return(list(train_dat = df_data[-test_ind, ],
              train_lab = df_label[-test_ind],
              test_dat = df_data[test_ind, ],
              test_lab = df_label[test_ind]))
  
}