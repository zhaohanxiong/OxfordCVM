
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
top50 = list()
top100 = list()
top200 = list()
top300 = list()
top400 = list()
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
  
  if (FALSE) { # TRUE FALSE
    # make plot box plot of disease groups
    boxplot(psuedotimes$global_pseudotimes ~ psuedotimes$bp_group, 
            main = sprintf("subset %s", gsub("io ", "", files[i])),
            ylab = "Disease Score", xlab = "Group")
    text(1, 1, adj = 0, labels = sprintf("Vars = %.0f", 
                                    sum(weight_vars$Node_contributions > weight_thres)))
    text(1, 0.9, adj = 0, labels = sprintf("Highest Weighting = %.2f", 
                                       max(weight_vars$Node_contributions)))    
  }

  if (TRUE) { # TRUE FALSE
    # make histogram of weight contributions
    hist(weight_vars$Node_contributions, 
         breaks = seq(0, max(weight_vars$Node_contributions)+0.1, by = 0.1),
         main = "Variable Weighting Distribution", 
         xlab = "Weightings", ylab = "Number of Variables")
    abline(v = median(weight_vars$Node_contributions), lty = 3, col = "red")
  }
  
  # sort the weight variables
  weight_vars = weight_vars$Var1[order(weight_vars$Node_contributions, 
                                       decreasing=TRUE)]

  # assign top N weighted variables to their respective lists
  top50[[i]] = weight_vars[1:50]
  top100[[i]] = weight_vars[1:100]
  top200[[i]] = weight_vars[1:200]
  top300[[i]] = weight_vars[1:300]
  top400[[i]] = weight_vars[1:400]
  top500[[i]] = weight_vars[1:500]

}

# flatten lists and tabulate, those with variable occurrence = N are kept
top50 = sort(table(unlist(top50)))
top100 = sort(table(unlist(top100)))
top200 = sort(table(unlist(top200)))
top300 = sort(table(unlist(top300)))
top400 = sort(table(unlist(top400)))
top500 = sort(table(unlist(top500)))

# plot
par(mfrow = c(2, 3))

topN = c(50, 100, 200, 300, 400, 500)
for (n in 1:length(topN)) {
  top_N_table = eval(as.symbol(paste0("top", topN[n])))
  top_N_includes = sapply(1:10, function(i) 
                                sum(top_N_table >= i)/length(top_N_table)*100)
  names(top_N_includes) = 1:10
  barplot(top_N_includes, main = paste0(topN[n]," Most Weighted Variables"),
          xlab = "Number of Same Variables in N (or More) Models", 
          ylab = "Proportion of Variables (%)")
  abline(h = seq(0, 100, by = 10), lty = 3, col = "red")
}
