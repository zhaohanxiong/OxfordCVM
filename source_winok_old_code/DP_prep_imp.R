library(rebus)
library(data.table)
library(writexl)
library(xlsx)
library(ggplot2)
library(dplyr)

DP_prep_cross3 <- function(data_dp,vars_included,target_Record.Id,background_Record.Id,perc_mis,cov){
  colnames=names(data_dp)[names(data_dp) %in% vars_included]
  data_dp=data_dp[,c("Record.Id","StudyName",colnames)]
  
  ### exclude columns with majority NA, for studies separatey
  for (study in unique(data_dp$StudyName)){
    a=which(colMeans(is.na(data_dp[data_dp$StudyName==study,which(names(data_dp) %in% vars_included)])) > 0.5)
    if (length(a)>0){
      data_dp=data_dp[,-which(names(data_dp) %in% names(a))]}
    ## exclude columns with the same value for everyone (including only NA), except of course the StudyName variable
    b=which(apply(bb_data, 2, function(x) length(unique(x)) == 1))
    if (length(b)>0){
      data_dp=data_dp[,-which(names(data_dp) %in% names(b)[!names(b) %in% "StudyName"])]}
  }
  
  
  
  if(missing(perc_mis)==FALSE){
  #remove rows with more than ... missing data
  c=apply(data_dp, MARGIN = 1, function(x) sum(is.na(x)))
  d=c<(ncol(data_dp)/100*perc_mis)
  data_dp=data_dp[d,]}
  
  ### code bp_group
  data_dp$bp_group=0
  data_dp$bp_group[data_dp$Record.Id%in%target_Record.Id]=2
  data_dp$bp_group[data_dp$Record.Id%in%background_Record.Id]=1
  
  list=list("data"=data_dp)
  
  if(missing(cov)==FALSE){
    ## delete subjects with missing data for covariates
    data_dp=data_dp[complete.cases(data_dp[,cov]),]
    cov_2=data_dp[,cov]
    list[[cov]]=cov_2
  }
  return(list)
} ## also exclude subjects with >??% missing data (default=5%)

bb_DP_prep2 <-function(dataset,target_Record.Id,background_Record.Id,between_Record.Id,variables,n_target=1000,n_background=1000,n_between=200,perc_mis,cov){
  target_Record.Id=target_Record.Id[!is.na(target_Record.Id)]
  background_Record.Id=background_Record.Id[!is.na(background_Record.Id)]
  between_Record.Id=between_Record.Id[!is.na(between_Record.Id)]
  
  data_dp=DP_prep_cross3(dataset,variables,target_Record.Id,background_Record.Id,perc_mis)
  
  data=list("fulldata"=data_dp$data)
  data$cov=data_dp$cov
  ### take the 1000 target and 1000 background subjects with most complete data + 200 in between
  data$Record.Id_subset=bb_subset(data$fulldata,n_target,n_background,n_between)
  return(data)
}

bb_subset <- function(dataset, n_target,n_background,n_between){
  target_Record.Id=dataset$Record.Id[dataset$bp_group==2]
  background_Record.Id=dataset$Record.Id[dataset$bp_group==1]
  between_Record.Id=dataset$Record.Id[dataset$bp_group==0]
  
  c=sort(apply(dataset[dataset$Record.Id %in% target_Record.Id,], MARGIN = 1, function(x) sum(is.na(x))))
  d=dataset[names(c[1:n_target]),"Record.Id"]
  f=sort(apply(dataset[dataset$Record.Id %in% background_Record.Id,], MARGIN = 1, function(x) sum(is.na(x))))
  g=dataset[names(f[1:n_background]),"Record.Id"]
  i=sort(apply(dataset[dataset$Record.Id %in% between_Record.Id,], MARGIN = 1, function(x) sum(is.na(x))))
  j=dataset[names(i[1:n_between]),"Record.Id"]
  Record.Id_subset=dataset$Record.Id[dataset$Record.Id %in% c(as.character(d),as.character(g),as.character(j))]
  return(Record.Id_subset)}  ## checks in the non-imputed database which records were most complete, returns list of subjects

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
dirbase="/Users/winok/Documents/Projects/UKBiobank/BB_DP2/model"

## remove values outside of 4SD from median
bb_data <- bb_data %>% mutate_if(is.numeric, outlier)

#### IMPUTE DATA WITH MATLAB
bb_data_or=bb_data
bb_data=bb_data[!is.na(bb_data$`BPSys-2.0`),]
write_xlsx(bb_data,paste(gsub("model","",dirbase),"bb_data_or.xlsx",sep=""))

### read in imputed data
bb_data=read.csv("/Users/winok/Documents/Projects/UKBiobank/BB_DP2/bb_data_imp_tot_outlrem2.csv")
bb_data$StudyName="BB"

### MODELS: number: population, number: target/background criteria, letter:variables

## read in imputed data + merge all imputed datasets
bb_data_imp=bb_data[,c("Record.Id","StudyName")]

for (file in list("data_imp_file_raw.csv","data_imp_file_raw2.csv","data_imp_file_raw3.csv","data_imp_file_raw4.csv","data_imp_file_raw6.csv","data_imp_file_raw7.csv","data_imp_file_raw8.csv","data_imp_file_raw9.csv","data_imp_file_raw10.csv")){
  file2=read.csv(paste("/Users/winok/Documents/Projects/UKBiobank/BB_DP2/",file,sep=""))
  file2_dup=duplicated(file2$Record.Id)
  file2=file2[!file2_dup,]
  bb_data_imp=merge(bb_data_imp,file2,all.x=TRUE,by="Record.Id")
  
  names=grep(".x",names(bb_data_imp),value=TRUE)
 if (length(names)>0){
  for (name.x in names){
    name=gsub(".x","",name.x)
    bb_data_imp[,name]=ifelse(is.na(bb_data_imp[,paste(name,".x",sep="")]),bb_data_imp[,paste(name,".y",sep="")],bb_data_imp[,paste(name,".x",sep="")])
  }
  bb_data_imp=bb_data_imp[,-grep(".x",names(bb_data_imp))]
  bb_data_imp=bb_data_imp[,-grep(".y",names(bb_data_imp))]
 }
 # print(table(is.na(bb_data_imp)))
}

names(bb_data_imp)=gsub("X","",names(bb_data_imp))
names(bb_data_imp)=sub("\\.","-",names(bb_data_imp))
names(bb_data_imp)=sub("Record-Id","Record.Id",names(bb_data_imp))

## remove rows that are empty except Record.Id and StudyName
d=bb_data_imp$Record.Id[apply(bb_data_imp[,3:ncol(bb_data_imp)], MARGIN = 1, function(x) sum(is.na(x)))==ncol(bb_data_imp)-2]
bb_data_imp=bb_data_imp[!bb_data_imp$Record.Id %in% d,]

bb_data_imp_or=bb_data_imp

## overlay on original dataset, if na in original dataset --> replace by value in imputed dataset
bb_data_imp=merge(bb_data, bb_data_imp_or,all.x=TRUE,by="Record.Id")
names2=names(bb_data_imp_or)[names(bb_data_imp_or) %in% names(bb_data)]
names2=names2[!names2 %in% "Record.Id"]
for (name in names2){
  bb_data_imp[,name]=ifelse(is.na(bb_data_imp[,paste(name,".x",sep="")]),bb_data_imp[,paste(name,".y",sep="")],bb_data_imp[,paste(name,".x",sep="")])
}
bb_data_imp=bb_data_imp[,-grep(".x",names(bb_data_imp))]
bb_data_imp=bb_data_imp[,-grep(".y",names(bb_data_imp))]


#models
## 1.a.1 = all subjects, all variables, 140/90 vs <120/80
  model1.a.1=bb_DP_prep2(data_prep.1, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.a)
  ### select subjects and variables from model from the imputed dataset
  model1.a.1_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.a.1$Record.Id_subset,c("Record.Id",names(model1.a.1$fulldata)[names(model1.a.1$fulldata) %in% variables.a])]
  ## add bp_group
  model1.a.1_sub2=merge(model1.a.1_sub,model1.a.1$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model1.a.1_sub2,paste(dirbase,"1.a.1/data_sub.xlsx",sep=""))

## 1.a.2 = all subjects, all variables, 160/100 vs <120/80
  model1.a.2=bb_DP_prep2(data_prep.1, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a)
  ### select subjects and variables from model from the imputed dataset
  model1.a.2_sub=bb_data_imp[bb_data_imp$Record.Id %in% model1.a.2$Record.Id_subset,c("Record.Id",names(model1.a.2$fulldata)[names(model1.a.2$fulldata) %in% variables.a])]
  ## add bp_group
  model1.a.2_sub2=merge(model1.a.2_sub,model1.a.2$fulldata[,c("Record.Id","bp_group")],all.x=TRUE)
  write_xlsx(model1.a.2_sub2,paste(dirbase,"1.a.2/data_sub.xlsx",sep=""))


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
model4.a.2=bb_DP_prep2(data_prep.4, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a)
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





