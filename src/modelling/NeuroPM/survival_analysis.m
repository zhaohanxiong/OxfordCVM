%% Survival analysis

years = 2015:2021;
data_size = length(ukb_outcomes_death2_sorted);
failure_time = single.empty;
number_failed = single.empty;
number_atrisk = single.empty;
survival_data = single.empty;
for yr_id = 1:length(years)
    failure_time(yr_id,1) = years(yr_id);
    selected_year = years(yr_id);
    number_failed(yr_id,1) = length(find(ukb_outcomes_death2_sorted.Year == selected_year) == 1);
    number_atrisk(yr_id,1) = data_size;
    data_size = data_size - number_failed(yr_id,1);
    
    survival_data(yr_id,:) = [failure_time(yr_id,1),number_failed(yr_id,1),number_atrisk(yr_id,1)];
end

y = survival_data(:,1);
freq = survival_data(:,2);
f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(ax1,y,'frequency',freq,'function','survivor','Bounds','off')
set(findall(ax1, 'Type', 'Stair'),'LineWidth',2,'Color',[1 0.37 0.49]);
xlabel('Year of death')
ylabel('Survival probability')
box off
xlim([min(years) max(years)])
ylim([-0.05 1.05])
ax1.FontSize = 20;
exportgraphics(f,'km_years.png');



data_size = length(ukb_outcomes_death2_sorted);
failure_time = datetime.empty;
number_failed = single.empty;
number_atrisk = single.empty;
for date_id = 1:length(ukb_outcomes_death2_sorted)
    failure_time(date_id,1) = ukb_outcomes_death2_sorted(date_id);
    selected_date = ukb_outcomes_death2_sorted(date_id);
    
    
    number_failed(date_id,1) = length(find(ukb_outcomes_death2_sorted == selected_date) == 1);
    
    number_atrisk(date_id,1) = data_size;
    data_size = data_size - number_failed(date_id,1);
end

y = failure_time.Month;
years = failure_time.Year;
years = years - 2015;
y = y + 12*years;

freq = number_failed;
f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(ax1,y,'frequency',freq,'function','survivor','Bounds','off')
set(findall(ax1, 'Type', 'Stair'),'LineWidth',2,'Color',[1 0.37 0.49]);
% xlabel('Year of death')
% ylabel('Survival probability')
box off
xlim([y(1) 12*length(2015:2021)])
ylim([-0.05 1.05])
ax1.FontSize = 25;
ax = gca;
ax.XLabel = [];
ax.YLabel = [];
ax.XTick = [12:12:12*length(2015:2021)];
ax.XTickLabels = {'2015','2016','2017','2018','2019','2020','2021'};
exportgraphics(f,'km_years_detailed.png');

%% Survival analysis [Control elevated hypertensive]
timeToevent = ukb_outcomes_ageatdeath - age_of_cPCA;

Elevated = timeToevent(labels_death==0);
Control = timeToevent(labels_death==1);
Hypertensive = timeToevent(labels_death==2);

nonzero = timeToevent(timeToevent>=0);

censored = ones(size(timeToevent,1),1);
groups2 = cell.empty;
for i = 1:length(groups)
    groups2{i,1} = 'Death';
end
% f = figure('Position',[476,335,764,643])
[p, fh0, stats] = MatSurv(timeToevent(timeToevent>=0), ...
                         censored(timeToevent>=0), ...
                         groups2(timeToevent>=0),...
                         'LineColor',[1 0.37 0.49],...
                           'XLim',[0 30]);
exportgraphics(fh0,'km_new0.png');




f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(gca,Control(Control>=0),'function','survivor','Bounds','off');
hold on
ecdf(Elevated(Elevated>=0),'function','survivor','Bounds','off');
ecdf(Hypertensive(Hypertensive>=0),'function','survivor','Bounds','off');
legend('Control','Elevated','Hypertensive')
stairs = findall(ax1, 'Type', 'Stair');
set(stairs(3),'LineWidth',2,'Color',[0.49 1 0.49]);
set(stairs(2),'LineWidth',2,'Color',[0.10 0.48 0.64]);
set(stairs(1),'LineWidth',2,'Color',[1 0.49 0.49]);
xlabel('Time to death (years)')
ylabel('Survival probability')
box off
xticks([0:2:max(nonzero)])
xlim([min(nonzero) max(nonzero)])
ylim([-0.05 1.05])
ax1.FontSize = 20;
exportgraphics(f,'km_timetodeath.png');

f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(gca,timeToevent(timeToevent>=0),'function','survivor','Bounds','off');
stairs = findall(ax1, 'Type', 'Stair');
set(stairs,'LineWidth',2,'Color',[1 0.37 0.49]);
xlabel('Time to death (years)')
ylabel('Survival probability')
box off
xticks([0:2:max(nonzero)])
xlim([min(nonzero) max(nonzero)])
ylim([-0.05 1.05])
ax1.FontSize = 20;
exportgraphics(f,'km_nogroups_timetodeath.png');


%% Survival rate (time to event) vs risk score
pol_degree = 1;
[nonzero_sorted,nonzero_sortid] = sort(nonzero);
risk_scores_death_sorted_nonzero = risk_scores_death_selected(timeToevent>=0);
risk_scores_death_sorted_nonzero_sorted = risk_scores_death_sorted_nonzero(nonzero_sortid);
% 
censored = ones(size(timeToevent,1),1);
bp_group2 = string;
bp_group2(labels_death == 0) = "Elevated";
bp_group2(labels_death == 1) = "Control";
bp_group2(labels_death == 2) = "Hypertension";
bp_group2 = bp_group2';
groups = char(bp_group2);
groups2 = cell.empty;
for i = 1:length(groups)
    groups2{i,1} = groups(i,:);
end
% f = figure('Position',[476,335,764,643])
[p, fh, stats] = MatSurv(timeToevent(timeToevent>=0), ...
                         censored(timeToevent>=0), ...
                         groups2(timeToevent>=0),...
                         'LineColor',[0.49 1 0.49;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49],...
                           'XLim',[0 30]);
exportgraphics(fh,'km_new.png');

nonzero_sorted_unique = unique(nonzero_sorted);
riskscores_edited = single.empty;
for p = 1:length(nonzero_sorted_unique)
    riskscores_edited(p,1) = mean(risk_scores_death_sorted_nonzero_sorted(nonzero_sorted == (nonzero_sorted_unique(p,1))));
end

x = nonzero_sorted;
y = risk_scores_death_sorted_nonzero_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);

f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(gca,timeToevent(timeToevent>=0),'function','survivor','Bounds','off');
stairs = findall(ax1, 'Type', 'Stair');
set(stairs,'LineWidth',2,'Color',[1 0.37 0.49]);
xlabel('Time to death (years)')
ylabel('Survival probability')
box off
xticks([0:2:max(nonzero)])
xlim([min(nonzero) max(nonzero)])
ylim([-0.05 1.05])
ax1.FontSize = 20;
hold on
yyaxis right
% scatter(x,y,50,[1 0.37 0.49],'filled')
plot(x,y1,':','LineWidth',3,'Color',[0.10 0.48 0.64])
ylim([min(y1) max(y1)])
ax = gca;
ax.YAxis(1).Color = [1 0.37 0.49];
ax.YAxis(2).Color = [0.10 0.48 0.64];
ylabel('Hyperscore')
legend('Survival','Hyperscore','Box','off','FontSize',15)
exportgraphics(f,'km_nogroups_timetodeath_riskscore.png');

%% Survival rate (time to event) vs risk score [Control elevated hypertensive]
pol_degree = 1;
Control = timeToevent(labels_death==1);
Control2 = Control(Control>=0);
Control_riskscores = risk_scores_death_selected(labels_death==1);
Control_riskscores2 = Control_riskscores(Control>=0);

[Control2_sorted,Control2_sortid] = sort(Control2);
Control_riskscores2_sorted = Control_riskscores2(Control2_sortid);

Control2_sorted_unique = unique(Control2_sorted);
Control_riskscores2_sorted_edited = single.empty;
for p = 1:length(Control2_sorted_unique)
    Control_riskscores2_sorted_edited(p,1) = median(Control_riskscores2_sorted(Control2_sorted == (Control2_sorted_unique(p,1))));
end

x = Control2_sorted;
y = Control_riskscores2_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);

f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(gca,Control2_sorted,'function','survivor','Bounds','off');
hold on
plot(x,normalize(y1,'range',[0 1]),':','LineWidth',3,'Color',[0.49 1 0.49])


Elevated = timeToevent(labels_death==0);
Elevated2 = Elevated(Elevated>=0);
Elevated_riskscores = risk_scores_death_selected(labels_death==0);
Elevated_riskscores2 = Elevated_riskscores(Elevated>=0);

[Elevated2_sorted,Elevated2_sortid] = sort(Elevated2);
Elevated_riskscores2_sorted = Elevated_riskscores2(Elevated2_sortid);

Elevated2_sorted_unique = unique(Elevated2_sorted);
Elevated_riskscores2_sorted_edited = single.empty;
for p = 1:length(Elevated2_sorted_unique)
    Elevated_riskscores2_sorted_edited(p,1) = median(Elevated_riskscores2_sorted(Elevated2_sorted == (Elevated2_sorted_unique(p,1))));
end

x = Elevated2_sorted;
y = Elevated_riskscores2_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);


ecdf(Elevated2_sorted,'function','survivor','Bounds','off');
plot(x,normalize(y1,'range',[0 1]),':','LineWidth',3,'Color',[0.10 0.48 0.64])


Hypertensive = timeToevent(labels_death==2);
Hypertensive2 = Hypertensive(Hypertensive>=0);
Hypertensive_riskscores = risk_scores_death_selected(labels_death==2);
Hypertensive_riskscores2 = Hypertensive_riskscores(Hypertensive>=0);

[Hypertensive2_sorted,Hypertensive2_sortid] = sort(Hypertensive2);
Hypertensive_riskscores2_sorted = Hypertensive_riskscores2(Hypertensive2_sortid);

Hypertensive2_sorted_unique = unique(Hypertensive2_sorted);
Hypertensive_riskscores2_sorted_edited = single.empty;
for p = 1:length(Hypertensive2_sorted_unique)
    Hypertensive_riskscores2_sorted_edited(p,1) = median(Hypertensive_riskscores2_sorted(Hypertensive2_sorted == (Hypertensive2_sorted_unique(p,1))));
end

x = Hypertensive2_sorted;
y = Hypertensive_riskscores2_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);

ecdf(Hypertensive2_sorted_unique,'function','survivor','Bounds','off');
plot(x,normalize(y1,'range',[0 1]),':','LineWidth',3,'Color',[1 0.49 0.49])

nonzero = timeToevent(timeToevent>=0);

legend('Control survival probability','Control normalized hyperscore',...
       'Elevated survival probability','Elevated normalized hyperscore',...
       'Hypertensive survival probability','Hypertensive normalized hyperscore','box','off','FontSize',12,...
       'Location','northeast')
% legend('Control',...
%        'Elevated',...
%        'Hypertensive','box','off','FontSize',15)
%    
stairs = findall(ax1, 'Type', 'Stair');
set(stairs(3),'LineWidth',2,'Color',[0.49 1 0.49]);
set(stairs(2),'LineWidth',2,'Color',[0.10 0.48 0.64]);
set(stairs(1),'LineWidth',2,'Color',[1 0.49 0.49]);
xlabel('Time to death (years)')
ylabel('Value')
box off
xticks([0:2:max(nonzero)])
xlim([min(nonzero) max(nonzero)])
ylim([-0.05 1.05])
ax1.FontSize = 20;
exportgraphics(f,'km_groups_timetodeath_riskscore.png');

%%
rng(2)
[idx,C,sumd,D] = kmeans(risk_scores_death_sorted_nonzero_sorted,3);
classes = cell.empty;
for k = 1:length(C)
    classes{k,1} = risk_scores_death_sorted_nonzero_sorted(idx == k);
end
range_1  = [min(classes{1,1}) max(classes{1,1})];
range_2  = [min(classes{2,1}) max(classes{2,1})];
range_3  = [min(classes{3,1}) max(classes{3,1})];

% idx1 = find(risk_scores_death_sorted_nonzero_sorted <= 0.2);
% idx2 = find((risk_scores_death_sorted_nonzero_sorted > 0.2) & (risk_scores_death_sorted_nonzero_sorted <0.4));
% idx3 = find((risk_scores_death_sorted_nonzero_sorted >= 0.4));
% 
% labels_death_clusters = zeros(size(risk_scores_death_sorted_nonzero_sorted,1));
% labels_death_clusters(idx1) = 1;
% labels_death_clusters(idx2) = 2;
% labels_death_clusters(idx3) = 3;
labels_death_clusters = idx;


censored = zeros(size(nonzero_sorted,1),1);
censored(death_ids(overall_death_ids)) = 1;
% 
bp_group2 = string;
bp_group2(labels_death_clusters == 1) = "0-0.25";
bp_group2(labels_death_clusters == 2) = "0.25-0.45";
bp_group2(labels_death_clusters == 3) = "0.45-0.65";
bp_group2 = bp_group2';
groups = char(bp_group2);
groups2 = cell.empty;
for i = 1:length(groups)
    groups2{i,1} = groups(i,:);
end

% f = figure('Position',[476,335,764,643])
[p, fh2, stats] = MatSurv(nonzero_sorted(nonzero_sorted>=0), ...
                         censored(nonzero_sorted>=0), ...
                         groups2(nonzero_sorted>=0),...
                         'LineColor',[0.49 1 0.49;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49],...
                           'XLim',[0 30]);
exportgraphics(fh2,'km_new2.png');






pol_degree = 1;

Control = nonzero_sorted(labels_death_clusters==1);
Control2 = Control;
Control_riskscores = risk_scores_death_sorted_nonzero_sorted(labels_death_clusters==1);
Control_riskscores2 = Control_riskscores;

[Control2_sorted,Control2_sortid] = sort(Control2);
Control_riskscores2_sorted = Control_riskscores2(Control2_sortid);

Control2_sorted_unique = unique(Control2_sorted);
Control_riskscores2_sorted_edited = single.empty;
for p = 1:length(Control2_sorted_unique)
    Control_riskscores2_sorted_edited(p,1) = median(Control_riskscores2_sorted(Control2_sorted == (Control2_sorted_unique(p,1))));
end

x = Control2_sorted;
y = Control_riskscores2_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);

f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(gca,Control2_sorted,'function','survivor','Bounds','off');
hold on
plot(x,normalize(y1,'range',[0 1]),':','LineWidth',3,'Color',[0.49 1 0.49])


Elevated = nonzero_sorted(labels_death_clusters==2);
Elevated2 = Elevated;
Elevated_riskscores = risk_scores_death_sorted_nonzero_sorted(labels_death_clusters==2);
Elevated_riskscores2 = Elevated_riskscores;

[Elevated2_sorted,Elevated2_sortid] = sort(Elevated2);
Elevated_riskscores2_sorted = Elevated_riskscores2(Elevated2_sortid);

Elevated2_sorted_unique = unique(Elevated2_sorted);
Elevated_riskscores2_sorted_edited = single.empty;
for p = 1:length(Elevated2_sorted_unique)
    Elevated_riskscores2_sorted_edited(p,1) = median(Elevated_riskscores2_sorted(Elevated2_sorted == (Elevated2_sorted_unique(p,1))));
end

x = Elevated2_sorted;
y = Elevated_riskscores2_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);


ecdf(Elevated2_sorted,'function','survivor','Bounds','off');
plot(x,normalize(y1,'range',[0 1]),':','LineWidth',3,'Color',[0.10 0.48 0.64])


Hypertensive = nonzero_sorted(labels_death_clusters==3);
Hypertensive2 = Hypertensive;
Hypertensive_riskscores = risk_scores_death_sorted_nonzero_sorted(labels_death_clusters==3);
Hypertensive_riskscores2 = Hypertensive_riskscores;

[Hypertensive2_sorted,Hypertensive2_sortid] = sort(Hypertensive2);
Hypertensive_riskscores2_sorted = Hypertensive_riskscores2(Hypertensive2_sortid);

Hypertensive2_sorted_unique = unique(Hypertensive2_sorted);
Hypertensive_riskscores2_sorted_edited = single.empty;
for p = 1:length(Hypertensive2_sorted_unique)
    Hypertensive_riskscores2_sorted_edited(p,1) = median(Hypertensive_riskscores2_sorted(Hypertensive2_sorted == (Hypertensive2_sorted_unique(p,1))));
end

x = Hypertensive2_sorted;
y = Hypertensive_riskscores2_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);

ecdf(Hypertensive2_sorted_unique,'function','survivor','Bounds','off');
plot(x,normalize(y1,'range',[0 1]),':','LineWidth',3,'Color',[1 0.49 0.49])


legend('0 - 0.25 survival probability','0 - 0.25 normalized hyperscore',...
       '0.25 - 0.45 survival probability','0.25 - 0.45 normalized hyperscore',...
       '0.45 - 0.5 survival probability','0.45 - 0.65 normalized hyperscore','box','off','FontSize',12,...
       'Location','northeast')
% legend('Control',...
%        'Elevated',...
%        'Hypertensive','box','off','FontSize',15)
%    
stairs = findall(ax1, 'Type', 'Stair');
set(stairs(3),'LineWidth',2,'Color',[0.49 1 0.49]);
set(stairs(2),'LineWidth',2,'Color',[0.10 0.48 0.64]);
set(stairs(1),'LineWidth',2,'Color',[1 0.49 0.49]);
xlabel('Time to death (years)')
ylabel('Value')
box off
xticks([0:2:max(nonzero)])
xlim([min(nonzero) max(nonzero)])
ylim([-0.05 1.05])
ax1.FontSize = 20;
exportgraphics(f,'km_groups_timetodeath_riskscore.png');



%% Kaplan Meier with all patients
age_of_cPCA_full = ukb_data_raw.X21003_2_0;
ukb_outcomes_ageatdeath_full = double(ukb_outcomes.X40007_0_0);

all_ids = [1:1:length(age_of_cPCA_full)]';
all_ids(death_ids(overall_death_ids)) = [];
age_of_cPCA_full(all_ids) = 50;
ukb_outcomes_ageatdeath_full(all_ids) = 100;

timeToevent_full = ukb_outcomes_ageatdeath_full - age_of_cPCA_full;
censored = zeros(size(timeToevent_full,1),1);
censored(death_ids(overall_death_ids)) = 1;
% 
bp_group2 = string;
bp_group2(bp_group == 0) = "Elevated";
bp_group2(bp_group == 1) = "Control";
bp_group2(bp_group == 2) = "Hypertension";
bp_group2 = bp_group2';
groups = char(bp_group2);
groups2 = cell.empty;
for i = 1:length(groups)
    groups2{i,1} = groups(i,:);
end

% f = figure('Position',[476,335,764,643])
[p, fh2, stats] = MatSurv(timeToevent_full(timeToevent_full>=0), ...
                         censored(timeToevent_full>=0), ...
                         groups2(timeToevent_full>=0),...
                         'LineColor',[0.49 1 0.49;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49],...
                           'XLim',[0 30],...
                           'YLim',[0.9960 1]);
exportgraphics(fh2,'km_new2.png');

censored = ones(size(timeToevent_full,1),1);
groups2 = cell.empty;
for i = 1:length(censored)
    groups2{i,1} = 'Death';
end
% f = figure('Position',[476,335,764,643])
[p, fh3, stats] = MatSurv(timeToevent_full(timeToevent_full>=0), ...
                         censored(timeToevent_full>=0), ...
                         groups2(timeToevent_full>=0),...
                         'LineColor',[1 0.37 0.49],...
                           'XLim',[0 30],...
                           'YLim',[0.9960 1]);
exportgraphics(fh3,'km_new3.png');




pol_degree = 1;
[nonzero_sorted,nonzero_sortid] = sort(nonzero);
risk_scores_death_sorted_nonzero = risk_scores_death_selected(timeToevent>=0);
risk_scores_death_sorted_nonzero_sorted = risk_scores_death_sorted_nonzero(nonzero_sortid);

nonzero_sorted_unique = unique(nonzero_sorted);
riskscores_edited = single.empty;
for p = 1:length(nonzero_sorted_unique)
    riskscores_edited(p,1) = mean(risk_scores_death_sorted_nonzero_sorted(nonzero_sorted == (nonzero_sorted_unique(p,1))));
end

x = nonzero_sorted;
y = risk_scores_death_sorted_nonzero_sorted;
p = polyfit(x,y,pol_degree);
y1 = polyval(p,x);


f = figure('Position',[403,399,735,437])
ax1 = gca;
ecdf(ax1,timeToevent_full(timeToevent_full>=0),'Censoring',censored(timeToevent_full>=0),'function','survivor','Bounds','off')
stairs = findall(ax1, 'Type', 'Stair');
set(stairs,'LineWidth',2,'Color',[1 0.37 0.49]);
xlabel('Time to death (years)')
ylabel('Survival probability')
box off
xticks([0:2:max(timeToevent_full(timeToevent_full>=0))])
xlim([min(timeToevent_full(timeToevent_full>=0)) max(timeToevent_full(timeToevent_full>=0))])
ylim([-0.05 1.05])
ax1.FontSize = 20;
hold on
yyaxis right
plot(x,y1,':','LineWidth',3,'Color',[0.10 0.48 0.64])
ylim([min(y1) max(y1)])
ax = gca;
ax.YAxis(1).Color = [1 0.37 0.49];
ax.YAxis(2).Color = [0.10 0.48 0.64];
ylabel('Hyperscore')
legend('Survival','Hyperscore','Box','off','FontSize',15)
exportgraphics(f,'km_nogroups_allpatients.png');


