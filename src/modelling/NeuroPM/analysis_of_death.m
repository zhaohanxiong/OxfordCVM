%% Analysis of death
%%%% Identifying outcomes based on patient id
ukb_outcomes_path = [pwd,'/outcomes_analysis/ukb_num_norm_outcomes.csv'];
opts = detectImportOptions(ukb_outcomes_path);
opts = setvartype(opts, 'string');
ukb_outcomes = readtable(ukb_outcomes_path,opts);
outcomes_eid = ukb_outcomes.eid;

labels   = readtable('io/labels_select.csv'); % N patients with arbitrary number of columns
pat_ids = labels.df___ignore_cols_;

[~,Locb] = ismember(string(pat_ids),outcomes_eid);
ukb_outcomes = ukb_outcomes(Locb,:);

cd([pwd,'/outcomes_analysis'])

%% DEATH IDS
%%%% FInding death ids
death_ids = find((string(ukb_outcomes.X40000_0_0) ~= "NA") == 1);
ukb_outcomes_death = ukb_outcomes.X40000_0_0(death_ids);

%%%% Primary death ids
ukb_outcomes_causes_p = ukb_outcomes.X40001_0_0(death_ids);
for p = 1:length(ukb_outcomes_causes_p)
    if isempty(ukb_outcomes_causes_p{p}) == 1
       ukb_outcomes_causes_p(p) = 'Z';
       continue
    end
    ukb_outcomes_causes_p(p) = ukb_outcomes_causes_p{p}(1);
end
ukb_outcomes_causes2 = categorical(ukb_outcomes_causes_p);

ukb_outcomes_causes2_forplot = ukb_outcomes_causes2;
ukb_outcomes_causes2_forplot(ukb_outcomes_causes2=="Z") = [];
ukb_outcomes_causes2_forplot = removecats(ukb_outcomes_causes2_forplot,"Z");
death_ids_circulatory = find(ukb_outcomes_causes2_forplot == "I");
figure('Position',[488,424,694,420]);
histogram(ukb_outcomes_causes2_forplot,'LineWidth',1.5)
ax = gca;
ax.FontSize = 15;
xlabel('Cause of death');
ylabel('Number of deaths');
box off
hold on
bar(categorical("I"),length(death_ids_circulatory),'FaceColor',[1 0.37 0.41])
exportgraphics(ax,'death_causes_primary_hist.png')

%%%% Secondary death ids
ukb_outcomes_causes_s = ukb_outcomes(death_ids,6:19);
ukb_outcomes_causes_s2 = string.empty;
for i = 1:size(ukb_outcomes_causes_s,2)
    ukb_outcomes_causes_s_selected = table2array(ukb_outcomes_causes_s(:,i));
for p = 1:length(ukb_outcomes_causes_s_selected)
    if isempty(ukb_outcomes_causes_s_selected{p}) == 1
       ukb_outcomes_causes_s_selected(p) = 'Z';
       continue
    end
    ukb_outcomes_causes_s_selected(p) = ukb_outcomes_causes_s_selected{p}(1);
end
    ukb_outcomes_causes_s2(:,i) = ukb_outcomes_causes_s_selected;
end

ukb_outcomes_causes_s_stacked = string.empty;
for i = 1:size(ukb_outcomes_causes_s2,1)
    vector = ukb_outcomes_causes_s2(i,:);
    ukb_outcomes_causes_s_stacked = [ukb_outcomes_causes_s_stacked;unique(vector)'];
end

ukb_outcomes_causes2 = categorical(ukb_outcomes_causes_s_stacked);

ukb_outcomes_causes2_forplot = ukb_outcomes_causes2;
ukb_outcomes_causes2_forplot(ukb_outcomes_causes2=="Z") = [];
ukb_outcomes_causes2_forplot = removecats(ukb_outcomes_causes2_forplot,"Z");
death_ids_circulatory = find(ukb_outcomes_causes2_forplot == "I");
figure('Position',[488,424,694,420]);
histogram(ukb_outcomes_causes2_forplot,'LineWidth',1.5)
ax = gca;
ax.FontSize = 15;
xlabel('Cause of death');
ylabel('Number of deaths');
box off
hold on
bar(categorical("I"),length(death_ids_circulatory),'FaceColor',[1 0.37 0.41])
exportgraphics(ax,'death_causes_secondary_hist.png')

%%%% Combine primary and secondary death ids
combined = string.empty;
for i = 1:size(ukb_outcomes_causes_s2,1)
    vector = ukb_outcomes_causes_s2(i,:);
    vector_p = ukb_outcomes_causes_p(i,:);
    combined = [combined;unique([vector,vector_p])'];
end
ukb_outcomes_causes2 = categorical(combined);
ukb_outcomes_causes2_forplot = ukb_outcomes_causes2;
ukb_outcomes_causes2_forplot(ukb_outcomes_causes2=="Z") = [];
ukb_outcomes_causes2_forplot = removecats(ukb_outcomes_causes2_forplot,"Z");
death_ids_circulatory = find(ukb_outcomes_causes2_forplot == "I");
figure('Position',[488,424,694,420]);
histogram(ukb_outcomes_causes2_forplot,'LineWidth',1.5)
ax = gca;
ax.FontSize = 15;
xlabel('Cause of death');
ylabel('Number of deaths');
box off
hold on
bar(categorical("I"),length(death_ids_circulatory),'FaceColor',[1 0.37 0.41])
exportgraphics(ax,'death_causes_combined_hist.png')

primary_death_ids = find(ukb_outcomes_causes_p == "I");
count = 1;
secondary_death_ids = single.empty;
for s = 1:size(ukb_outcomes_causes_s2,1)
    secondary_vector = ukb_outcomes_causes_s2(s,:);
    check = find(secondary_vector == "I");
    if isempty(check) == 0
       secondary_death_ids(count,1) = s;
       count = count + 1;
    end
end
overall_death_ids = [primary_death_ids;secondary_death_ids];

%%%% Death ids with circulatory diseases
overall_death_ids = unique(overall_death_ids);

%% Age of death
ukb_outcomes_patients = ukb_outcomes(death_ids,:);

%%%% Patients who died with circulatory diseases
ukb_outcomes_patients = ukb_outcomes_patients(overall_death_ids,:);

ukb_outcomes_ageatdeath = double(ukb_outcomes_patients.X40007_0_0);
age_of_cPCA = ukb_data_raw.X21003_2_0(death_ids);
age_of_cPCA = age_of_cPCA(overall_death_ids);

ukb_outcomes_death_selected = ukb_outcomes_death(overall_death_ids);
ukb_outcomes_death2 = datetime(ukb_outcomes_death_selected);

risk_scores = global_pseudotimes;
risk_scores_death = risk_scores(death_ids);
risk_scores_death_selected = risk_scores_death(overall_death_ids);
[ukb_outcomes_death2_sorted,sorting_id] = sort(ukb_outcomes_death2,'ascend');

ukb_outcomes_ageatdeath_sorted = ukb_outcomes_ageatdeath(sorting_id);
age_of_cPCA_sorted = age_of_cPCA(sorting_id);

risk_scores_death_sorted = risk_scores_death_selected(sorting_id);

labels_death = labels.bp_group(death_ids);
labels_death = labels_death(overall_death_ids);
labels_death_sorted = labels_death(sorting_id);

f = figure('Position',[425,417,865,441]);
labels_sorted_names = categorical(labels_death_sorted);
labels_sorted_names(labels_sorted_names == categorical(0)) = 'Elevated';
labels_sorted_names(labels_sorted_names == categorical(1)) = 'Control';
labels_sorted_names(labels_sorted_names == categorical(2)) = 'Hypertensive';
labels_sorted_names = removecats(labels_sorted_names,{'0','1','2'});
labels_sorted_names = reordercats(labels_sorted_names,{'Elevated','Control','Hypertensive'});
g=gramm('x',ukb_outcomes_death2_sorted.Year,'y',risk_scores_death_sorted,'color',labels_sorted_names);
g.set_names('x','Year of death','y','Hyperscore','color','Category');
g.set_layout_options('legend',true);
%g.geom_jitter('width',1,'height',0);
g.stat_boxplot();
g.set_point_options('base_size',3);
g.axe_property('box','off','TickDir','in','XGrid','off','YGrid','off','GridColor',[0.5 0.5 0.5],'FontSize',15);
g.set_color_options('map',[0.49 1 0.49;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49]);
g.draw();
exportgraphics(f,'death.png')

f = figure('Position',[425,417,865,441]);
g=gramm('x',ukb_outcomes_death2_sorted.Year,'y',risk_scores_death_sorted);
g.set_names('x','Year of death','y','Hyperscore','color','Category');
g.set_layout_options('legend',true);
%g.geom_jitter('width',1,'height',0);
g.stat_boxplot();
g.set_point_options('base_size',3);
g.axe_property('box','off','TickDir','in','XGrid','off','YGrid','off','GridColor',[0.5 0.5 0.5],'FontSize',15);
g.draw();
exportgraphics(f,'death_nogroups.png')

figure('Position',[680,558,404,420]);
histogram(ukb_outcomes_death2_sorted.Year,'LineWidth',1.5,'FaceColor',[1 0.37 0.41])
ax = gca;
ax.FontSize = 15;
ax.XTickLabelRotation = 90;
ax.XTick = [2014:1:2021];
xlabel('Year of death');
ylabel('Number of deaths');
box off
exportgraphics(ax,'death_nogroups_hist.png')

%% Survival analysis [By year]

%%%% Analysis by year
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

%% Survival analysis [Time to death]
timeToevent = ukb_outcomes_ageatdeath - age_of_cPCA;

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

%%%% Three categories 
Elevated = timeToevent(labels_death==0);
Control = timeToevent(labels_death==1);
Hypertensive = timeToevent(labels_death==2);
 
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

%%%% Analysis in presence of all patients
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

%% Analysis with k-means categories
[nonzero_sorted,nonzero_sortid] = sort(nonzero);
risk_scores_death_sorted_nonzero = risk_scores_death_selected(timeToevent>=0);
risk_scores_death_sorted_nonzero_sorted = risk_scores_death_sorted_nonzero(nonzero_sortid);

rng(2)
[idx,C,sumd,D] = kmeans(risk_scores_death_sorted_nonzero_sorted,3);
classes = cell.empty;
for k = 1:length(C)
    classes{k,1} = risk_scores_death_sorted_nonzero_sorted(idx == k);
end
range_1  = [min(classes{1,1}) max(classes{1,1})];
range_2  = [min(classes{2,1}) max(classes{2,1})];
range_3  = [min(classes{3,1}) max(classes{3,1})];

labels_death_clusters = idx;

censored = ones(size(nonzero_sorted,1),1);

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
[p, fh2, stats] = MatSurv(nonzero_sorted, ...
                         censored, ...
                         groups2,...
                         'LineColor',[0.49 1 0.49;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49],...
                           'XLim',[0 30]);
exportgraphics(fh2,'km_new_kmeans.png');

%%%% Including all patients
age_of_cPCA_full = ukb_data_raw.X21003_2_0;
ukb_outcomes_ageatdeath_full = double(ukb_outcomes.X40007_0_0);

all_ids = [1:1:length(age_of_cPCA_full)]';
all_ids(death_ids(overall_death_ids)) = [];
age_of_cPCA_full(all_ids) = 50;
ukb_outcomes_ageatdeath_full(all_ids) = 100;

timeToevent_full = ukb_outcomes_ageatdeath_full - age_of_cPCA_full;
censored = zeros(size(timeToevent_full,1),1);
censored(death_ids(overall_death_ids)) = 1;

non_zero_id = find((timeToevent_full >= 0) & (timeToevent_full < 50));

risk_scores = global_pseudotimes;

idx1 = find(risk_scores <= 0.25);
idx2 = find((risk_scores > 0.2) & (risk_scores <0.45));
idx3 = find((risk_scores >= 0.45));

labels_death_clusters = zeros(size(risk_scores,1),1);
labels_death_clusters(idx1) = 1;
labels_death_clusters(idx2) = 2;
labels_death_clusters(idx3) = 3;

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
[p, fh2, stats] = MatSurv(timeToevent_full(timeToevent_full>=0), ...
                         censored(timeToevent_full>=0), ...
                         groups2(timeToevent_full>=0),...
                         'LineColor',[0.49 1 0.49;...
                           0.10 0.48 0.64;...
                           1 0.49 0.49;...
                           0 0 0],...
                           'XLim',[0 30],...
                           'YLim',[0.9960 1]);
exportgraphics(fh2,'km_new_kmeans2.png');

%% Risk score of deaths
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

mdl = fitlm(x,y);
p_value = table2array(mdl.Coefficients(2,4));
R_sqaured = mdl.Rsquared.Ordinary;

f = figure('Position',[403,399,735,437])
hold on
scatter(1000,1000,50,[0 0 0],'filled')
scatter(1000,1000,50,[0 0 0],'filled')
scatter(x,y,50,[1 0.37 0.49],'filled')
plot(x,y1,':','LineWidth',3,'Color',[0.10 0.48 0.64])
xlabel('Time to death (years)')
ylabel('Hyperscore')
box off
ax = gca;
ax.FontSize = 20;
xlim([0 30])
ylim([0 max(y)])
legend(['R^{2}: ' ,num2str(round(R_sqaured,3))],['p-value: ' ,num2str(round(p_value,3))],...
        'Box','off','Interpreter', 'tex','Position',[0.622222228142139,0.761632351614123,0.268027204964437,0.168192214974004]);
exportgraphics(f,'hyoerscore_death.png');

%% Risk score of deaths (Groups)
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

mdl = fitlm(x,y);
p_value1 = table2array(mdl.Coefficients(2,4));
R_sqaured1 = mdl.Rsquared.Ordinary;


f = figure('Position',[403,399,735,437])
hold on
plot(x,y1,':','LineWidth',3,'Color',[0.49 1 0.49])

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

mdl = fitlm(x,y);
p_value2 = table2array(mdl.Coefficients(2,4));
R_sqaured2 = mdl.Rsquared.Ordinary;

plot(x,y1,':','LineWidth',3,'Color',[0.10 0.48 0.64])

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

mdl = fitlm(x,y);
p_value3 = table2array(mdl.Coefficients(2,4));
R_sqaured3 = mdl.Rsquared.Ordinary;

plot(x,y1,':','LineWidth',3,'Color',[1 0.49 0.49])
% 
% legend(['R^{2}: ' ,num2str(round(R_sqaured1,3)),' - p-value: ' ,num2str(round(p_value1,3))],...
%        ['R^{2}: ' ,num2str(round(R_sqaured2,3)),' - p-value: ' ,num2str(round(p_value2,3))],...
%        ['R^{2}: ' ,num2str(round(R_sqaured3,3)),' - p-value: ' ,num2str(round(p_value3,3))],...
%         'Box','off','Interpreter', 'tex','Position',[0.622222228142139,0.761632351614123,0.268027204964437,0.168192214974004]);

xlabel('Time to death (years)')
ylabel('Hyperscore')
box off
ax = gca;
ax.FontSize = 20;
xlim([0 30])

exportgraphics(f,'hyoerscore_death_groups.png');

%%  Risk score of deaths (k-means Groups)
[nonzero_sorted,nonzero_sortid] = sort(nonzero);
risk_scores_death_sorted_nonzero = risk_scores_death_selected(timeToevent>=0);
risk_scores_death_sorted_nonzero_sorted = risk_scores_death_sorted_nonzero(nonzero_sortid);

rng(2)
[idx,C,sumd,D] = kmeans(risk_scores_death_sorted_nonzero_sorted,3);
classes = cell.empty;
for k = 1:length(C)
    classes{k,1} = risk_scores_death_sorted_nonzero_sorted(idx == k);
end
range_1  = [min(classes{1,1}) max(classes{1,1})];
range_2  = [min(classes{2,1}) max(classes{2,1})];
range_3  = [min(classes{3,1}) max(classes{3,1})];

labels_death_clusters = idx;

pol_degree = 1;
Control = nonzero_sorted(labels_death_clusters==1);
Control2 = Control(Control>=0);
Control_riskscores = risk_scores_death_sorted_nonzero_sorted(labels_death_clusters==1);
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

mdl = fitlm(x,y);
p_value1 = table2array(mdl.Coefficients(2,4));
R_sqaured1 = mdl.Rsquared.Ordinary;


f = figure('Position',[403,399,735,437])
hold on
plot(x,y1,':','LineWidth',3,'Color',[0.49 1 0.49])

Elevated = nonzero_sorted(labels_death_clusters==2);
Elevated2 = Elevated(Elevated>=0);
Elevated_riskscores = risk_scores_death_sorted_nonzero_sorted(labels_death_clusters==2);
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

mdl = fitlm(x,y);
p_value2 = table2array(mdl.Coefficients(2,4));
R_sqaured2 = mdl.Rsquared.Ordinary;

plot(x,y1,':','LineWidth',3,'Color',[0.10 0.48 0.64])

Hypertensive = nonzero_sorted(labels_death_clusters==3);
Hypertensive2 = Hypertensive(Hypertensive>=0);
Hypertensive_riskscores = risk_scores_death_sorted_nonzero_sorted(labels_death_clusters==3);
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

mdl = fitlm(x,y);
p_value3 = table2array(mdl.Coefficients(2,4));
R_sqaured3 = mdl.Rsquared.Ordinary;

plot(x,y1,':','LineWidth',3,'Color',[1 0.49 0.49])
% 
% legend(['R^{2}: ' ,num2str(round(R_sqaured1,3)),' - p-value: ' ,num2str(round(p_value1,3))],...
%        ['R^{2}: ' ,num2str(round(R_sqaured2,3)),' - p-value: ' ,num2str(round(p_value2,3))],...
%        ['R^{2}: ' ,num2str(round(R_sqaured3,3)),' - p-value: ' ,num2str(round(p_value3,3))],...
%         'Box','off','Interpreter', 'tex','Position',[0.622222228142139,0.761632351614123,0.268027204964437,0.168192214974004]);

xlabel('Time to death (years)')
ylabel('Hyperscore')
box off
ax = gca;
ax.FontSize = 20;
xlim([0 30])

exportgraphics(f,'hyoerscore_death_groups_kmeans.png');


