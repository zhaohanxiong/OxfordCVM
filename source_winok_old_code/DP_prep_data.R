
library(data.table)
library(rebus)
library(writexl)
library(xlsx)
library(dplyr)
library(tidyverse)
library(bit64)

### variables
# header
bb_data_tot=fread("../bb_data.csv",nrows=1) ## too big: read in files in chunks, select only those with MR data and only variables of interest, delete variable --> repeat
variablelist=read.csv("../bb_variablelist.csv")
variablelist$Field=as.character(variablelist$Field)
variablelist$FieldID=as.character(variablelist$FieldID)
bulkvars=variablelist$FieldID[variablelist$ItemType=="Bulk"|variablelist$ItemType=="Samples"|variablelist$ItemType=="Records"]
bulkvars=grep(paste("^",paste(bulkvars,collapse="-|^",sep=""),"-",sep=""),names(bb_data_tot),value=TRUE)

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

### Read in data
vars=c("eid","12187-2.0",Age, Sex, StudyDate, BPSys,BPSys2,BPDia,BPDia2,bb_CMR_vars,bb_BMR_vars,bb_AMR_vars,bb_bodycomp_vars,bb_art_vars,bb_blood_vars,bb_car_vars, bb_spir_vars,bb_ecgrest_vars,bb_antro_vars,bb_dis_vars,bb_med_vars)
vars_index=which(colnames(bb_data_tot) %in% vars)

### read in data: 
bb_data1=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=30000,select=vars_index,na.strings = c("NA","-99.00","1900-01-01",",\"\",\"\",\"\""))
bb_data1=bb_data1[bb_data1$`12187-2.0`==0&!is.na(bb_data1$`12187-2.0`),]
bb_data2=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=100000, skip=100000,select=vars_index,na.strings =c("NA","","-99.00","1900-01-01",",\"\",\"\",\"\""))
names(bb_data2)=names(bb_data1)
bb_data2=bb_data2[bb_data2$`12187-2.0`==0&!is.na(bb_data2$`12187-2.0`),]
bb_data3=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=100000, skip=200000,select=vars_index,na.strings =c("NA","","-99.00","1900-01-01",",\"\",\"\",\"\""))
names(bb_data3)=names(bb_data1)
bb_data3=bb_data3[bb_data3$`12187-2.0`==0&!is.na(bb_data3$`12187-2.0`),]
bb_data4=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=100000, skip=300000,select=vars_index,na.strings =c("NA","","-99.00","1900-01-01",",\"\",\"\",\"\""))
names(bb_data4)=names(bb_data1)
bb_data4=bb_data4[bb_data4$`12187-2.0`==0&!is.na(bb_data4$`12187-2.0`),]
bb_data5=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=100000, skip=400000,select=vars_index,na.strings =c("NA","","-99.00","1900-01-01",",\"\",\"\",\"\""))
names(bb_data5)=names(bb_data1)
bb_data5=bb_data5[bb_data5$`12187-2.0`==0&!is.na(bb_data5$`12187-2.0`),]
bb_data6=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=100000, skip=500000,select=vars_index,na.strings =c("NA","","-99.00","1900-01-01",",\"\",\"\",\"\""))
names(bb_data6)=names(bb_data1)
bb_data6=bb_data6[bb_data6$`12187-2.0`==0&!is.na(bb_data6$`12187-2.0`),]

bb_data=rbind(bb_data1,bb_data2,bb_data3,bb_data4,bb_data5,bb_data6)

rm(bb_data1,bb_data2,bb_data3,bb_data4,bb_data5,bb_data6)  

### new variables
bb_data=as.data.frame(bb_data)
bb_data$StudyName="BB"
bb_data$Record.Id=paste("BB",bb_data$eid,sep="")
bb_data$`BPSys-2.0`=ifelse(is.na(bb_data$`4080-2.0`),bb_data$`93-2.0`,bb_data$`4080-2.0`)
bb_data$`BPDia-2.0`=ifelse(is.na(bb_data$`4079-2.0`),bb_data$`94-2.0`,bb_data$`4079-2.0`)
bb_data$`mean_IMT_avg-2.0`=rowMeans(bb_data[,c("22671-2.0","22674-2.0","22677-2.0","22680-2.0")],na.rm=T) ## averaged across angles
bb_data$`max_IMT_avg-2.0`=rowMeans(bb_data[,c("22672-2.0","22675-2.0","22678-2.0","22681-2.0")],na.rm=T) ## averaged across angles
bb_data$`min_IMT_avg-2.0`=rowMeans(bb_data[,c("22670-2.0","22673-2.0","22676-2.0","22679-2.0")],na.rm=T) ## averaged across angles
bb_data$`vol_hip_avg-2.0`=rowMeans(bb_data[,c("25019-2.0","25020-2.0")],na.rm=T) ## left and right averaged


# recode empty space to NA in date fields
a=grep(number_range(42000,42013),names(bb_data_tot),value=TRUE)
b=seq(1,length(a),2)  ## select even numbers, those are the variables with dates
a=a[b]
a=c(StudyDate,a)

bb_data <- bb_data %>%
  mutate_at(all_of(vars(a)), ~ifelse(. =="", NA, .))

## calculate days before/since visit
bb_data$`42000-0.0_datedif` <- as.Date(bb_data$`42000-0.0`, format="%Y-%m-%d")-
  as.Date(bb_data$`53-2.0`, format="%Y-%m-%d")
bb_data$`42002-0.0_datedif` <- as.Date(bb_data$`42002-0.0`, format="%Y-%m-%d")-
  as.Date(bb_data$`53-2.0`, format="%Y-%m-%d")
bb_data$`42004-0.0_datedif` <- as.Date(bb_data$`42004-0.0`, format="%Y-%m-%d")-
  as.Date(bb_data$`53-2.0`, format="%Y-%m-%d")
bb_data$`42006-0.0_datedif` <- as.Date(bb_data$`42006-0.0`, format="%Y-%m-%d")-
  as.Date(bb_data$`53-2.0`, format="%Y-%m-%d")
bb_data$`42008-0.0_datedif` <- as.Date(bb_data$`42008-0.0`, format="%Y-%m-%d")-
  as.Date(bb_data$`53-2.0`, format="%Y-%m-%d")
bb_data$`42010-0.0_datedif` <- as.Date(bb_data$`42010-0.0`, format="%Y-%m-%d")-
  as.Date(bb_data$`53-2.0`, format="%Y-%m-%d")


### combination variable of maximum number of days before the visit (largest negative difference days)
a=as.data.frame(cbind(as.numeric(bb_data$`42000-0.0_datedif`),as.numeric(bb_data$`42002-0.0_datedif`),as.numeric(bb_data$`42004-0.0_datedif`),as.numeric(bb_data$`42006-0.0_datedif`),as.numeric(bb_data$`42008-0.0_datedif`),as.numeric(bb_data$`42010-0.0_datedif`)))
a$diag_min_datedif=apply(a,1,min,na.rm=TRUE)
a$diag_min_datedif[a$diag_min_datedif==Inf]<-NA

bb_data=cbind(bb_data,a$diag_min_datedif)
names(bb_data)[names(bb_data)=="a$diag_min_datedif"]="diag_min_datedif"


### data cleaning
bb_data1=bb_data
### data cleaning CMR, remove unrealistic values
bb_data <- bb_data %>%
  mutate_at(vars(grep("22426",names(bb_data),value=TRUE)), ~ifelse(. <35, NA, .)) %>%
  mutate_at(vars(grep("22426",names(bb_data),value=TRUE)), ~ifelse(. >130, NA, .)) %>%
  mutate_at(vars(grep("22427",names(bb_data),value=TRUE)), ~ifelse(. <1.5, NA, .)) %>%
  mutate_at(vars(grep("22427",names(bb_data),value=TRUE)), ~ifelse(. >25, NA, .)) %>%
  mutate_at(vars(grep("22425",names(bb_data),value=TRUE)), ~ifelse(. <1.5, NA, .)) %>%
  mutate_at(vars(grep("22425",names(bb_data),value=TRUE)), ~ifelse(. >6, NA, .)) %>%
  mutate_at(vars(grep("22424",names(bb_data),value=TRUE)), ~ifelse(. <3, NA, .)) %>%
  mutate_at(vars(grep("22424",names(bb_data),value=TRUE)), ~ifelse(. >12, NA, .)) %>%
  mutate_at(vars(grep("22420",names(bb_data),value=TRUE)), ~ifelse(. <30, NA, .)) %>%
  mutate_at(vars(grep("22420",names(bb_data),value=TRUE)), ~ifelse(. >80, NA, .)) %>%
  mutate_at(vars(grep("22421",names(bb_data),value=TRUE)), ~ifelse(. <60, NA, .)) %>%
  mutate_at(vars(grep("22421",names(bb_data),value=TRUE)), ~ifelse(. >240, NA, .)) %>%
  mutate_at(vars(grep("22422",names(bb_data),value=TRUE)), ~ifelse(. <10, NA, .)) %>%
  mutate_at(vars(grep("22422",names(bb_data),value=TRUE)), ~ifelse(. >100, NA, .)) %>%
  mutate_at(vars(grep("22423",names(bb_data),value=TRUE)), ~ifelse(. <30, NA, .)) %>%
  mutate_at(vars(grep("22423",names(bb_data),value=TRUE)), ~ifelse(. >150, NA, .))

### write files
write.csv(bb_data1,"/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/bb_data_or.csv")

write.csv(bb_data,"/Users/winok/Documents/Projects/UKBiobank/database/bb_data.csv")


## add death records + cardiac segmentation
death=read.csv("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/bb_data_DEATH.csv")
bb_data=merge(bb_data,death,all.x=TRUE)
death_cause=read.csv("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/bb_data_DEATH_CAUSE.csv")
death_cause=death_cause[death_cause$ins_index==0,]
death_cause=death_cause[,-which(names(death_cause)%in% c("ins_index","level"))]
death_cause=death_cause %>% pivot_wider(id_cols="eid",names_from="arr_index",values_from="cause_icd10",names_prefix="cause_icd10_",values_fill=NA)
death_cause=as.data.frame(death_cause)
bb_data=merge(bb_data,death_cause,all.x=TRUE,by="eid")
bb_data$died=ifelse(is.na(bb_data$cause_icd10_0),0,1)
bb_data$died=as.factor(bb_data$died)



cardiac_seg=read.csv("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukbreturn1886/UK Biobank Imaging Enhancement Cardiac Phenotypes.csv")
names(cardiac_seg)[names(cardiac_seg) %in% "eid"]="c_eid"
cardiac_seg_id=read.table("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukbreturn1886/ukb58244bridge18545.txt")
names(cardiac_seg_id)=c("eid","c_eid")
cardiac_seg=merge(cardiac_seg,cardiac_seg_id,all.x=TRUE)
cardiac_seg=cardiac_seg[,-which(names(cardiac_seg) %in% "c_eid")]
bb_data=merge(bb_data,cardiac_seg,all.x=TRUE, by="eid")
names(bb_data)[names(bb_data)=="eid"]="Record.Id"
  bb_data$LVM.LVEDV=bb_data$LVM__g_/bb_data$LVEDV__mL_

write.csv(bb_data,"/Users/winok/Documents/Projects/UKBiobank/database/bb_data.csv",row.names=FALSE)

## remove values outside of 4SD from median
bb_data <- bb_data %>% mutate_if(is.numeric, outlier)

#### IMPUTE DATA WITH MATLAB
bb_data_or=bb_data[!is.na(bb_data$`BPSys-2.0`),]
write_xlsx(bb_data_or,"/Users/winok/Documents/Projects/UKBiobank/BB_DP_imp/bb_data_or.xlsx")

