function [stats_hs] = extract_survival_hs_sex(ukb_outcomes,sex,selected_group,global_pseudotimes,events,events_ids,age_events,tag)

global_pseudotimes2 = global_pseudotimes(selected_group);
idx = zeros(length(global_pseudotimes2),1);
for i = 1:length(global_pseudotimes2)
    selected_score = global_pseudotimes2(i);
    if selected_score <= 0.18
       idx(i) = 1;
    end
    if (selected_score > 0.18) && (selected_score <= 0.38)
       idx(i) = 2;
    end
    if (selected_score > 0.38) && (selected_score <= 0.79)
       idx(i) = 3;
    end
end

C = unique(idx);
classes = cell.empty;
for k = 1:length(C)
    classes{k,1} = global_pseudotimes2(idx == k);
end
range_1  = [min(classes{1,1}) max(classes{1,1})];
range_2  = [min(classes{2,1}) max(classes{2,1})];
range_3  = [min(classes{3,1}) max(classes{3,1})];

ukb_outcomes_yob = double(ukb_outcomes.X34_0_0);
ukb_outcomes_mob = double(ukb_outcomes.X52_0_0);
ukb_outcomes_daob = double(ones(length(ukb_outcomes_mob),1));
ukb_outcomes_dob = datetime(ukb_outcomes_yob, ukb_outcomes_mob, ukb_outcomes_daob);

ukb_outcomes_doa = ukb_outcomes.X53_2_0;
ukb_outcomes_doa = datetime(ukb_outcomes_doa,'InputFormat','yyyy-MM-dd');
ukb_outcomes_ageatcPCA = ukb_outcomes_doa - ukb_outcomes_dob;
ukb_outcomes_ageatcPCA2 = hours(ukb_outcomes_ageatcPCA);
ukb_outcomes_ageatcPCA = ukb_outcomes_ageatcPCA2 ./ (24*365);

ukb_outcomes_ageatdeath_full = double(ukb_outcomes.X40007_0_0);
if events == 1
   ukb_outcomes_ageatdeath_full(events_ids) = age_events;
end
all_ids = [1:1:length(ukb_outcomes_ageatcPCA)]';
all_ids(selected_group) = [];
ukb_outcomes_ageatcPCA(all_ids) = 50;
ukb_outcomes_ageatdeath_full(all_ids) = 100;

timeToevent_full = ukb_outcomes_ageatdeath_full - ukb_outcomes_ageatcPCA;
censored = zeros(size(timeToevent_full,1),1);
censored(selected_group) = 1;

idx1 = find(global_pseudotimes <= range_1(2));
idx2 = find((global_pseudotimes > range_1(2)) & (global_pseudotimes <= range_2(2)));
idx3 = find((global_pseudotimes > range_2(2)));

labels_death_clusters = zeros(size(global_pseudotimes,1),1);
labels_death_clusters(idx1) = 1;
labels_death_clusters(idx2) = 2;
labels_death_clusters(idx3) = 3;
% 
% bp_group2 = string;
% bp_group2(labels_death_clusters == 1) = "0-0.18";
% bp_group2(labels_death_clusters == 2) = "0.18-0.38";
% bp_group2(labels_death_clusters == 3) = "0.38-0.78";
bp_group2 = sex;
groups = char(bp_group2);
groups2 = cell.empty;
for i = 1:length(groups)
    groups2{i,1} = groups(i,:);
end

[p, fh1, stats, DATA] = MatSurv(timeToevent_full, ...
                         censored, ...
                         groups2,...
                         'LineColor',[0.675 0.04 0.27;...
                           0.32 0.64 0.85],...
                           'XLim',[0 7],...
                           'YLim',[0.992*100 1*100],'legend',false,'TimeUnit','Years',...
                           'DispP',false,'PairWiseP',true,'NoRiskTable',true,...
                           'TimeMax',7,'Print',false);
stats_hs = stats;
fh1.Position = [624,378,556,407];
ax = gca;
ax.YTickMode = 'auto';
ax.XLabel.String = 'Time (years)';
ax.XLabel.FontWeight = 'bold';
ax.XLim = [0 8];
ax.XTick = [0:1:7];
ax.YLabel.String = 'Survival probability (%)';
ax.YLabel.FontWeight = 'bold';
ax.Color = [235/255 235/255 235/255];
grid on
ax.GridColor = [1 1 1];
ax.GridAlpha = 1;

cd([pwd,'/outcomes_analysis'])
exportgraphics(fh1,['survival_plot_Sex_',tag,'.png']);
cd ..

%%%% Female and Male plots
bp_group2 = string;
bp_group2(labels_death_clusters == 1) = "0-0.18";
bp_group2(labels_death_clusters == 2) = "0.18-0.38";
bp_group2(labels_death_clusters == 3) = "0.38-0.78";
bp_group2 = bp_group2';
groups = char(bp_group2);
groups2 = cell.empty;
for i = 1:length(groups)
    groups2{i,1} = groups(i,:);
end

[p_female, fh1_female, stats_female, DATA_female] = MatSurv(timeToevent_full(string(sex)=='Female'), ...
                         censored(string(sex)=='Female'), ...
                         groups2(string(sex)=='Female'),...
                         'LineColor',[0.22,0.54,0.00;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49],...
                           'XLim',[0 7],...
                           'YLim',[0.992*100 1*100],'legend',false,'TimeUnit','Years',...
                           'DispP',false,'PairWiseP',true,'NoRiskTable',true,...
                           'TimeMax',7,'Print',false,'NoPlot',true);
g1_female = DATA_female.GROUPS(1).KM_ALL(:,1:2);
g2_female = DATA_female.GROUPS(2).KM_ALL(:,1:2);
g3_female = DATA_female.GROUPS(3).KM_ALL(:,1:2); 


[p_male, fh1_male, stats_male, DATA_male] = MatSurv(timeToevent_full(string(sex)=='Male'), ...
                         censored(string(sex)=='Male'), ...
                         groups2(string(sex)=='Male'),...
                         'LineColor',[0.22,0.54,0.00;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49],...
                           'XLim',[0 7],...
                           'YLim',[0.992*100 1*100],'legend',false,'TimeUnit','Years',...
                           'DispP',false,'PairWiseP',true,'NoRiskTable',true,...
                           'TimeMax',7,'Print',false,'NoPlot',true);
g1_male = DATA_male.GROUPS(1).KM_ALL(:,1:2);
g2_male = DATA_male.GROUPS(2).KM_ALL(:,1:2);
g3_male = DATA_male.GROUPS(3).KM_ALL(:,1:2);

fh1_sex = figure;
fh1_sex.Position = [624,378,556,407];
ax = gca;
ax.FontSize = 14;
ax.YTickMode = 'auto';
ax.XLabel.String = 'Time (years)';
ax.XLabel.FontWeight = 'bold';
ax.XLabel.FontSize = 16;
ax.XLim = [0 8];
ax.XTick = [0:1:7];
ax.YLabel.String = 'Survival probability (%)';
ax.YLabel.FontWeight = 'bold';
ax.YLabel.FontSize = 16;
ax.Color = [235/255 235/255 235/255];
grid on
ax.GridColor = [1 1 1];
ax.GridAlpha = 1;

hold on

stairs(g1_female(:,1),g1_female(:,2).*100,'-','LineWidth',2,'Color',[0.94,0.48,0.64]);
stairs(g1_male(:,1),g1_male(:,2).*100,'--','LineWidth',2,'Color',[0.51,0.73,0.89]);

stairs(g2_female(:,1),g2_female(:,2).*100,'-','LineWidth',2,'Color',[0.81,0.25,0.45]);
stairs(g2_male(:,1),g2_male(:,2).*100,'--','LineWidth',2,'Color',[0.32,0.59,0.77]);

stairs(g3_female(:,1),g3_female(:,2).*100,'-','LineWidth',2,'Color',[0.53,0.05,0.22]);
stairs(g3_male(:,1),g3_male(:,2).*100,'--','LineWidth',2,'Color',[0.17,0.35,0.47]);


cd([pwd,'/outcomes_analysis'])
exportgraphics(ax,['survival_plot_SexHS_malefemale_',tag,'.png']);
cd ..



%%%%%%%%%% Hazard rate
censored = ones(size(timeToevent_full,1),1);
censored(selected_group) = 0;
c1 = censored(string(sex) == 'Female');
g1 = timeToevent_full(string(sex) == 'Female');
c2 = censored(string(sex) == 'Male');
g2 = timeToevent_full(string(sex) == 'Male');

fh2=figure;
[f,x] = ecdf(g1,'Censoring',c1,'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.675 0.04 0.27],'LineWidth',2)
hold on
[f,x] = ecdf(g2,'Censoring',c2,'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.32 0.64 0.85],'LineWidth',2)
hold off

fh2.Position = [624,378,556,407];
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 14;
ax.XLabel.FontSize = 16;
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'Time (years)';
ax.XLabel.FontWeight = 'bold';
ax.XLim = [0 8];
ax.XTick = [0:1:7];
ax.XMinorTick = 1;
ax.XAxis.MinorTickValues = 0:0.5:7;
set(gca,'TickDir','out');
ax.YTickMode = 'auto';
ax.YLabel.String = 'Cumulative hazard (%)';
ax.YLabel.FontWeight = 'bold';
ax.Color = [235/255 235/255 235/255];
grid on
ax.GridColor = [1 1 1];
ax.GridAlpha = 1;
box off

cd([pwd,'/outcomes_analysis'])
exportgraphics(fh2,['hazard_plot_Sex_',tag,'.png']);
cd ..


group_female = labels_death_clusters(string(sex) == 'Female');
group_male = labels_death_clusters(string(sex) == 'Male');
censored = ones(size(timeToevent_full,1),1);
censored(selected_group) = 0;
c1 = censored(string(sex) == 'Female');
g1 = timeToevent_full(string(sex) == 'Female');
c2 = censored(string(sex) == 'Male');
g2 = timeToevent_full(string(sex) == 'Male');

fh2_sex=figure;
hold on
[f,x] = ecdf(g1(group_female == 1),'Censoring',c1(group_female == 1),'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.94,0.48,0.64],'LineWidth',2)
[f,x] = ecdf(g2(group_male == 1),'Censoring',c2(group_male == 1),'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.51,0.73,0.89],'LineWidth',2)

[f,x] = ecdf(g1(group_female == 2),'Censoring',c1(group_female == 2),'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.81,0.25,0.45],'LineWidth',2)
[f,x] = ecdf(g2(group_male == 2),'Censoring',c2(group_male == 2),'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.32,0.59,0.77],'LineWidth',2)

[f,x] = ecdf(g1(group_female == 3),'Censoring',c1(group_female == 3),'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.53,0.05,0.22],'LineWidth',2)
[f,x] = ecdf(g2(group_male == 3),'Censoring',c2(group_male == 3),'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.17,0.35,0.47],'LineWidth',2)


fh2_sex.Position = [624,378,556,407];
ax = gca;
ax.LineWidth = 1.5;
ax.FontSize = 14;
ax.XLabel.FontSize = 16;
ax.YLabel.FontSize = 16;
ax.XLabel.String = 'Time (years)';
ax.XLabel.FontWeight = 'bold';
ax.XLim = [0 8];
ax.XTick = [0:1:7];
ax.XMinorTick = 1;
ax.XAxis.MinorTickValues = 0:0.5:7;
set(gca,'TickDir','out');
ax.YTickMode = 'auto';
ax.YLabel.String = 'Cumulative hazard (%)';
ax.YLabel.FontWeight = 'bold';
ax.Color = [235/255 235/255 235/255];
grid on
ax.GridColor = [1 1 1];
ax.GridAlpha = 1;
box off

cd([pwd,'/outcomes_analysis'])
exportgraphics(fh2_sex,['hazard_plot_SexHS_malefemale_',tag,'.png']);
cd ..

close all
end