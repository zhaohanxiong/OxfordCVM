## packages
library(ggplot2)
library(dplyr)
library(gridExtra)
library(ggpmisc)
library(scales)
library(tidyr)

## functions
rename2 <- function(renametable,var,indexcololdname,indexcolnewname){
  a=which(renametable[,indexcololdname]==var)
  newname=renametable[a,indexcolnewname]
  return(newname)
}

## data load
bb_data=read.csv("/Users/winok/Documents/Projects/UKBiobank/data/database/bb_data.csv")
names(bb_data)=gsub("X","",names(bb_data))
names(bb_data)=sub("\\.","-",names(bb_data))
names(bb_data)=sub("Record-Id","Record.Id",names(bb_data))

variablelist=read.csv("/Users/winok/Documents/Projects/UKBiobank/data/database/bb_variablelist.csv")
  
### dirbase
dirbase="/Users/winok/Documents/Projects/UKBiobank/BB_DP_all/"
dirbase="/Users/winok/Documents/Projects/UKBiobank/BB_DP_imp/"
dirbase="/Users/winok/Documents/Projects/UKBiobank/scripts/BB_DP2/"     #!!!

### models
model="1.a.1"
model="1.a.2"
model="1.a.2/cov"
model="1.a.2_excl"
model="1.a.3"
model="1.b.2"
model="4.a.2"
model="4.a.2_eventsince"
model="5.a.2_eventsince"

model="model4.a.2/old" #!!


type="_sub"
type="_sub_cov"
type="_imp"
type="_imp_cov"
type=""             #!!

## load data
    pseudotimes=read.csv(paste(dirbase,model,"/global_pseudotimes",type,".csv",sep=""))
    pseudotimes=pseudotimes[!duplicated(pseudotimes$RecordId),]
    names(pseudotimes)=c("Record.Id","bp_group","V1_pseudotimes")
    pseudotimes=merge(pseudotimes,bb_data,all.x=TRUE,by="Record.Id")
   
    
    var_weighting=read.csv(paste(dirbase,model,"/var_weighting",type,".csv",sep=""))
    thr_weighting=read.csv(paste(dirbase,model,"/thr_weighting",type,".csv",sep=""))[[1]]
    var_weighting2=var_weighting[var_weighting$Node_contributions>thr_weighting,]
    var_weighting2$var_names2=gsub("-2.0","",var_weighting2$var_names)
    var_weighting2$var_names=gsub("-2.1","",var_weighting2$var_names)
    var_weighting2$var_names=gsub("-0.0","",var_weighting2$var_names)
    for (var in var_weighting2$var_names2){
      if(var %in% variablelist$FieldID){
        var_weighting2$var_names2[var_weighting2$var_names2==var]=rename2(variablelist,var,"FieldID","Field")}
    }
    var_weighting2=var_weighting2[order(var_weighting2$Node_contributions,decreasing=TRUE),]
#write.csv(var_weighting2,paste(dirbase,model,"/var_weighting_names.csv",sep=""))

## plots
  ### per bp_group
      ggplot(pseudotimes,aes(y=V1_pseudotimes,x=as.factor(bp_group),fill=as.factor(bp_group)))+geom_boxplot()+geom_point(aes(fill=as.factor(bp_group)),position=position_jitterdodge())+scale_fill_discrete(breaks=c("0","1","2"),labels=c("Other","Healthy","Disease"))+ggtitle(paste(model,"disease category and BP",sep=" "))+theme(legend.title = element_blank(), axis.text.x = element_blank(),axis.title.x=element_blank())    
  
  ### with BP
      ggplot(pseudotimes,aes(x=V1_pseudotimes,y=`BPSys-2.0`,color=as.factor(bp_group)))+geom_point()+scale_color_discrete(breaks=c("0","1","2"), labels=c("Other","Healthy","Disease"))+ggtitle(paste(model,"DP score and Systolic BP",sep=" "))+theme(legend.title = element_blank())
      ggplot(pseudotimes,aes(x=V1_pseudotimes,y=`BPDia-2.0`,color=as.factor(bp_group)))+geom_point()+scale_color_discrete(breaks=c("0","1","2"), labels=c("Other","Healthy","Disease"))+ggtitle(paste(model,"DP score and Diastolic BP",sep=" "))+theme(legend.title = element_blank())
  
  ## redo asthetics
      ggplot(pseudotimes,aes(x=V1_pseudotimes,y=`BPSys-2.0`,color=as.factor(bp_group)))+geom_point()+scale_color_manual(breaks=c("1","0","2"), labels=c("Healthy","Other","Hypertensive"),values=c("green4","grey","red3"))+theme(legend.title = element_blank())+labs(title="Disease Progression Score and Blood pressure",x="Disease Progression Score",y= "Systolic Blood Pressure")
      
      pseudotimes %>%
        mutate(bp_group = factor(bp_group, levels=c("1", "0", "2"))) %>%
        ggplot(aes(y=V1_pseudotimes,fill=as.factor(bp_group)))+geom_boxplot()+scale_fill_manual(breaks=c("1","0","2"), labels=c("Healthy","Other","Hypertensive"),values=c("green4","grey","red3"))+theme(legend.title = element_blank(),legend.position = "bottom",text=element_text(size=22))+labs(y="Disease Progresion Score")
  ## different thresholds BP
      pseudotimes %>%
        mutate(bp_group2 =  ifelse(`BPSys-2.0`>129 | `BPDia-2.0`>79,"2",
                                   ifelse(`BPSys-2.0`<120 & `BPDia-2.0`<80,"1","0"))) %>%
        ggplot(aes(y=V1_pseudotimes,fill=as.factor(bp_group2)))+geom_boxplot()+scale_fill_manual(breaks=c("1","0","2"), labels=c("Healthy","Other","Hypertensive"),values=c("green4","grey","red3"))+theme(legend.title = element_blank(),legend.position = "bottom",text=element_text(size=22))+labs(y="Disease Progresion Score")
   ## density plots different threshold BP   
      pseudotimes %>%
        mutate(bp_group2 =  ifelse(`BPSys-2.0`>129 | `BPDia-2.0`>79,"2",
                                   ifelse(`BPSys-2.0`<120 & `BPDia-2.0`<80,"1","0"))) %>%
      ggplot(aes(x=V1_pseudotimes, fill=bp_group2)) +
        scale_fill_manual(breaks=c("1","0","2"), labels=c("Healthy","Other","Hypertensive"),values=c("green4","grey","red3"))+
        theme(legend.title = element_blank(),legend.position = "bottom",text=element_text(size=22))+labs(x="Disease Progresion Score")+
        geom_density(alpha=.5)
      
        ## redo asthetics
      ggplot(pseudotimes,aes(x=V1_pseudotimes,y=`BPSys-2.0`,color=as.factor(bp_group)))+geom_point()+scale_color_manual(breaks=c("1","0","2"), labels=c("Healthy","Other","Hypertensive"),values=c("green4","grey","red3"))+theme(legend.title = element_blank())+labs(x="HyperScore",y= "Systolic Blood Pressure")
  ## redo asthetics
      ggplot(pseudotimes,aes(x=V1_pseudotimes,y=`BPSys-2.0`,color=as.factor(bp_group)))+geom_point()+scale_color_manual(breaks=c("1","0","2"), labels=c("Healthy","Other","Hypertensive"),values=c("green4","grey","red3"))+theme(legend.title = element_blank(),legend.position = "bottom")+labs(x="HyperScore",y= "Systolic Blood Pressure")
           
  
  ## Diastolic
      ggplot(pseudotimes,aes(x=V1_pseudotimes,y=`BPDia-2.0`,color=as.factor(bp_group)))+geom_point()+scale_color_manual(breaks=c("1","0","2"), labels=c("Healthy","Other","Hypertensive Disease"),values=c("green4","grey","red3"))+theme(legend.title = element_blank())+labs(x="Disease Progression Score", "Systolic Blood Pressure")
  
  ## with disease at timepoint 2.0
      outvar=pseudotimes$`6150-2.0`
      outvar=pseudotimes$diag_min_datedif
      outvar=pseudotimes$`42008-0.0_datedif`
      # boxplot
      ggplot(pseudotimes,aes(y=V1_pseudotimes,x=as.factor(outvar),fill=as.factor(outvar)))+geom_boxplot()+geom_point(aes(fill=as.factor(outvar)),position=position_jitterdodge())+scale_fill_discrete(breaks=c("-7","-3","1","2","3","4"), labels=c("None","No answer","Heart Attack","Angina","Stroke","High BP"))+ggtitle(model)+theme(legend.title = element_blank(), axis.text.x = element_blank(),axis.title.x=element_blank())    
      # scatterplot
      ggplot(pseudotimes,aes(x=V1_pseudotimes,y=outvar,color=as.factor(bp_group)))+geom_point()+scale_color_discrete(breaks=c("0","1","2"), labels=c("Other","Healthy","Disease"))+ggtitle(model)+theme(legend.title = element_blank())
  
  
  ## table with multiple outcome measures
      outvars=bb_BMR_vars
      
      table=NULL
      for (outvar in outvars){
        formula=as.formula(paste("`",outvar,"`","~","V1_pseudotimes",sep=""))
        linMod <- glm(formula, data = pseudotimes)
        # Summary of the analysis
        b=unname(summary(linMod)$coefficients["V1_pseudotimes",])
        c=c(outvar,b)
        if (c[5]<0.05){
          table=rbind(table,c)
        } }
      colnames(table)=c("Variable","Estimate","Std.Error","t value","Pr(>|t|")
      table=as.data.frame(table)
      rownames(table)=table$Variable
      print(table)
      
      r=cor(pseudotimes[,"V1_pseudotimes"],pseudotimes[,outvar],use="pairwise.complete.obs")
      f=ggplot(pseudotimes,aes_string(x="V1_pseudotimes",y=outvar)) +
        geom_point()+
        geom_smooth(method="lm")+
        theme(legend.position = "top")+
        ggtitle(paste("r=",r))
      print(f)
      
      ### convert variable names
      table$Variable=gsub("-2.0","",table$Variable)
      table$Variable=gsub("-0.0","",table$Variable)
      
      for (var in table$Variable){
        if(var %in% variablelist$FieldID){
          table$Variable[table$Variable==var]=rename2(variablelist,var,"FieldID","Field")}
      }
  
      
  ## variable weightings
      i=0
      b=NULL
      list=list(bb_CMR_vars[bb_CMR_vars %in% names(bb_data)],bb_BMR_vars[bb_BMR_vars %in% names(bb_data)],bb_AMR_vars[bb_AMR_vars %in% names(bb_data)],bb_bodycomp_vars[bb_bodycomp_vars%in% names(bb_data)],bb_art_vars[bb_art_vars %in% names(bb_data)],bb_car_vars[bb_car_vars%in% names(bb_data)],bb_blood_vars[bb_blood_vars%in% names(bb_data)],bb_spir_vars[bb_spir_vars%in% names(bb_data)],bb_ecgrest_vars[bb_ecgrest_vars%in% names(bb_data)],Sex,Age)
      names(list)=c("bb_CMR_vars","bb_BMR_vars","bb_AMR_vars","bb_bodycomp_vars","bb_art_vars","bb_car_vars","bb_blood_vars","bb_spir_vars","bb_ecgrest_vars","Sex","Age")
      
      for (i in 1:length(list)){
        vars=unname(unlist(list[i]))
        name=names(list[i])
        a=as.data.frame(vars)
        a=cbind(a,rep(name,length(vars)))
        b=rbind(b,a)
      }
      names(b)=c("var_names","Modality")
     # b$var_names=gsub("\\-[0-9].[0-9]","",b$var_names)
      b=merge(b,var_weighting2)
      b$Modality=as.factor(b$Modality)
      
      
      for (var in b$var_names2){
        if(var %in% variablelist$FieldID){
          b$Variable[b$var_names2==var]=rename2(variablelist,var,"FieldID","Field")}
      }
      
      ### also weightings not significant in the model
      i=0
      c=NULL
      list=list(bb_CMR_vars[bb_CMR_vars %in% names(bb_data)],bb_BMR_vars[bb_BMR_vars %in% names(bb_data)],bb_AMR_vars[bb_AMR_vars %in% names(bb_data)],bb_bodycomp_vars[bb_bodycomp_vars%in% names(bb_data)],bb_art_vars[bb_art_vars %in% names(bb_data)],bb_car_vars[bb_car_vars%in% names(bb_data)],bb_blood_vars[bb_blood_vars%in% names(bb_data)],bb_spir_vars[bb_spir_vars%in% names(bb_data)],bb_ecgrest_vars[bb_ecgrest_vars%in% names(bb_data)],Sex,Age)
      names(list)=c("bb_CMR_vars","bb_BMR_vars","bb_AMR_vars","bb_bodycomp_vars","bb_art_vars","bb_car_vars","bb_blood_vars","bb_spir_vars","bb_ecgrest_vars","Sex","Age")
      
      for (i in 1:length(list)){
        vars=unname(unlist(list[i]))
        name=names(list[i])
        a=as.data.frame(vars)
        a=cbind(a,rep(name,length(vars)))
        c=rbind(c,a)
      }
      names(c)=c("var_names","Modality")
      
      c=merge(c,var_weighting)
      c$Modality=as.factor(c$Modality)
      
      c$var_names2=gsub("-2.0","",c$var_names)
      c$var_names=gsub("-2.1","",c$var_names)
      c$var_names=gsub("-0.0","",c$var_names)
      for (var in c$var_names2){
        if(var %in% variablelist$FieldID){
          c$var_names2[c$var_names2==var]=rename2(variablelist,var,"FieldID","Field")}
      }
      c=c[order(c$Node_contributions,decreasing=TRUE),]
      
      for (var in c$var_names2){
        if(var %in% variablelist$FieldID){
          c$Variable[c$var_names2==var]=rename2(variablelist,var,"FieldID","Field")}
      }
      
      
      ## average weighting per modality
      
      ggplot(b,aes(y=Node_contributions,x=Modality,fill=Modality))+geom_boxplot()
      ggplot(b,aes(x=Node_contributions))+geom_histogram()
      ggplot(b,aes(x=Node_contributions,fill=Modality))+geom_histogram()
      
      
      
      ggplot(b,aes(y=Node_contributions,x=Modality,fill=Modality))+geom_boxplot()+scale_fill_discrete(labels=c("Brain MRI","Body composition","Carotid artery","Cardiac MR","ECG rest",
                                                                                                               "Spirometry"))+labs(title="Weightings of variables by modality",x="",y="Weightings")+
        theme(axis.text.x = element_blank(),axis.ticks.x=element_blank(),legend.position = "bottom")

      
      b %>% 
        group_by(Modality) %>% 
        summarize(mean=mean(Node_contributions,na.rm=T))
      
      ggplot(b,aes(y=Node_contributions,x=Modality,fill=Modality))+geom_boxplot()+scale_fill_discrete(labels=c("Brain MRI","Body composition","Carotid artery","Cardiac MR","ECG rest", "Spirometry"))+labs(x="",y="Weightings")+theme(legend.title = element_blank(),text = element_text(size=22),axis.text.x = element_blank(),axis.ticks.x=element_blank(),legend.position = "bottom")
      
    ### bar graph weightings
      ggplot(data=b, aes(x=var_names2, y=Node_contributions,fill=Modality)) +
        geom_bar(stat="identity")
      ## remove BMR variables --> too many
      b_CU=b[b$Modality=="bb_car_vars",]
      b_CU=b_CU[b_CU$var_names2 !="Minimum carotid IMT (intima-medial thickness) at 210 degrees ",]
      b_CU=b_CU %>% 
        filter(Node_contributions>0.8)
      b_ECG_rest=b[b$Modality=="bb_ecgrest_vars",]
      b_ECG_rest=b_ECG_rest[b_ECG_rest$var_names2=="QRS num"|b_ECG_rest$var_names2=="QRS duration",]
      b$Modality[b$var_names2=="Body surface area"]="bb_bodycomp_vars"
      b_CMR=b[b$Modality=="bb_CMR_vars",]
      b_bodycomp=b[b$Modality=="bb_bodycomp_vars",]
      b_BMR=b[b$Modality=="bb_BMR_vars",]
      b_BMR=b_BMR %>% 
        filter(Node_contributions>1.1)
     b2=rbind(b_CMR,b_BMR,b_CU,b_ECG_rest,b_bodycomp)
     
     
      
     ggplot(data=b2, aes(x=var_names2, y=Node_contributions,fill=Modality)) +
       geom_bar(stat="identity") + xlab("") + ylab("Weightings") + theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.title=element_blank())+ scale_fill_discrete(labels=c("Brain MRI","Body composition","Carotid ultrasound","Cardiac MRI","ECG rest"))
     ggplot(data=b2, aes(x=var_names2, y=Node_contributions,fill=Modality)) +
       geom_bar(stat="identity") + xlab("variables") + ylab("Weightings") + theme(axis.text.x = element_blank(), axis.title=element_text(size=20), legend.title=element_blank(), legend.text=element_blank())

     
     ### all weightings
     c_CU=c[c$Modality=="bb_car_vars",]
     c_CU=c_CU[1:10,]
     c_CU$var_names2=sub("\\(intima-medial thickness\\) at ","",c_CU$var_names2)
     c_CU$var_names2=sub("Minimum","Min",c_CU$var_names2)
     c_CU$var_names2=sub("Maximum","Max",c_CU$var_names2)
     c_CU$var_names2=sub("degrees","deg",c_CU$var_names2)
     c_ECG_rest=c[c$Modality=="bb_ecgrest_vars",]
     c_ECG_rest=c_ECG_rest[1:10,]
     c$Modality[c$var_names2=="Body surface area"]="bb_bodycomp_vars"
     c_CMR=c[c$Modality=="bb_CMR_vars",]
     c_CMR=c_CMR[1:10,]
     c_CMR$var_names2=sub("Number of beats in waveform average for","number of beats",c_CMR$var_names2)
     c_CMR$var_names2=sub("Peripheral","",c_CMR$var_names2)
     c_bodycomp=c[c$Modality=="bb_bodycomp_vars",]
     c_bodycomp=c_bodycomp[1:10,]
     c_BMR=c[c$Modality=="bb_BMR_vars",]
     c_BMR=c_BMR[1:10,]
     c_BMR$var_names2=c("GMV cerebellum","GMV prancingulate","GMV pallidum","ICVF acoustic", "GMV caudate","FA lemniscus","GMV planum polare","GMV operculum","GMV occipital fusiform","T2star thalamus")
     c2=rbind(c_CMR,c_BMR,c_CU,c_ECG_rest,c_bodycomp)
     c2=na.omit(c2)
     
     ggplot(data=c2, aes(x=var_names2, y=Node_contributions,fill=Modality)) +
       geom_bar(stat="identity") + xlab("") + ylab("Weightings") + theme(axis.text.x = element_text(angle = 70, hjust = 1),legend.title=element_blank())+ scale_fill_discrete(labels=c("Brain MRI","Body composition","Carotid ultrasound","Cardiac MRI","ECG rest"))
     ggplot(data=c2, aes(x=var_names2, y=Node_contributions,fill=Modality)) +
       geom_bar(stat="identity") + xlab("variables") + ylab("Weightings") + theme(axis.text.x = element_blank(), axis.title=element_text(size=20), legend.title=element_blank(), legend.text=element_blank())
 
     ggplot(data=c2, aes(x=var_names2, y=Node_contributions,fill=Modality)) +
       geom_bar(stat="identity") + xlab("variables") + ylab("Weightings") + theme(axis.text.x = element_blank(), axis.title=element_text(size=20), legend.title=element_blank()) +
       scale_fill_discrete(labels=c("Brain MRI","Body composition","Carotid ultrasound","Cardiac MRI","ECG rest"))
     
          
### variation in parameters over time
      ## top parameter in each category
  length(levels(b$Modality)) #5
  
    # parameter 1.1
  a=b[b$Modality==levels(b$Modality)[1],]
  var1.1=a$var_names[order(-a$Node_contributions)][1]
  var1.1s=paste("`",var1.1,"`",sep="")
  var1.2=a$var_names[order(-a$Node_contributions)][2]
  var1.2s=paste("`",var1.2,"`",sep="")
  
  a=b[b$Modality==levels(b$Modality)[2],]
  var2.1=a$var_names[order(-a$Node_contributions)][1]
  var2.1s=paste("`",var2.1,"`",sep="")
  var2.2=a$var_names[order(-a$Node_contributions)][2]
  var2.2s=paste("`",var2.2,"`",sep="")
  
  a=b[b$Modality==levels(b$Modality)[3],]
  var3.1=a$var_names[order(-a$Node_contributions)][1]
  var3.1s=paste("`",var3.1,"`",sep="")
  var3.2=a$var_names[order(-a$Node_contributions)][2]
  var3.2s=paste("`",var3.2,"`",sep="")
  
  a=b[b$Modality==levels(b$Modality)[4],]
  var4.1=a$var_names[order(-a$Node_contributions)][1]
  var4.1s=paste("`",var4.1,"`",sep="")
  var4.2=a$var_names[order(-a$Node_contributions)][3]
  var4.2s=paste("`",var4.2,"`",sep="")
  
  a=b[b$Modality==levels(b$Modality)[5],]
  var5.1=a$var_names[order(-a$Node_contributions)][2]
  var5.1s=paste("`",var5.1,"`",sep="")
  var5.2=a$var_names[order(-a$Node_contributions)][3]
  var5.2s=paste("`",var5.2,"`",sep="")
  
  ## way 1 rescale mean square root
  data_wide=cbind(pseudotimes$V1_pseudotimes,as.data.frame(scale(pseudotimes[,c(var1.1,var1.2,var2.1,var3.1,var3.2,var4.1,var4.2,var5.1,var5.2)])))## scale data
  data_wide=as.data.frame(data_wide)
  names(data_wide)=c("V1_pseudotimes",c(var1.1,var1.2,var2.1,var3.1,var3.2,var4.1,var4.2,var5.1,var5.2))

  
## way 2: rescale 0 to 1  
  vars=c(var1.1,var1.2,var2.1,var3.1,var3.2,var4.1,var4.2,var5.1,var5.2)
  af=NULL
  for(col in vars) { 
    af2 <- rescale(pseudotimes[,col]) 
    af=cbind(af,af2)
  } 

  data_wide=cbind(pseudotimes$V1_pseudotimes,af)
  data_wide=as.data.frame(data_wide)
  names(data_wide)=c("V1_pseudotimes",c(var1.1,var1.2,var2.1,var3.1,var3.2,var4.1,var4.2,var5.1,var5.2))
                  
  ### then go to long format
  data_long=pivot_longer(data = data_wide, cols=-c(V1_pseudotimes),names_to = "Variables", values_to = "Value")
  
  variable_names=rev(c(var1.1,var1.2,var2.1,var3.1,var3.2,var4.1,var4.2,var5.1,var5.2))
  variable_names2=gsub("\\-[0-9].[0-9]","",variable_names)
  variable_names3=NULL
  for (var in variable_names2){
  variable_names3=rbind(variable_names3,rename2(variablelist,var,"FieldID","Field"))
  }

  ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,fullrange=TRUE)+ 
    scale_color_manual(name = "Variabes", labels = variable_names3, values=c("firebrick1","firebrick3","royalblue1","royalblue3","darkolivegreen1","darkolivegreen3","grey28","goldenrod1","goldenrod3"))+
    labs(x="Disease progression score",y="Scaled values")
  
  
        p=ggplot(pseudotimes,aes_string(y="V1_pseudotimes",x=var1.1))+geom_point()+geom_smooth(method="glm")+xlab(b$var_names2[b$var_names==c])
      # parameter 1.2
      
        a=a$var_names[order(-a$Node_contributions)][2]
      p=ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`22338-2.0`))+geom_point()+geom_smooth(method="glm")+xlab(b$var_names2[b$var_names==c])
      

       i=2
       #parameter 2.2 
  a=b[b$Modality==levels(b$Modality)[i],]
  a=a$var_names[order(-a$Node_contributions)][1]
      q=ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`23123-2.0`))+geom_point()+geom_smooth(method="glm")+xlab(b$var_names2[b$var_names==a])
      
      a=a$var_names[order(-a$Node_contributions)][2]
      q=ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`23123-2.0`))+geom_point()+geom_smooth(method="glm")+xlab(b$var_names2[b$var_names==a])
      
      i=3
  a=b[b$Modality==levels(b$Modality)[i],]
  a=a$var_names[order(-a$Node_contributions)][1]
     r=ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`22425-2.0`))+geom_point()+geom_smooth(method="glm")+xlab(b$var_names2[b$var_names==a])
     
     a=b[b$Modality==levels(b$Modality)[i],]
     a=a$var_names[order(-a$Node_contributions)][1]
     r=ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`22425-2.0`))+geom_point()+geom_smooth(method="glm")+xlab(b$var_names2[b$var_names==a])
     
     
       i=4
  a=b[b$Modality==levels(b$Modality)[i],]
  a=a$var_names[order(-a$Node_contributions)][1]
      s=ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`25913-2.0`))+geom_point()+geom_smooth(method="glm")+xlab(b$var_names2[b$var_names==a])

      grid.arrange(p,q,r,s, ncol=2)      
      
    ## by parameters of choice, even those not included in the model
      i=3
      a=grep("-2.0",bb_CMR_vars,value=TRUE)[i]
      formula=as.formula(paste0("V1_pseudotimes", "~", '`',a,'`',sep=""))
      ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`25913-2.0`))+geom_point()+stat_smooth(method="lm")+
        xlab(variablelist$Field[variablelist$FieldID==gsub("\\-[0-9].[0-9]","",a)])+
        stat_poly_eq(aes(label = paste(..rr.label..)), 
                     label.x.npc = "right", label.y.npc = 0.15,
                     formula = formula, parse = TRUE, size = 3)+
        stat_fit_glance(method="lm",method.args=list(formula=V1_pseudotimes ~ `25913-2.0`), geom = 'text',
                        aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                        label.x.npc = 'right', label.y.npc = 0.35, size = 3)
      

      i=3
      a=grep("-2.0",bb_CMR_vars,value=TRUE)[i]
      a="LVEF"
      formula=as.formula(paste0("V1_pseudotimes", "~", '`',a,'`',sep=""))
      ggplot(pseudotimes,aes(y=V1_pseudotimes,x=`22423-2.0`))+geom_point()+stat_smooth(method="glm")+
        xlab(variablelist$Field[variablelist$FieldID==gsub("\\-[0-9].[0-9]","",a)])+
        stat_poly_eq(aes(label = paste(..rr.label..)), 
                     label.x.npc = "right", label.y.npc = 0.15,
                     formula = formula, parse = TRUE, size = 3)+
        stat_fit_glance(method="lm",method.args=list(formula=V1_pseudotimes ~ `22423-2.0`), geom = 'text',
                        aes(label = paste("P-value = ", signif(..p.value.., digits = 4), sep = "")),
                        label.x.npc = 'right', label.y.npc = 0.35, size = 3)
  
      
#### long format plot of variables of choice
      
      vars=c("LVM__g_","LVEDV__mL_","RVEDV__mL_","LVEF","RVEF")
      vars=c("25020-2.0","25781-2.0","22671-2.0","22674-2.0","22677-2.0","22680-2.0") # right hippocampus, total volume of WMH,mean carotid IMD at 120degrees, 150 degrees, 210 degrees, 240 degrees
      vars=c("25020-2.0","25781-2.0","LVM__g_","LVEDV__mL_","22674-2.0") # right hippocampus, total volume of WMH,mean carotid IMD at 150 degrees, LVM_
      vars=c("vol_hip_avg","25781-2.0","LVM__g_","LVEDV__mL_","mean_IMT_avg-2.0") # right hippocampus, total volume of WMH,mean carotid IMD at 150 degrees, LVM_
      
      vars=c("BPSys-2.0","BPDia-2.0")
      vars=c("30740-1.0","30780-1.0","30690-1.0","3456-2.0","1558-2.0","21001-2.0") #glucose #LDL #cholesterol #current smoking #how often alcohol + # BMI
      vars=c("BPSys-2.0","BPDia-2.0","30690-1.0") ## level 1: BP + chol
      vars=c("BPSys-2.0","BPDia-2.0","30690-1.0","LVM__g_","22425-2.0","LVEDV__mL_","LVEF","RVEDV__mL_","RVEF") ## level 1: BP + chol + LVM + CI + LVEDV + LVEF + RVEDV + RVEF
      
      vars=c("25781-2.0","22425-2.0","mean_IMT_avg-2.0","23281-2.0") # total volume WMH, cardiac index, carotid ultrasound IMT mean, total mass fat percentage
      vars=c("25781-2.0","LVM__g_","mean_IMT_avg-2.0","23281-2.0") # total volume WMH, LVmass, carotid ultrasound IMT mean, total mass fat percentage
      vars=c("25781-2.0","25020-2.0","LVM__g_","22425-2.0","mean_IMT_avg-2.0") # total volume WMH, right hippocampus, LVmass, cardiac index, carotid ultrasound IMT mean
      
      ## adapted highest ranking variables
      vars=c("25913-2.0","25837-2.0","23123-2.0","mean_IMT_avg-2.0","22425-2.0","12673-2.0","22337-2.0","12338-2.0")
      vars=c("vol_hip_avg-2.0","25781-2.0","23104-2.0","mean_IMT_avg-2.0","22425-2.0","LVM__g_","22337-2.0","12338-2.0")
      
          #pseudotimes$hippocampus_lr=pseudotimes$`25019-2.0`+pseudotimes$`25781-2.0`
      #vars=c("hippocampus_lr","25781-2.0")
      
  ## if data is missing
            # vars2=c("eid","12187-2.0",Age, Sex, StudyDate, vars)
            # vars_index=which(colnames(bb_data_tot) %in% vars2)
            # bb_data1=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=200000,select=vars_index,na.strings = c("NA","-99.00","1900-01-01",",\"\",\"\",\"\""))
            # bb_data1=bb_data1[bb_data1$`12187-2.0`==0&!is.na(bb_data1$`12187-2.0`),]
            # bb_data2=fread("/Users/winok/Documents/Projects/UKBiobank/database/data_downloads/ukb41542.csv", nrows=300000, skip=200000,select=vars_index,na.strings =c("NA","","-99.00","1900-01-01",",\"\",\"\",\"\""))
            # names(bb_data2)=names(bb_data1)
            # bb_data2=bb_data2[bb_data2$`12187-2.0`==0&!is.na(bb_data2$`12187-2.0`),]
            # 
            # 
            # pseudotimes=read.csv(paste(dirbase,model,"/global_pseudotimes",type,".csv",sep=""))
            # pseudotimes=pseudotimes[!duplicated(pseudotimes$RecordId),]
            # names(pseudotimes)=c("Record.Id","bp_group","V1_pseudotimes")
            # pseudotimes=merge(pseudotimes,bb_data1,all.x=TRUE,by="Record.Id")
      
      
      ## way 1: scale 
      data_wide=cbind(pseudotimes$V1_pseudotimes,as.data.frame(scale(pseudotimes[,vars])))## scale data
      data_wide$`25781-2.0`=rescale(data_wide$`25781-2.0`)
      data_wide=as.data.frame(data_wide)
      names(data_wide)=c("V1_pseudotimes",vars)
      
      ### way 1+2
      af=NULL
      for(col in vars) { 
        af2 <- rescale(data_wide[,col]) 
        af=cbind(af,af2)
      } 
      data_wide=cbind(pseudotimes$V1_pseudotimes,af)
      data_wide=as.data.frame(data_wide)
      names(data_wide)=c("V1_pseudotimes",vars)
      
      ## way 2: rescale 0 to 1  
       af=NULL
      for(col in vars) { 
        af2 <- rescale(pseudotimes[,col]) 
        af=cbind(af,af2)
      } 
      
      data_wide=cbind(pseudotimes$V1_pseudotimes,af)
      data_wide=as.data.frame(data_wide)
      names(data_wide)=c("V1_pseudotimes",vars)
      
      
    ### then go to long format
      data_long=pivot_longer(data = data_wide, cols=-c(V1_pseudotimes),names_to = "Variables", values_to = "Value")
      
      variable_names=vars
      variable_names2=gsub("\\-[0-9].[0-9]","",variable_names)
      variable_names3=NULL
      for (var in variable_names2){
        variable_names3=rbind(variable_names3,rename2(variablelist,var,"FieldID","Field"))
      }
      
      ### add modality to long dataset by recoding from variablelist
      variable_cat=NULL
      for (var in variable_names2){
        variable_cat=rbind(variable_cat,rename2(variablelist,var,"FieldID","Path"))
      }
      a=strsplit(variable_cat," > ")
      variable_cat=sapply(a, "[[", 3)
      a=as.data.frame(cbind(vars,variable_names2,variable_names3,variable_cat))
      data_long$Modality=NA
      for (var in vars){
        data_long$Modality[data_long$Variables==var]=rename2(a,var,"vars","variable_cat")}
      data_long$Modality=as.factor(data_long$Modality)
      
      variable_names4=paste(a$variable_cat,variable_names3,sep=": ")
      
    ## plot
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,fullrange=TRUE)+ 
        scale_color_manual(name = "Variables",breaks=vars ,labels = variable_names3, values=c("firebrick1","firebrick3","royalblue1","royalblue3","darkolivegreen3"))+
        labs(x="HyperScore",y="Scaled values") 
      
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,fullrange=TRUE)+ 
        scale_color_manual(name = "Variables",breaks=vars ,labels = variable_names4, values=c("firebrick1","firebrick3","royalblue1","royalblue3","darkolivegreen3"))+
        labs(x="HyperScore",y="Scaled values") + theme(legend.title=element_blank(),legend.position = "bottom")+guides(color=guide_legend(ncol=3))
       
      
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,fullrange=TRUE)+ 
        scale_color_manual(name = "Variables",breaks=vars ,labels = variable_names3, values=c("firebrick1","firebrick3","royalblue1","royalblue3","darkolivegreen3"))+
        labs(x="HyperScore",y="Scaled values") + theme(legend.title=element_blank(),legend.position = "bottom")+guides(color=guide_legend(ncol=3))
      
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,fullrange=TRUE)+ 
        scale_color_discrete(name = "Variables",breaks=vars ,labels = variable_names4)+
        labs(x="HyperScore",y="Scaled values") + theme(legend.title=element_blank(),legend.position = "right")
      
      
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,fullrange=TRUE)+ 
        scale_color_manual(name = "Variables",breaks=vars ,labels = variable_names3, values=c("firebrick1","firebrick3","blueviolet","royalblue1","royalblue3","darkolivegreen3","darkolivegreen1","darkorange1","darkorange3"))+
        labs(x="HyperScore",y="Scaled values") 
      
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,fullrange=TRUE,method="loess")+ 
       scale_color_manual(name = "Variables",breaks=vars ,labels = variable_names4, values=c("firebrick1","firebrick3","blueviolet","darkorange1","royalblue1","royalblue3","darkolivegreen3","darkolivegreen1"))+
        labs(x="HyperScore",y="Scaled values") 
      
      ### GRANT APPLICATION FINAL
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,method="loess",fullrange=TRUE)+xlim(0,0.75)+
      scale_color_manual(name = "Variables",breaks=vars ,labels = c("Brain lesion volume", "Cardiac index","mean IMT","Fat percentage"), values=c("#F8766D","#00BF7D","#00B0F6","#E76BF3"))+
        labs(x="Disease progression",y="Normalised values") + theme(axis.title = element_text(size=20),legend.title=element_blank(),legend.text=element_text(size=20))
      
      ggplot(data_long, aes(x=V1_pseudotimes, y= Value, color= Variables))+geom_smooth(se=FALSE,method="loess",fullrange=TRUE)+xlim(0,0.75)+
        scale_color_discrete(name = "Variables",breaks=vars ,labels = c("Brain lesion volume","Hippocampus volume (r)","LV mass" ,"Cardiac index","Carotid IMT"
                                                                        ))+
        labs(x="Disease progression",y="Normalised values") + theme(axis.title = element_text(size=20),legend.title=element_blank(),legend.text=element_text(size=20))
      
      
      ## shorter titles
      variable_names3=rbind("hippocampus volume","white matter lesions volume","BMI","mean IMT","Cardiac index","Left ventricular mass","T axis","P duration")
     variable_names3=rbind("hippocampus volume","white matter hyperintensities volume","Left ventricular mass","Left ventricular end diastolic volume","Mean intima-medial thickness")
      variable_names4=paste(a$variable_cat,variable_names3,sep=": ")
      
  ### death data
      ## comparison in global pseudotimes of those who died and those who did not die
ggplot(pseudotimes, aes(y=V1_pseudotimes,x=died)) +geom_boxplot()
      
## disease of circulatory system (I) --> no people in this subset
pseudotimes$died_circ=0
pseudotimes$died_circ[grep("I",pseudotimes$cause_icd10_0)]=1

      
### person with normal values yet high disease progression score
test=pseudotimes[pseudotimes$`BPDia-2.0`<80 & pseudotimes$`BPDia-2.0`<120 & pseudotimes$`30690-1.0`<6.2&pseudotimes$V1_pseudotimes>0.3,]
      
  
## 3D plot
library(scatterplot3d)
attach(pseudotimes)
scatterplot3d(`25781-2.0`,LVM__g_,LVEDV__mL_, main="3D Scatterplot",xlab=variable_names3[1],ylab=variable_names3[2],zlab=variable_names3[3],color=bp_group)

scatterplot3d(V1_pseudotimes,LVM__g_,LVEDV__mL_, main="3D Scatterplot",xlab="HyperScore",ylab=variable_names3[2],zlab=variable_names3[3],color=bp_group)

scatterplot3d(V1_pseudotimes,LVM__g_,`25781-2.0`, main="3D Scatterplot",xlab="HyperScore",ylab="Left ventricular mass",zlab="White matter hyperintensities",color=bp_group)

scatterplot3d(data_wide,LVM__g_,`25781-2.0`, main="3D Scatterplot",xlab="HyperScore",ylab="Left ventricular mass",zlab="White matter hyperintensities",color=bp_group)

## Hypertensive vs normotensive threshold, 0=disease, 1=healthy
hpt=quantile(pseudotimes$V1_pseudotimes[pseudotimes$bp_group==2],probs=0.05)
ntt=quantile(pseudotimes$V1_pseudotimes[pseudotimes$bp_group==1],probs=0.95)
hpt-ntt  

