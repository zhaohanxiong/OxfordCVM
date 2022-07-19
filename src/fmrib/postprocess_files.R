# load outputs from NeuroPM
path = "NeuroPM/io/"
path = "C:/Users/86155/Desktop/10_fold_full_run_scalePC"
# --------------------------------------------------------------------------------------------
# Tidy Up Pseudotimes Output File
# --------------------------------------------------------------------------------------------
# load pseudotime scores
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)

# rename first column
names(psuedotimes)[1:3] = c("patid", "BPSys.2.0", "BPDia.2.0")

# save psuedotimes with renamed columns
write.csv(psuedotimes, file.path(path,"pseudotimes.csv"), row.names = FALSE)

# --------------------------------------------------------------------------------------------
# Map Variable Codes to UKB Descriptions
# --------------------------------------------------------------------------------------------
# prepare data frame of variable names and their descriptors
varnames = read.csv(file.path(path, "var_weighting.csv"), 
                    header=TRUE, stringsAsFactor=FALSE)$Var1

# load bb variable list to compare
ukb_varnames = read.csv("../../../bb_variablelist.csv", 
                        header=TRUE, stringsAsFactor=FALSE)

# match field codes with field descriptors
varnames = c(names(psuedotimes)[2:3], varnames)
varnames = gsub("_", ".", gsub("x", "X", varnames))

var_regexpr = regexpr("\\.", varnames) + 1
varnames_instance = substring(varnames, var_regexpr, var_regexpr)
varnames = data.frame(colname = varnames,
                      FieldID = substring(varnames, 
                                          regexpr("X", varnames) + 1, 
                                          regexpr("\\.", varnames) - 1))
varnames$colname = as.character(varnames$colname)
varnames$FieldID = as.character(varnames$FieldID)
varnames$Field = ukb_varnames$Field[sapply(varnames$FieldID, function(v) 
                                             which(ukb_varnames$FieldID == v))]
varnames$instance = varnames_instance
varnames$display = paste0(varnames$Field, ifelse(varnames$instance == "0",
                                                 "",
                                                 paste0(" (", varnames$instance, ")")))

# write this to file for dataframe of variable codes and original names
write.csv(varnames, file.path(path, "ukb_varnames.csv"), row.names = FALSE)

# --------------------------------------------------------------------------------------------
# Filter Variables by Weighting and Correlation
# --------------------------------------------------------------------------------------------
library(data.table)

# load variable weights and threshold and variables
var_weights = read.csv(file.path(path, "var_weighting.csv"), 
                       header=TRUE, stringsAsFactor=FALSE)
var_thresh = read.csv(file.path(path, "threshold_weighting.csv"),
                      header=TRUE, stringsAsFactor=FALSE)$Expected_contribution
ukb_df = data.frame(fread(file.path(path, "ukb_num.csv"),header=TRUE))

# rename variable weightings
var_weights$Var1 = gsub("_", ".", var_weights$Var1)
var_weights$Var1 = gsub("x", "X", var_weights$Var1)

# compute which variables are the most significant
var_weights$significant = var_weights$Node_contributions > var_thresh

# normalize variable weightings
var_weights$Node_contributions = var_weights$Node_contributions/sum(
                                              var_weights$Node_contributions)

# compute correlation with every variable
cors = apply(ukb_df, 2, function(x) 
                        cor.test(x, psuedotimes$global_pseudotimes)$estimate)
pvals = apply(ukb_df, 2, function(x)
                        cor.test(x, psuedotimes$global_pseudotimes)$p.val)
names(cors) = names(ukb_df)
names(pvals) = names(ukb_df)

# match variable weighting dataframe with variable correlation data frame
var_weights$cor = sapply(1:nrow(var_weights), function(i) 
                                  cors[var_weights$Var1[i] == names(cors)])
var_weights$pvals = sapply(1:nrow(var_weights), function(i) 
                                  pvals[var_weights$Var1[i] == names(pvals)])

# get top 10% of highly correlated variables which are also significant
var_weights$significant_cor = var_weights$cor > sort(abs(var_weights$cor), 
                                  decreasing=TRUE)[floor(nrow(var_weights)*0.1)] & 
                              var_weights$pval < 0.0001

# keep variables which are significant (by cTI) and strongly correlated
var_weights = var_weights[var_weights$significant | var_weights$significant_cor, ]

# retrieve original names
var_weights$name = sapply(1:nrow(var_weights), function(i) varnames$Field[
                                         varnames$colname == var_weights$Var1[i]])

# write the reduced variable list to file
write.csv(var_weights, file.path(path, "var_weighting_reduced.csv"))

# print summary statistics for output
print(sprintf(paste0("%.0f Significant Columns (cTI Selected) Contributed to "
                    ," %0.1f%% of the Total Weighting"), 
              nrow(var_weights[var_weights$significant, ]),
              sum(var_weights$Node_contributions[var_weights$significant]) * 100))
print(sprintf(paste0("%.0f Significant Columns (cTI + Cor Test) Contributed to "
                     ," %0.1f%% of the Total Weighting"), 
              nrow(var_weights),
              sum(var_weights$Node_contributions) * 100))
print(sprintf(paste0("Number of Variables with Statistically Significant ",
                     "Correlations (p < 0.05) is %0.f"),
              sum(var_weights$pvals < 0.05)))
print(sprintf(paste0("Number of Variables with Statistically Significant ",
                     "Correlations (p < 0.001) is %0.f"),
              sum(var_weights$pvals < 0.001)))
print(sprintf(paste0("Number of Variables with Statistically Significant ",
                     "Correlations (p < 0.0001) is %0.f"),
              sum(var_weights$pvals < 0.0001)))

# subset ukb_num dataframe to obtain only highest correlated variables
ukb_df = ukb_df[, var_weights$Var1]

# write the reduced variable data frame to output
fwrite(ukb_df, file.path(path, "ukb_num_reduced.csv"))
