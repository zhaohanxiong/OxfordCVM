
# load outputs from NeuroPM
setwd("C:/Users/zxiong/Desktop")

# list files
files = list.files()
files = files[grepl("io", files)]
files = files[grepl("\\-", files)]

# sort files
files = files[order(as.numeric(substring(
                                  files, 4, as.vector(regexpr("-",files))-1)))]

# initialize lists to store most weighted variables
top10 = list()
top25 = list()
top50 = list()
top100 = list()
top250 = list()
top500 = list()

par(mfrow = c(2,5))

for (i in 1:length(files)) {

  # set directory of files for this subset run
  f_dir = files[i]
  
  # read weight files
  weight_vars = read.csv(file.path(f_dir, "var_weighting.csv"), header=TRUE)
  
  weight_thres = as.numeric(read.csv(file.path(f_dir, "threshold_weighting.csv"), 
                                     header=TRUE))

  # read psuedo time files
  psuedotimes = read.csv(file.path(f_dir, "pseudotimes.csv"), header=TRUE)
  psuedotimes$bp_group = ordered(psuedotimes$bp_group, levels = c(1,0,2))
  
  # make plot box plot of disease groups
  #boxplot(psuedotimes$global_pseudotimes ~ psuedotimes$bp_group, 
  #        main = sprintf("subset %s", gsub("io ", "", files[i])),
  #        ylab = "Disease Score", xlab = "Group")
  #text(1, 1, adj = 0, labels = sprintf("Vars = %.0f", 
  #                                sum(weight_vars$Node_contributions > weight_thres)))
  #text(1, 0.9, adj = 0, labels = sprintf("Highest Weighting = %.2f", 
  #                                   max(weight_vars$Node_contributions)))
  
  # make histogram of weight contributions
  hist(weight_vars$Node_contributions, 
       breaks = seq(0, max(weight_vars$Node_contributions)+0.1, by = 0.1))
  
  # sort the weight variables
  weight_vars = weight_vars$Var1[order(weight_vars$Node_contributions, 
                                       decreasing=TRUE)]
  
  # assign top N weighted variables to their respective lists
  top10[[i]] = weight_vars[1:10]
  top25[[i]] = weight_vars[1:25]
  top50[[i]] = weight_vars[1:50]
  top100[[i]] = weight_vars[1:100]
  top250[[i]] = weight_vars[1:250]
  top500[[i]] = weight_vars[1:500]

}

# flatten lists and tabulate, those with variable occurrence = N are kept
top10 = sort(table(unlist(top10)))
top25 = sort(table(unlist(top25)))
top50 = sort(table(unlist(top50)))
top100 = sort(table(unlist(top100)))
top250 = sort(table(unlist(top250)))
top500 = sort(table(unlist(top500)))

# plot
par(mfrow = c(2, 3))

topN = c(10, 25, 50, 100, 250, 500)
for (n in 1:length(topN)) {
  top_N_table = eval(as.symbol(paste0("top", topN[n])))
  barplot(top_N_table, main = paste0("top ", topN[n]," variables"))
  text(0, 9, adj = 0, labels = sprintf("# Common Variables in 5 models: %.0f", sum(top_N_table >= 5)))
  text(0, 8, adj = 0, labels = sprintf("# Common Variables in 8 models: %.0f", sum(top_N_table >= 8)))
  text(0, 7, adj = 0, labels = sprintf("# Common Variables in 10 models: %.0f", sum(top_N_table == 10)))
}
