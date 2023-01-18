function [stats_hs] = extract_survival_hs(ukb_outcomes,selected_group,global_pseudotimes,events,events_ids,age_events,tag)

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

[p, fh1, stats, DATA] = MatSurv(timeToevent_full, ...
                         censored, ...
                         groups2,...
                         'LineColor',[0.22,0.54,0.00;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49],...
                           'XLim',[0 7],...
                           'YLim',[0.975*100 1*100],'legend',false,'TimeUnit','Years',...
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
exportgraphics(fh1,['survival_plot_HS_',tag,'.png']);
cd ..

overall_p = p;
pairwise_p = struct2table(stats.ParwiseStats).p_MC;
groups_12_p = pairwise_p(1);
groups_13_p = pairwise_p(2);
groups_23_p = pairwise_p(3);
all_p = [overall_p,groups_12_p,groups_13_p,groups_23_p];
disp(['              ',tag])
disp('              logrank p-value')
disp('    Overall    G:B        G:R        B:R')
disp(all_p)


%%%%%%%%%% Hazard rate
censored = ones(size(timeToevent_full,1),1);
censored(selected_group) = 0;
c1 = censored(string(groups2) == '0-0.18   ');
g1 = timeToevent_full(string(groups2) == '0-0.18   ');
c2 = censored(string(groups2) == '0.18-0.38');
g2 = timeToevent_full(string(groups2) == '0.18-0.38');
c3 = censored(string(groups2) == '0.38-0.78');
g3 = timeToevent_full(string(groups2) == '0.38-0.78');

fh2=figure;
[f,x] = ecdf(g1,'Censoring',c1,'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.22,0.54,0.00],'LineWidth',2)
hold on
[f,x] = ecdf(g2,'Censoring',c2,'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[0.10 0.48 0.64],'LineWidth',2)
[f,x] = ecdf(g3,'Censoring',c3,'function','cumulative hazard');
stairs(x,f.*100,'-','Color',[1 0.49 0.49],'LineWidth',2)
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
exportgraphics(fh2,['hazard_plot_HS_',tag,'.png']);
cd ..

pairwise_HR = struct2table(stats.ParwiseStats).HR_logrank;
groups_12_HR = pairwise_HR(1);
groups_13_HR = pairwise_HR(2);
groups_23_HR = pairwise_HR(3);
all_HR = [groups_12_HR,groups_13_HR,groups_23_HR];
disp(['         ',tag])
disp('       logrank Hazard ratio')
disp('    G:B        G:R        B:R')
disp(all_HR)

close all
end