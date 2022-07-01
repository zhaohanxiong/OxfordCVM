# load outputs from NeuroPM
path = "NeuroPM/io/"

# load pseudotime scores
psuedotimes = read.csv(file.path(path,"pseudotimes.csv"), header=TRUE)

# rename first column
names(psuedotimes)[1:3] = c("patid", "BPSys.2.0", "BPDia.2.0")

# save psuedotimes with renamed columns
write.csv(psuedotimes, file.path(path,"pseudotimes.csv"), row.names = FALSE)

# assign bp_groups as the real labels
psuedotimes$bp_group[psuedotimes$bp_group == 0] = "Between"
psuedotimes$bp_group[psuedotimes$bp_group == 1] = "Background"
psuedotimes$bp_group[psuedotimes$bp_group == 2] = "Disease"
psuedotimes$bp_group = ordered(psuedotimes$bp_group,
                               levels = c("Background","Between","Disease"))

# perform statistical tests to evaluate model
# seperate groups into different variable
g1 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Background"]
g2 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Between"]
g3 = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Disease"]

# perform t-test between groups
t.test(g1,g2) # background vs between
t.test(g2,g3) # between vs disease
t.test(g1,g3) # background vs disease

# perform quantile differences between groups, % overlap
g1_box = unname(c(quantile(g1, 0.25), quantile(g1, 0.75))) # background
g2_box = unname(c(quantile(g2, 0.25), quantile(g2, 0.75))) # between
g3_box = unname(c(quantile(g3, 0.25), quantile(g3, 0.75))) # disease

# display results
sprintf(paste0("Overlap in IQR of Background vs Between is ",
               "%0.1f%% (Background) %0.1f%% of (Between)"),
        (g1_box[2] - g2_box[1]) / diff(g1_box) * 100,
        (g1_box[2] - g2_box[1]) / diff(g2_box) * 100)
sprintf(paste0("Overlap in IQR of Boxes Between vs Disease is ",
               "%0.1f%% (Between) %0.1f%% (Disease)"),
        (g2_box[2] - g3_box[1]) / diff(g2_box) * 100,
        (g2_box[2] - g3_box[1]) / diff(g3_box) * 100)

# compute overlap between background and disease group scores
sample_background = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Background"]
sample_disease = psuedotimes$global_pseudotimes[psuedotimes$bp_group == "Disease"]
overlap = max(sample_background) - min(sample_disease)

# calculate number of overlapping samples in the background and disease groups
n_background_overlap = sum(sample_background > min(sample_disease))
n_disease_overlap = sum(sample_disease < max(sample_background))

# quantifying the quantiles for the overlapping values
background_q = 1 - n_background_overlap/length(sample_background)
disease_q = 1 - n_disease_overlap/length(sample_disease)

# display results
sprintf("Comparing the Amount of Overlap Between Background and Disease")
sprintf("Overlapping Interval of Scores is %0.3f Out of 1", overlap)
sprintf("%% of Non-Overlapping Scores in the Background Group is %0.1f%%",
        background_q * 100)
sprintf("%% of Non-Overlapping Scores in the Disease Group is %0.1f%%",
        disease_q * 100)

# prepare dataframe of variable names and their descriptors
varnames = read.csv(file.path(path, "var_weighting.csv"), 
                    header=TRUE, stringsAsFactor=FALSE)$Var1

# load bb variable list
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

# write this to file
write.csv(varnames, file.path(path, "ukb_varnames.csv"), row.names = FALSE)
