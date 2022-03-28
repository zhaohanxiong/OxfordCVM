library(rebus)
library(data.table)
library(writexl)
library(xlsx)
library(ggplot2)
library(dplyr)

bb_DP_prep3 <-function(dataset,target_Record.Id,background_Record.Id,between_Record.Id,variables,cov=NULL,perc_mis_M=5,perc_mis=20){
  target_Record.Id=target_Record.Id[!is.na(target_Record.Id)]
  background_Record.Id=background_Record.Id[!is.na(background_Record.Id)]
  between_Record.Id=between_Record.Id[!is.na(between_Record.Id)]
  
 data_dp=dataset
 colnames=names(data_dp)[names(data_dp) %in% c(variables,as.character(cov))]
 data_dp=data_dp[,c("Record.Id","StudyName",colnames)]
 
 data_dp_cl=bb_excl_mis(data_dp,names(data_dp),perc_mis_M,perc_mis)
 data_dp=data_dp_cl$data
 
 ### code bp_group
 target_Record.Id_M=data_dp_cl$data_M$Record.Id[data_dp_cl$data_M$Record.Id %in% target_Record.Id]
 background_Record.Id_M=data_dp_cl$data_M$Record.Id[data_dp_cl$data_M$Record.Id %in% background_Record.Id]
 
 data_dp$bp_group=0
 data_dp$bp_group[data_dp$Record.Id%in% target_Record.Id_M]=2
 data_dp$bp_group[data_dp$Record.Id%in%background_Record.Id_M]=1
 
 list=list("variables"=names(data_dp)[!names(data_dp)%in%"bp_group"],
           "perc_missing_model"=perc_mis_M,
           "perc_missing"=perc_mis)
 
 if(missing(cov)==FALSE){
   ## delete subjects with missing data for covariates
   data_dp=data_dp[complete.cases(data_dp[,cov]),]
   cov_2=data_dp[,cov]
   list[["cov"]]=cov_2
 }
 
 list[["bpdata"]]=data_dp[,c("Record.Id","bp_group")]
 
 return(list)
 }

bb_excl_mis <-function(dataset,variables,perc_mis_M=5,perc_mis=20){
### exclude columns with majority NA, for studies separatey
for (study in unique(dataset$StudyName)){
  a=which(colMeans(is.na(dataset[dataset$StudyName==study,which(names(dataset) %in% variables)])) > 0.5)
  if (length(a)>0){
    dataset=dataset[,-which(names(dataset) %in% names(a))]}
  ## exclude columns with the same value for everyone (including only NA), except of course the StudyName variable
  b=which(apply(dataset, 2, function(x) length(unique(x)) == 1))
  b=names(b)[!names(b) %in% "StudyName"]
  ### b=names(dataset) %in% b
  if (length(b)>0){
    dataset=dataset[,-which(names(dataset) %in% b)]}
}

#remove rows with more than ... missing data
c=apply(dataset, MARGIN = 1, function(x) sum(is.na(x)))
d=c<(ncol(dataset)/100*perc_mis)
e=c<(ncol(dataset)/100*perc_mis_M)
data_dp=dataset[d,]
data_dp_M=dataset[e,]

list=list("data"=data_dp,"data_M"=data_dp_M)
}

adjust_data_3 <-function(dataset,vars,adjvar){
  library(dplyr)
  vars_adjusted=NULL
  data_adj=dataset[,-which(names(dataset) %in% vars)]
  vars=vars[vars !=adjvar]
  for (var in vars){
    if (is.numeric(dataset[,var])){
      if (abs(sum(dataset[,var],na.rm=T))>0){
        adjusted=dataset[,c(var,"Record.Id",adjvar)]
        adjusted=na.omit(adjusted)
        
        formula=as.formula(paste("`",var,"`","~","`",adjvar,"`",sep=""))
        #formula=as.formula(paste(var,"~",adjvar))
        mod=lm(formula,adjusted)
        
        intercept=summary(mod)$coefficients["(Intercept)","Estimate"]
        #est_sex=summary(mod)$coefficients[adjvar,"Estimate"]
        est_sex=summary(mod)$coefficients[paste("`",adjvar,"`",sep=""),"Estimate"]
        mean_sex=mean(adjusted[,adjvar], na.rm=T)
        # add residuals to dataset
        adjusted$res=mod$residuals
        
        # create adjusted variable
        adj=mutate(adjusted, var_adj = res + (intercept + (est_sex*mean_sex)))
        adj2=as.data.frame(adj[,c("Record.Id","var_adj")])
        colnames(adj2)=c("Record.Id",var)
        
        data_adj=merge(data_adj,adj2,all.x=T)
      }}}
  return(data_adj)
} # Add `` to variable name in formula to deal with variable names with numbers

rename2 <- function(renametable,var,indexcololdname,indexcolnewname){
  a=which(renametable[,indexcololdname]==var)
  newname=renametable[a,indexcolnewname]
  return(newname)
}

outlier <- function(vector){
  median=median(vector,na.rm=TRUE)
  sd=sd(vector,na.rm=TRUE)
  outlpos=median+4*sd
  outlneg=median-4*sd
  vector2=ifelse(vector<outlneg|vector>outlpos,NA,vector)
  return(vector2)
}

### path do directories
dirbase="/Users/winok/Documents/Projects/UKBiobank/BB_DP_imp/model"

## remove values outside of 4SD from median
bb_data <- bb_data %>% mutate_if(is.numeric, outlier)

#### IMPUTE DATA WITH MATLAB
bb_data_or=bb_data[!is.na(bb_data$`BPSys-2.0`),]

### Select data with not so much missing data
bb_data_cl=bb_excl_mis(bb_data_or,names(bb_data_or),perc_mis_M=5,perc_mis=20)

write_xlsx(bb_data_or,"/Users/winok/Documents/Projects/UKBiobank/BB_DP_imp/bb_data_or.xlsx")

### read in imputed data
bb_data_imp=read.csv("/Users/winok/Documents/Projects/UKBiobank/BB_DP2/bb_data_imp_tot_outlrem2.csv")

names(bb_data_imp)=gsub("X","",names(bb_data_imp))
names(bb_data_imp)=sub("\\.","-",names(bb_data_imp))
names(bb_data_imp)=sub("Record-Id","Record.Id",names(bb_data_imp))

bb_data_imp$StudyName="BB"

#models
dirbase="/Users/winok/Documents/Projects/UKBiobank/BB_DP_imp/model"
  ## 1.a.1 = all subjects, all variables, 140/90 vs <120/80
  model1.a.1=bb_DP_prep3(data_prep.1, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.a)
  ### select subjects and variables from model from the imputed dataset
  model1.a.1_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.a.1$bpdata$Record.Id,model1.a.1$variables]
  ## add bp_group
  model1.a.1_sub=merge(model1.a.1_sub,model1.a.1$bpdata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model1.a.1_sub,paste(dirbase,"1.a.1/data_sub.xlsx",sep=""))

## 1.a.2 = all subjects, all variables, 160/100 vs <120/80
  model1.a.2=bb_DP_prep3(data_prep.1, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a,perc_mis_M=5,perc_mis=20)
  ### select subjects and variables from model from the imputed dataset
  model1.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.a.2$bpdata$Record.Id,model1.a.2$variables]
  ## add bp_group
  model1.a.2_sub=merge(model1.a.2_sub,model1.a.2$bpdata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model1.a.2_sub,paste(dirbase,"1.a.2/data_sub.xlsx",sep=""))

  ## 1.a.2_cov = all subjects, all variables, 160/100 vs <120/80, cov Sex/age
  model1.a.2=bb_DP_prep3(data_prep.1, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a,c("31-0.0","21003-2.0"),5,20)
  t.test(bb_data[bb_data$Record.Id %in% target_Record.Id.2,Sex],(bb_data[bb_data$Record.Id %in% background_Record.Id.2,Sex]))
  ### select subjects and variables from model from the imputed dataset
  model1.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.a.2$bpdata$Record.Id,model1.a.2$variables[model1.a.2$variables %in% names(bb_data_imp)]]
  ## add bp_group
  model1.a.2_sub=merge(model1.a.2_sub,model1.a.2$bpdata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model1.a.2_sub,paste(dirbase,"1.a.2/cov/data_sub.xlsx",sep=""))
  write_xlsx(model1.a.2$cov,paste(dirbase,"1.a.2/cov/cov.xlsx",sep=""))

## 1.a.2_excl = all subjects, all variables, 160/100 vs <120/80, excl outliers 1.a.2
  pseudotimes=read.csv(paste(dirbase,"1.a.2","/global_pseudotimes.csv",sep=""))
  names(pseudotimes)=c("Record.Id","bp_group","V1_pseudotimes")
  
  excl=pseudotimes$Record.Id[pseudotimes$V1_pseudotimes>0.20]
  model1.a.2_sub2_RecordId=model1.a.2_sub2$Record.Id[!model1.a.2_sub2$Record.Id %in% excl]
  model1.a.2_sub2_excl=model1.a.2_sub2[model1.a.2_sub2$Record.Id %in% model1.a.2_sub2_RecordId, ]
  write_xlsx(model1.a.2_sub2_excl,paste(dirbase,"1.a.2_excl/data_sub.xlsx",sep=""))
  
## 1.a.2_sub: add in between subjects to model DP2_1.a.2
  ### select subjects and variables from model from the imputed dataset
  a=read.csv("/Users/winok/Documents/Projects/UKBiobank/BB_DP2/model1.a.2/global_pseudotimes.csv")
  a.target=a$RecordId[a$dp_bpgroup==2]
  a.background=a$RecordId[a$dp_bpgroup==1]
  ## add bp_group
  ### select subjects and variables from model from the imputed dataset
  model1.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.a.2$fulldata$Record.Id,c("Record.Id",names(model1.a.2$fulldata)[names(model1.a.2$fulldata) %in% variables.a])]
  
  model1.a.2_sub2_a=model1.a.2_sub
  model1.a.2_sub2_a$bp_group=0
  model1.a.2_sub2_a$bp_group[model1.a.2_sub2_a$Record.Id %in% a.target]=2
  model1.a.2_sub2_a$bp_group[model1.a.2_sub2_a$Record.Id %in% a.background]=1
  write_xlsx(model1.a.2_sub2,paste(dirbase,"1.a.2_400betw/data_sub.xlsx",sep=""))

## 1.a.3= all subjects, all variables, those who have had an event at time of imaging vs no event at time of imaging or follow-up
## select 1000 target, 1000 background, 200 in between subjects with most data
model1.a.3=bb_DP_prep2(data_prep.1, target_Record.Id.3,background_Record.Id.3,between_Record.Id.3,variables.a)
### select subjects and variables from model from the imputed dataset
model1.a.3_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.a.3$Record.Id_subset,c("Record.Id",names(model1.a.3$fulldata)[names(model1.a.3$fulldata) %in% variables.a])]
## add bp_group
model1.a.3_sub2=merge(model1.a.3_sub,model1.a.3$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
write_xlsx(model1.a.3_sub2,paste(dirbase,"1.a.3/data_sub.xlsx",sep=""))

# 1.a.4= all subjects, all variables, those who have had an event at time of imaging vs no event at time of imaging or follow-up
model1.a.4=bb_DP_prep2(data_prep.1, target_Record.Id.4,background_Record.Id.4,between_Record.Id.4,variables.a)
write_xlsx(model1.a.4$sub,paste(dirbase,"1.a.4/data_sub.xlsx",sep=""))

## 1.b.1 = all subjects, CMR variables, 140/90 vs <120/80
model1.b.1=bb_DP_prep2(data_prep.1, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.b)
write_xlsx(model1.b.1$sub,paste(dirbase,"1.b.1/data_sub.xlsx",sep=""))

## 1.b.2 = all subjects, CMR variables, 160/100 vs <120/80
  model1.b.2=bb_DP_prep2(data_prep.1, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.b)
  ### select subjects and variables from model from the imputed dataset
  model1.b.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.b.2$Record.Id_subset,c("Record.Id",names(model1.b.2$fulldata)[names(model1.b.2$fulldata) %in% variables.b])]
  ## add bp_group
  model1.b.2_sub2=merge(model1.b.2_sub,model1.b.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model1.b.2_sub2,paste(dirbase,"1.b.2/data_sub.xlsx",sep=""))

## 1.c.1 = all subjects, CMR variables, 140/90 vs <120/80
model1.c.1=bb_DP_prep2(data_prep.1, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.c)
write_xlsx(model1.c.1$sub,paste(dirbase,"1.c.1/data_sub.xlsx",sep=""))

## 1.c.2 = all subjects, CMR variables, 160/100 vs <120/80
model1.c.2=bb_DP_prep2(data_prep.1, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.c)
write_xlsx(model1.c.2$sub,paste(dirbase,"1.c.2/data_sub.xlsx",sep=""))


## model 2.a: women, all variables
## 2.a.1 = all subjects, all variables, 140/90 vs <120/80
model2.a.1=bb_DP_prep2(data_prep.2, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.a)
write_xlsx(model2.a.1$sub,paste(dirbase,"2.a.1/data_sub.xlsx",sep=""))

## 2.a.2 = all subjects, all variables, 160/100 vs <120/80
model2.a.2=bb_DP_prep2(data_prep.2, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a)
### select subjects and variables from model from the imputed dataset
model2.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model2.a.2$Record.Id_subset,c("Record.Id",names(model2.a.2$fulldata)[names(model2.a.2$fulldata) %in% variables.a])]
## add bp_group
model2.a.2_sub2=merge(model2.a.2_sub,model2.a.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
write_xlsx(model2.a.2_sub2,paste(dirbase,"2.a.2/data_sub.xlsx",sep=""))


## model 3.a: men, all variables
## 3.a.1 = all subjects, all variables, 140/90 vs <120/80
model3.a.1=bb_DP_prep2(data_prep.3, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.a)
write_xlsx(model3.a.1$sub,paste(dirbase,"3.a.1/data_sub.xlsx",sep=""))

## 3.a.2 = all subjects, all variables, 160/100 vs <120/80
model2.a.2=bb_DP_prep2(data_prep.3, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a)
write_xlsx(model3.a.2$sub,paste(dirbase,"3.a.2/data_sub.xlsx",sep=""))


## model 4.a.2: all subjects without cardiac event at time of imaging, all variables, 160/90
  model4.a.2=bb_DP_prep2(data_prep.4, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a,n_target=length(target_Record.Id.2),n_background = length(background_Record.Id.2),n_between=length(between_Record.Id.2))
  ### select subjects and variables from model from the imputed dataset
  model4.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model4.a.2$Record.Id_subset,c("Record.Id",names(model4.a.2$fulldata)[names(model4.a.2$fulldata) %in% variables.a])]
  ## add bp_group
  model4.a.2_sub2=merge(model4.a.2_sub,model4.a.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model4.a.2_sub2,paste(dirbase,"4.a.2/data_sub.xlsx",sep=""))

## model 4.a.2_eventsince: all subjects without cardiac event at time of imaging, all variables, 160/90
### select subjects and variables from model from the imputed dataset + those with 
model4.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% c(data_prep.4$Record.Id[data_prep.4$diag_min_datedif>0&!is.na(data_prep.4$diag_min_datedif)],model4.a.2$Record.Id_subset),c("Record.Id",names(model4.a.2$fulldata)[names(model4.a.2$fulldata) %in% variables.a])]
## add bp_group
model4.a.2_sub2=merge(model4.a.2_sub,model4.a.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
model4.a.2_sub2=model4.a.2_sub2[!is.na(model4.a.2_sub2$bp_group),]
write_xlsx(model4.a.2_sub2,paste(dirbase,"4.a.2_eventsince/data_sub.xlsx",sep=""))

## model 4.a.2: all subjects without cardiac event at time of imaging, all variables, 160/90
  model4.b.2=bb_DP_prep2(data_prep.4, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.b,n_target=length(target_Record.Id.2),n_background = length(background_Record.Id.2),n_between=length(between_Record.Id.2))
  ### select subjects and variables from model from the imputed dataset
  model4.b.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model4.b.2$Record.Id_subset,c("Record.Id",names(model4.b.2$fulldata)[names(model4.b.2$fulldata) %in% variables.b])]
  ## add bp_group
  model4.b.2_sub2=merge(model4.b.2_sub,model4.b.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model4.b.2_sub2,paste(dirbase,"4.b.2/data_sub.xlsx",sep=""))


## model 5.a.2: women without cardiac event at time of imaging, all variables, 160/90
model5.a.2=bb_DP_prep2(data_prep.5, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a)
### select subjects and variables from model from the imputed dataset
model5.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model5.a.2$Record.Id_subset,c("Record.Id",names(model5.a.2$fulldata)[names(model5.a.2$fulldata) %in% variables.a])]
## add bp_group
model5.a.2_sub2=merge(model5.a.2_sub,model5.a.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
write_xlsx(model5.a.2_sub2,paste(dirbase,"5.a.2/data_sub.xlsx",sep=""))

## model 5.a.2_eventsince: all subjects without cardiac event at time of imaging, all variables, 140/90
### select subjects and variables from model from the imputed dataset + those with 
model5.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% c(bb_data_imp$Record.Id[bb_data$diag_min_datedif>0&!is.na(bb_data$diag_min_datedif)],model5.a.2$Record.Id_subset),c("Record.Id",names(model5.a.2$fulldata)[names(model5.a.2$fulldata) %in% variables.a])]
## add bp_group
model5.a.2_sub2=merge(model5.a.2_sub,model5.a.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
model5.a.2_sub2=model5.a.2_sub2[!is.na(model5.a.2_sub2$bp_group),]
write_xlsx(model5.a.2_sub2,paste(dirbase,"5.a.2_eventsince/data_sub.xlsx",sep=""))






