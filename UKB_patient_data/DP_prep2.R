library(rebus)
library(data.table)
library(writexl)
library(xlsx)
library(ggplot2)
library(dplyr)

DP_prep_cross3 <- function(data_dp,vars_included,target_Record.Id,background_Record.Id,perc_mis,cov){
  if(missing(perc_mis)){
    perc_mis=5
  }
  ### exclude columns with majority NA, for studies separatey
  for (study in unique(data_dp$StudyName)){
    a=which(colMeans(is.na(data_dp[data_dp$StudyName==study,which(names(data_dp) %in% vars_included)])) > 0.5)
    if (length(a)>0){
      data_dp=data_dp[,-which(names(data_dp) %in% names(a))]}
    ### exclude columns with only NA, for studies separately
    b=which(colSums(is.na(data_dp[data_dp$StudyName==study,])|data_dp[data_dp$StudyName==study,]==0)==nrow(data_dp[data_dp$StudyName==study,]))
    if (length(b)>0){
      data_dp=data_dp[,-which(names(data_dp) %in% names(b))]}
  }
  
  #remove rows with more than ... missing data
  c=apply(data_dp, MARGIN = 1, function(x) sum(is.na(x)))
  d=c<(length(c)/100*perc_mis)
  data_dp=data_dp[d,]
  
  ### code bp_group
  data_dp$bp_group=0
  data_dp$bp_group[data_dp$Record.Id%in%target_Record.Id]=2
  data_dp$bp_group[data_dp$Record.Id%in%background_Record.Id]=1
  
  colnames=names(data_dp)[names(data_dp) %in% vars_included]
  data_dp=data_dp[,c("Record.Id","StudyName",colnames, "bp_group")]
  
  list=list("data"=data_dp)
    
  if(missing(cov)==FALSE){
  ## delete subjects with missing data for covariates
  data_dp=data_dp[complete.cases(data_dp[,cov]),]
  cov_2=data_dp[,cov]
    list[[cov]]=cov_2
}
  return(list)
} ## also exclude subjects with >??% missing data (default=5%)

bb_DP_prep2 <-function(dataset,target_Record.Id,background_Record.Id,between_Record.Id,variables,n_target=1000,n_background=1000,n_between=200){
  target_Record.Id=target_Record.Id[!is.na(target_Record.Id)]
  background_Record.Id=background_Record.Id[!is.na(background_Record.Id)]
  between_Record.Id=between_Record.Id[!is.na(between_Record.Id)]
  
  data_dp=DP_prep_cross3(dataset,variables,target_Record.Id,background_Record.Id)
  data=list("fulldata"=data_dp$data)
  data$cov=data_dp$cov
  ### take the 1000 target and 1000 background subjects with most complete data + 200 in between
  data$sub=bb_subset(data$fulldata,n_target,n_background,n_between)
  return(data)
}

bb_subset <- function(dataset, n_target,n_background,n_between){
  target_Record.Id=dataset$Record.Id[dataset$bp_group==2]
  background_Record.Id=dataset$Record.Id[dataset$bp_group==1]
  between_Record.Id=dataset$Record.Id[dataset$bp_group==0]

  c=sort(apply(dataset[dataset$Record.Id %in% target_Record.Id,], MARGIN = 1, function(x) sum(is.na(x))))
  d=dataset[names(c[1:n_target]),"Record.Id"]
  #e=dataset[dataset$Record.Id %in% d,]
  f=sort(apply(dataset[dataset$Record.Id %in% background_Record.Id,], MARGIN = 1, function(x) sum(is.na(x))))
  g=dataset[names(f[1:n_background]),"Record.Id"]
  #h=dataset[dataset$Record.Id %in% g,]
  i=sort(apply(dataset[dataset$Record.Id %in% between_Record.Id,], MARGIN = 1, function(x) sum(is.na(x))))
  j=dataset[names(i[1:n_between]),"Record.Id"]
  #k=dataset[dataset$Record.Id %in% j,]
  dataset2=dataset[dataset$Record.Id %in% c(as.character(d),as.character(g),as.character(j)),]
  return(dataset2)
}  ## checks in the non-imputed database which records were most complete, returns new dataset

bb_subset <- function(dataset, n_target=1000,n_background=1000,n_between=200){
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

### MODELS: number: population, number: target/background criteria, letter:variables
 #models
    ## 1.a.1 = all subjects, all variables, 140/90 vs <120/80
    model1.a.1=bb_DP_prep2(data_prep.1, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.a)
    write_xlsx(model1.a.1$sub,paste(dirbase,"1.a.1/data_sub.xlsx",sep=""))
    
    ## 1.a.2 = all subjects, all variables, 160/100 vs <120/80
    model1.a.2=bb_DP_prep2(data_prep.1, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a)
    write_xlsx(model1.a.2$sub,paste(dirbase,"1.a.2/data_sub.xlsx",sep=""))
    
    ## 1.a.3= all subjects, all variables, those who have had an event at time of imaging vs no event at time of imaging or follow-up
    model1.a.3=bb_DP_prep2(data_prep.1, target_Record.Id.3,background_Record.Id.3,between_Record.Id.3,variables.a)
    write_xlsx(model1.a.3$sub,paste(dirbase,"1.a.3/data_sub.xlsx",sep=""))

    # 1.a.4= all subjects, all variables, those who have had an event at time of imaging vs no event at time of imaging or follow-up
    model1.a.4=bb_DP_prep2(data_prep.1, target_Record.Id.4,background_Record.Id.4,between_Record.Id.4,variables.a)
    write_xlsx(model1.a.4$sub,paste(dirbase,"1.a.4/data_sub.xlsx",sep=""))
    
    ## 1.b.1 = all subjects, CMR variables, 140/90 vs <120/80
    model1.b.1=bb_DP_prep2(data_prep.1, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.b)
    write_xlsx(model1.b.1$sub,paste(dirbase,"1.b.1/data_sub.xlsx",sep=""))

    ## 1.b.2 = all subjects, CMR variables, 160/100 vs <120/80
    model1.b.2=bb_DP_prep2(data_prep.1, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.b)
    write_xlsx(model1.b.2$sub,paste(dirbase,"1.b.2/data_sub.xlsx",sep=""))
    
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
    write_xlsx(model2.a.2$sub,paste(dirbase,"2.a.2/data_sub.xlsx",sep=""))
    
      
  ## model 3.a: men, all variables
    ## 3.a.1 = all subjects, all variables, 140/90 vs <120/80
    model3.a.1=bb_DP_prep2(data_prep.3, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.a)
    write_xlsx(model3.a.1$sub,paste(dirbase,"3.a.1/data_sub.xlsx",sep=""))
    
    ## 3.a.2 = all subjects, all variables, 160/100 vs <120/80
    model2.a.2=bb_DP_prep2(data_prep.3, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.a)
    write_xlsx(model3.a.2$sub,paste(dirbase,"3.a.2/data_sub.xlsx",sep=""))
    
  ## model 4.a.1: all subjects without cardiac event at time of imaging, all variables
    ## model 4.a.1: all subjects without cardiac event at time of imaging, all variables, 140/90
    model4.a.1=bb_DP_prep2(data_prep.4, target_Record.Id.1,background_Record.Id.1,between_Record.Id.1,variables.a)
    write_xlsx(model4.a.1$sub,paste(dirbase,"4.a.1/data_sub.xlsx",sep=""))
    
  ## model 4.d.2: all subjects without cardiac event at time of imaging, all variables
    ## model 4.d.2: all subjects without cardiac event at time of imaging, all variables, 140/90
    model4.d.2=bb_DP_prep2(data_prep.4, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.d)
    write_xlsx(model4.d.2$sub,paste(dirbase,"model4.d.2/data_sub.xlsx",sep=""))
    ## model 4.d.2: all subjects without cardiac event at time of imaging, all variables, 140/90; no in-between subjects
    model4.d.2_noinb=bb_DP_prep2(data_prep.4, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.d,n_target=1000,n_background=1000,n_between=0)
    write_xlsx(model4.d.2_noinb$sub,paste(dirbase,"model4.d.2_noinb/data_sub.xlsx",sep=""))
    ## model 4.d.2: all subjects without cardiac event at time of imaging, all variables, 140/90; no in-between subjects
    model4.d.2_400inb=bb_DP_prep2(data_prep.4, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.d,n_target=1000,n_background=1000,n_between=400)
    write_xlsx(model4.d.2_400inb$sub,paste(dirbase,"model4.d.2_400inb/data_sub.xlsx",sep=""))
    

    
### model 4.d.2 test --> put in between subjects last so they are easy to remove in MATLAB
    model4.d.2_400inb=bb_DP_prep2(data_prep.4, target_Record.Id.2,background_Record.Id.2,between_Record.Id.2,variables.d,n_target=1000,n_background=1000,n_between=400)
    model4.d.2_400inb_test=rbind(model4.d.2_400inb$sub[model4.d.2_400inb$sub$Record.Id %in% target_Record.Id.2,],model4.d.2_400inb$sub[model4.d.2_400inb$sub$Record.Id %in% background_Record.Id.2,],model4.d.2_400inb$sub[model4.d.2_400inb$sub$Record.Id %in% between_Record.Id.2,])
    write_xlsx(model4.d.2_400inb_test,paste(dirbase,"model4.d.2_400inb_test/data_sub.xlsx",sep=""))
    ### model 4.d.2 test 200 in between
    pseudotimes1=read.csv('/Users/winok/Documents/Projects/UKBiobank/BB_DP2/model4.d.2_400inb_test/model4.d.2/global_pseudotimes_sub.csv')
    names(pseudotimes1)=c("Record.Id","bp_group","global_pseudotimes1")
    pseudotimes2=read.csv('/Users/winok/Documents/Projects/UKBiobank/BB_DP2/model4.d.2_400inb_test/model4.d.2_200inb/global_pseudotimes_sub.csv')
    names(pseudotimes2)=c("Record.Id","bp_group","global_pseudotimes2")
    pseudotimes3=read.csv('/Users/winok/Documents/Projects/UKBiobank/BB_DP2/model4.d.2_400inb_test/global_pseudotimes_sub.csv')
    names(pseudotimes3)=c("Record.Id","bp_group","global_pseudotimes3")
    pseudotimes=merge(pseudotimes3,pseudotimes2, all.x=TRUE)    
    pseudotimes=merge(pseudotimes,pseudotimes1, all.x=TRUE)    
    pseudotimes$diff1=pseudotimes$global_pseudotimes3-pseudotimes$global_pseudotimes2
    pseudotimes$diff2=pseudotimes$global_pseudotimes3-pseudotimes$global_pseudotimes1
    