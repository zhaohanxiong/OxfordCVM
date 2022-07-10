library(data.table)

# set path
path = "fmrib/NeuroPM/io/" # "C:/Users/zxiong/Desktop/io"

# load data
ukb_df = data.frame(fread(file.path(path,"ukb_num.csv"),header=TRUE))[1:2800,]
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)[1:2800,]
varnames = read.csv(file.path(path,"ukb_varnames.csv"), header=TRUE)
variable_weightings = read.csv(file.path(path,"var_weighting.csv"), header=TRUE)

# rename variable weightings
variable_weightings$Var1 = gsub("_", ".", variable_weightings$Var1)
variable_weightings$Var1 = gsub("x", "X", variable_weightings$Var1)

# compute correlation with every variable
cors = apply(ukb_df, 2, function(x) cor.test(x,psuedotimes$global_pseudotimes)$
                                                                        estimate)
pvals = apply(ukb_df, 2, function(x) cor.test(x,psuedotimes$global_pseudotimes)$
                                                                          p.val)

# visualize distribution of correlations
if (FALSE) {
  hist(cors, breaks = 100,
       main = "Histogram of Variable Correlations with Psuedotime",
       xlab = "Pearson Correlation")
}

# extract significant variables
sig_cors = cors[pvals < 0.05 & !is.na(pvals)]
sig_vars = unname(unlist(sapply(names(sig_cors), function(x) varnames$Field[
                                                     which(varnames$colname == x)])))
sig_table = data.frame(vars = sig_vars, cors = sig_cors)

# extract highly weighted variables
variable_weightings$cor = sapply(variable_weightings$Var1, function(x)
                                                  cors[which(varnames$colname == x)])
variable_weightings$pval = sapply(variable_weightings$Var1, function(x)
                                                  pvals[which(varnames$colname == x)])
variable_weightings$name = unname(unlist(sapply(variable_weightings$Var1, function(x)
                                       varnames$Field[which(varnames$colname == x)])))

# view table
if (FALSE) {
  View(sig_table)
  View(variable_weightings)
  write.csv(variable_weightings, "temp.csv")
  write.csv(sig_table, "temp.csv")
}
