library(data.table)
library(rebus)
library(writexl)
library(xlsx)
library(dplyr)

## data
bb_data=read.csv("/Users/winok/Documents/Projects/UKBiobank/data/database/bb_data.csv")
names(bb_data)=gsub("X","",names(bb_data))
names(bb_data)=sub("\\.","-",names(bb_data))
names(bb_data)=sub("Record-Id","Record.Id",names(bb_data))
bb_data$Record.Id=paste("BB",bb_data$Record.Id,sep="")

bb_data$StudyName="BB"

### functions
bb_DP_prep3 <-function(dataset,target_Record.Id,background_Record.Id,between_Record.Id,variables,perc_mis_M=5,perc_mis=20,cov=NULL){
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
  
  if(is.null(cov)==FALSE){
    ## delete subjects with missing data for covariates
    data_dp=data_dp[complete.cases(data_dp[,cov]),]
    cov_2=data_dp[,cov]
    data_dp=data_dp[,-which(names(data_dp) %in% cov)]
  }
  if(is.null(cov)==TRUE){
    cov_2=0
  }
  
  list=list("data"=data_dp,
            "variables"=names(data_dp)[!names(data_dp)%in%"bp_group"],
            "cov"=cov_2,
            "perc_missing_model"=perc_mis_M,
            "perc_missing"=perc_mis)
  
  return(list)
}

bb_DP_prep2 <-function(dataset,target_Record.Id,background_Record.Id,between_Record.Id,variables){
  target_Record.Id=target_Record.Id[!is.na(target_Record.Id)]
  background_Record.Id=background_Record.Id[!is.na(background_Record.Id)]
  between_Record.Id=between_Record.Id[!is.na(between_Record.Id)]
  
  data_dp=DP_prep_cross3(dataset,variables,target_Record.Id,background_Record.Id)
  data=list("fulldata"=data_dp$data)
  data$cov=data_dp$cov
  ### take the 1000 target and 1000 background subjects with most complete data + 200 in between
  data$sub=bb_subset(data$fulldata,1000,1000,200)
  return(data)
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

bb_subset   <- function(dataset, n_target=1000,n_background=1000,n_between=200){
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

### variables
    # header
    bb_data_tot=fread("/Users/winok/Documents/Projects/UKBiobank/data/database/data_downloads/ukb42704.csv",nrows=1) ## too big: read in files in chunks, select only those with MR data and only variables of interest, delete variable --> repeat
    variablelist=read.csv("/Users/winok/Documents/Projects/UKBiobank/data/database/data_downloads/bb_variablelist_or.csv")
    variablelist$Field=as.character(variablelist$Field)
    variablelist$FieldID=as.character(variablelist$FieldID)
    bulkvars=variablelist$FieldID[variablelist$ItemType=="Bulk"|variablelist$ItemType=="Samples"|variablelist$ItemType=="Records"]
    bulkvars=grep(paste("^",paste(bulkvars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    stratavars=variablelist$FieldID[variablelist$Strata=="Auxiliary"|variablelist$Strata=="Supporting"] # only include primary variables - exclude auxilliary and supplementary variables
    stratavars=grep(paste("^",paste(stratavars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    
    ## Demographic
    Sex="31-0.0"
    Age=grep("^21003-",names(bb_data_tot),value=TRUE)
    ## other, date of imaging visit
    StudyDate=grep("^53-",names(bb_data_tot),value=TRUE)
    
    
    ## blood pressure
    BPSys=grep("^4080-",names(bb_data_tot),value=TRUE)
    BPSys2=grep("^93-",names(bb_data_tot),value=TRUE)
    BPDia=grep("^4079-",names(bb_data_tot),value=TRUE)
    BPDia2=grep("94-2.0",names(bb_data_tot),value=TRUE)
    
    ## diagnosis vars
    bb_dis_vars=variablelist$FieldID[variablelist$Category>42&variablelist$Category<51] ## 
    bb_dis_vars=bb_dis_vars[seq(1,length(bb_dis_vars),2)] ## select even numbers, those are the variables with dates
    bb_dis_vars=grep(paste("^",paste(bb_dis_vars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    ## cause of death
    bb_dis_vars=c(bb_dis_vars,grep("^40000-|^40001-|^40002-|^40007-",names(bb_data_tot),value=TRUE))
    
    ## medication vars
    bb_med_vars=variablelist$FieldID[variablelist$Category=="100045"]
    bb_med_vars=grep(paste("^",paste(bb_med_vars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    
    ### vars of interest
    ## brain MR
    bb_BMR_vars=variablelist$FieldID[variablelist$Category==110|variablelist$Category==112|variablelist$Category==1102|variablelist$Category==109|variablelist$Category==134|variablelist$Category==135|variablelist$Category==1101] 
    bb_BMR_vars=grep(paste("^",paste(bb_BMR_vars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    ## exclude certain variables
    excl=grep(paste("^",paste(c("20216","25756","25757","25757","25758","25759","25746"),collapse="-|^",sep=""),"-",sep=""),bb_BMR_vars,value=TRUE)
    bb_BMR_vars=bb_BMR_vars[!bb_BMR_vars %in% excl]
    bb_BMR_vars=bb_BMR_vars[!bb_BMR_vars %in% bulkvars]
    
    ## cardiac MR
    # removed all blood pressure related varialbes, kept cardiac structure and heart rate variables, kept pulse pressure
    bb_CMR_vars=grep("^22426-|^22425-|^22424-|^22420-|^22421-|^22422-|^22423-|^12702-|^12682-|^12673-|^12679-|^12676-|^12686-|^12685-|^22427-",names(bb_data_tot),value=TRUE)
    bb_CMR_vars=bb_CMR_vars[!bb_CMR_vars %in% bulkvars]
    cardiac_seg=read.csv("/Users/winok/Documents/Projects/UKBiobank/data/database/data_downloads/ukbreturn1886/UK Biobank Imaging Enhancement Cardiac Phenotypes.csv")
    bb_CMR_vars=c(bb_CMR_vars,names(cardiac_seg)[2:length(names(cardiac_seg))])
    
    ## abdominal MR
    bb_AMR_vars=variablelist$FieldID[variablelist$Category==126|variablelist$Category==149]
    bb_AMR_vars=grep(paste("^",paste(bb_AMR_vars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    excl=grep(paste("^",paste(c("22412","22414"),collapse="-|^",sep=""),"-",sep=""),bb_AMR_vars,value=TRUE)
    bb_AMR_vars=bb_AMR_vars[!bb_AMR_vars %in% excl]
    bb_AMR_vars=bb_AMR_vars[!bb_AMR_vars %in% bulkvars]
    
    ## Body composition
    bb_bodycomp_vars=variablelist$FieldID[variablelist$Category==124|variablelist$Category==125|variablelist$Category==100009|variablelist$Category==170]
    bb_bodycomp_vars=grep(paste("^",paste(bb_bodycomp_vars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    
    ## arterial stiffness
    bb_art_vars=variablelist$FieldID[variablelist$Category==100007]
    excl=grep("^4186-|^2404-|^2405-",bb_art_vars,value=TRUE)
    bb_art_vars=bb_art_vars[!bb_art_vars %in% excl]
    bb_art_vars=bb_art_vars[!bb_art_vars %in% bulkvars]
    
    ## carotid ultrasound
    bb_car_vars=variablelist$FieldID[variablelist$Category==101]
    bb_car_vars=grep(paste("^",paste(bb_car_vars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    excl=grep(paste("^",paste(c("22682","22683","22684","22685","12291","12292"),collapse="-|^"),"-",sep=""),bb_car_vars,value=TRUE)
    bb_car_vars=bb_car_vars[!bb_car_vars %in% excl]
    bb_car_vars=bb_car_vars[!bb_car_vars %in% bulkvars]
    
    ## spirometry
    bb_spir_vars=grep("^20151-|^20150-|^20153-|^20258-|^20156-|^20154-",names(bb_data_tot),value=TRUE)
    
    ## ECG
    bb_ecgrest_vars=grep("^12336-|^12338-|^22334-|^22330-|^22338-|^12340-|^22331-|^22332-|^22333-|^22335-|^22336-|^22337-",names(bb_data_tot),value=TRUE)
    
    ##blood
    ## percentages of blood are coded with tens, the other variables refer to the methods of sample analysis
    bb_blood_vars=variablelist$FieldID[variablelist$Category==100081|variablelist$Category==17518|variablelist$Category==100083]
    bb_blood_vars=grep(paste("^",paste(bb_blood_vars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)
    excl=grep("^30505-|^30515-|^30525-|^30535-",bb_blood_vars,value=TRUE)
    bb_blood_vars=bb_blood_vars[!bb_blood_vars %in% excl]
    
    ## antropometric
    range=number_range(46,51)
    bb_antro_vars=grep(range,names(bb_data_tot),value=TRUE)
    
### combine variables
    vars=c("eid","12187-2.0",Age, Sex, StudyDate, BPSys,BPSys2,BPDia,BPDia2,bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,bb_art_vars,bb_blood_vars,bb_car_vars, bb_spir_vars,bb_ecgrest_vars,bb_antro_vars,bb_dis_vars,bb_med_vars)
    vars=vars[!vars %in% c(bulkvars,stratavars)]
    vars_2=c(grep("\\-2.0",c(Age, StudyDate,BPSys,BPSys2,BPDia,BPDia2,bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,bb_art_vars,bb_blood_vars,bb_car_vars,bb_ecgrest_vars,bb_antro_vars),value=TRUE),grep("\\-2.",bb_CMR_vars,value=TRUE),bb_spir_vars,bb_dis_vars,bb_med_vars)
    vars_2=vars[!vars_2 %in% c(bulkvars,stratavars)]
    
    #all
    variables.a=vars_2[vars_2 %in% c(bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,bb_art_vars,bb_car_vars,bb_blood_vars,bb_spir_vars,bb_ecgrest_vars,Sex,Age)]
    #cardiac
    variables.b=vars_2[vars_2 %in% c(bb_CMR_vars,bb_art_vars,bb_car_vars)]
    #brain
    variables.c=vars_2[vars_2 %in% bb_BMR_vars]
    ## cardiac + brain + carotid ultrasound
    variables.d=vars_2[vars_2 %in% c(bb_CMR_vars,bb_BMR_vars,bb_art_vars,bb_car_vars,Sex,Age)]
    
# population
    #all
    data_prep.1=bb_data[bb_data$Record.Id %in% bb_data$Record.Id[!is.na(bb_data$`BPSys-2.0`)],]
    # only women
    data_prep.2=bb_data[bb_data$Record.Id %in% bb_data$Record.Id[!is.na(bb_data$`BPSys-2.0`)&bb_data[,Sex]=="0"],]
    # only men
    data_prep.3=bb_data[bb_data$Record.Id %in% bb_data$Record.Id[!is.na(bb_data$`BPSys-2.0`)&bb_data[,Sex]=="1"],]
    # exclude those with heart attack/angina/stroke at time of imaging
    data_prep.4=bb_data[bb_data$Record.Id %in% bb_data$Record.Id[!is.na(bb_data$`BPSys-2.0`)&(bb_data$`6150-2.0`<0|bb_data$`6150-2.0`>3|is.na(bb_data$`6150-2.0`))&(bb_data$diag_min_datedif>0|is.na(bb_data$diag_min_datedif))],]  
    # only women: exclude those with heart attack/angina/stroke at time of imaging
    data_prep.5=bb_data[bb_data$Record.Id %in% bb_data$Record.Id[!is.na(bb_data$`BPSys-2.0`)&bb_data[,Sex]=="0"&(bb_data$`6150-2.0`<0|bb_data$`6150-2.0`>3|is.na(bb_data$`6150-2.0`))&(bb_data$diag_min_datedif>0|is.na(bb_data$diag_min_datedif))],]  


## target/background criteria
    ## >140/80
    target_Record.Id.1=bb_data$Record.Id[bb_data$`BPSys-2.0`>140|bb_data$`BPDia-2.0`>90]
    background_Record.Id.1=bb_data$Record.Id[bb_data$`BPSys-2.0`<120&bb_data$`BPDia-2.0`<80]
    between_Record.Id.1=bb_data$Record.Id[-which(bb_data$Record.Id %in% c(as.character(background_Record.Id.1),as.character(target_Record.Id.1)))]
    
    ## >160/100
    target_Record.Id.2=bb_data$Record.Id[bb_data$`BPSys-2.0`>160|bb_data$`BPDia-2.0`>100]
    background_Record.Id.2=bb_data$Record.Id[bb_data$`BPSys-2.0`<120&bb_data$`BPDia-2.0`<80]
    between_Record.Id.2=bb_data$Record.Id[-which(bb_data$Record.Id %in% c(as.character(background_Record.Id.2),as.character(target_Record.Id.2)))]

    ## target: event at time of imaging. Background: no event, no event on follow
    target_Record.Id.3=bb_data$Record.Id[bb_data$`6150-2.0`>0&bb_data$`6150-2.0`<4]
    background_Record.Id.3=bb_data$Record.Id[(bb_data$`6150-2.0`<0|bb_data$`6150-2.0`==4)&(bb_data$`6150-3.0`<0|bb_data$`6150-3.0`==4)]
    between_Record.Id.3=bb_data$Record.Id[-which(bb_data$Record.Id %in% c(as.character(background_Record.Id.3),as.character(target_Record.Id.3)))]
    
    ## target: no event at time of imaging, but at follow-up. Background: no event, no event on follow-up, low BP
    target_Record.Id.4=bb_data$Record.Id[(bb_data$`6150-2.0`>0&bb_data$`6150-2.0`<4)&(bb_data$`6150-3.0`>0|bb_data$`6150-3.0`<4)]
    background_Record.Id.4=bb_data$Record.Id[(bb_data$`6150-2.0`<0|bb_data$`6150-2.0`==4)&(bb_data$`6150-3.0`<0|bb_data$`6150-3.0`==4)]
    between_Record.Id.4=bb_data$Record.Id[-which(bb_data$Record.Id %in% c(as.character(background_Record.Id.4),as.character(target_Record.Id.4)))]
    




