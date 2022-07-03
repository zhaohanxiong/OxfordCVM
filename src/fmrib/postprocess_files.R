# load outputs from NeuroPM
path = "NeuroPM/io/"

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
