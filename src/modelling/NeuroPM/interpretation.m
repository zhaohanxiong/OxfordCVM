
significant_variables = find(varweighting.significant == 'TRUE');
var_weights_signifiant = varweighting(significant_variables,:);
table_variable_names = string(ukb_data.Properties.VariableNames');
table_variable_names = strrep(table_variable_names,"x","X");
table_variable_names = strrep(table_variable_names,"_",".");

risk_scores = global_pseudotimes;
contribution = var_weights_signifiant.Node_contributions;
labels = bp_group;

%% Outcomes analysis
ukb_outcomes_path = [pwd,'/io/ukb_num_norm_outcomes.csv'];
opts = detectImportOptions(ukb_outcomes_path);
opts = setvartype(opts, 'string');
ukb_outcomes = readtable(ukb_outcomes_path,opts);
outcomes_eid = ukb_outcomes.eid;
[~,Locb] = ismember(string(pat_ids),outcomes_eid);
ukb_outcomes = ukb_outcomes(Locb,:);

ukb_data_raw_sig = double.empty;
ukb_data_sig = double.empty;
for variable_number = 1:10
variable_information = var_weights_signifiant(variable_number,:);

selected_variable = variable_information.Var1;
selected_definition = variable_information.name;
selected_group = variable_information.group;

variable_location = find(table_variable_names == selected_variable);
variable_original_values = table2array(ukb_data_raw(:,variable_location));
variable_normalised_values = table2array(ukb_data(:,variable_location));

ukb_data_raw_sig = [ukb_data_raw_sig,variable_original_values];
ukb_data_sig = [ukb_data_sig,variable_normalised_values];

end
variable_top10signifiant = var_weights_signifiant(1:10,:);

%%%% DEATH DATE
death_ids = find((string(ukb_outcomes.X40000_0_0) ~= "NA") == 1);
ukb_outcomes_death = ukb_outcomes.X40000_0_0(death_ids);

ukb_outcomes_causes_d = ukb_outcomes.X40010_0_0(death_ids);

%%%%%%% PRIMARY
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

%%%%%%% SECONDARY
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

%%%%%%% Combine primary and secondary
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
overall_death_ids = unique(overall_death_ids);

ukb_outcomes_patients = ukb_outcomes(death_ids,:);
ukb_outcomes_patients = ukb_outcomes_patients(overall_death_ids,:);
ukb_outcomes_ageatdeath = double(ukb_outcomes_patients.X40007_0_0);
% ukb_outcomes_ageatdeath2 = double(ukb_outcomes_patients.X40007_1_0);
% ukb_outcomes_ageatdeath = nansum([ukb_outcomes_ageatdeath1,ukb_outcomes_ageatdeath2],2);
age_of_cPCA = ukb_data_raw.X21003_2_0(death_ids);
age_of_cPCA = age_of_cPCA(overall_death_ids);

ukb_outcomes_death_selected = ukb_outcomes_death(overall_death_ids);
ukb_outcomes_death2 = datetime(ukb_outcomes_death_selected);
% ukb_outcomes_death2 = ukb_outcomes_death2.Year;
risk_scores_death = risk_scores(death_ids);
risk_scores_death_selected = risk_scores_death(overall_death_ids);
[ukb_outcomes_death2_sorted,sorting_id] = sort(ukb_outcomes_death2,'ascend');

ukb_outcomes_ageatdeath_sorted = ukb_outcomes_ageatdeath(sorting_id);
age_of_cPCA_sorted = age_of_cPCA(sorting_id);

risk_scores_death_sorted = risk_scores_death_selected(sorting_id);

selected_variable = ukb_data_raw_sig(:,1);
selected_variable_death = selected_variable(death_ids);
selected_variable_death = selected_variable_death(overall_death_ids);
selected_variable_sorted = selected_variable_death(sorting_id);

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


%%%% Age of heart attack
heartattack_ids = find((string(ukb_outcomes.X3894_2_0) ~= "NA") == 1);
ukb_outcomes_heartattack = ukb_outcomes.X3894_2_0(heartattack_ids);
ukb_outcomes_heartattack = double(string(ukb_outcomes_heartattack));

age_of_cPCA = ukb_data_raw.X21003_2_0(heartattack_ids);

risk_scores_heartattack = risk_scores(heartattack_ids);

time_until = ukb_outcomes_heartattack - age_of_cPCA;
[time_until_sorted,sorting_id] = sort(time_until,'ascend');
risk_scores_heartattack_sorted = risk_scores_heartattack(sorting_id);
age_of_cPCA_sorted = age_of_cPCA(sorting_id);
ukb_outcomes_heartattack_sorted = ukb_outcomes_heartattack(sorting_id);


figure;
scatter(time_until_sorted,risk_scores_heartattack_sorted)

%% Selecting variables 
for variable_number = 1:10
variable_information = var_weights_signifiant(variable_number,:);
variable_contribution = contribution(variable_number,:);

selected_variable = variable_information.Var1;
selected_definition = variable_information.name;
selected_group = variable_information.group;

variable_location = find(table_variable_names == selected_variable);
variable_original_values = table2array(ukb_data_raw(:,variable_location));
variable_normalised_values = table2array(ukb_data(:,variable_location));

[variable_normalised_values_sorted,sorting_id] = sort(variable_normalised_values,'ascend');
risk_scores_sorted = risk_scores(sorting_id);
[cubicCoef,stats,ctr] = polyfit(variable_normalised_values_sorted,risk_scores_sorted,3);
cubicFit = polyval(cubicCoef,variable_normalised_values_sorted,[],ctr);
labels_sorted = labels(sorting_id);

%%% Background vs diseased
background_labels = find(labels_sorted==1);
variable_normalised_values_sorted_background = variable_normalised_values_sorted(background_labels);
risk_scores_sorted_background = risk_scores_sorted(background_labels);
disease_labels = find(labels_sorted==2);
variable_normalised_values_sorted_disease = variable_normalised_values_sorted(disease_labels);
risk_scores_sorted_disease = risk_scores_sorted(disease_labels);


f = figure('Position',[680,447,531,531]);
% 680,659,351,319
labels_sorted_names = categorical(labels_sorted);
labels_sorted_names(labels_sorted_names == categorical(1)) = 'Backround';
labels_sorted_names(labels_sorted_names == categorical(2)) = 'Disease';

%Create x data histogram on top
clear g
g(1,1)=gramm('x',variable_normalised_values_sorted,'color',labels_sorted_names,'subset',labels_sorted==1 | labels_sorted==2);
g(1,1).set_layout_options('Position',[0.04 0.715 0.76 0.2],... %Set the position in the figure (as in standard 'Position' axe property)
    'legend',false,... % No need to display legend for side histograms
    'redraw',true); %We deactivate automatic redrawing/resizing so that the axes stay aligned according to the margin options
g(1,1).set_names('x','');
g(1,1).stat_bin('geom','stacked_bar','fill','all','nbins',50); %histogram
g(1,1).axe_property('Xlim',[min(variable_normalised_values_sorted) max(variable_normalised_values_sorted)],'visible','off'); % We deactivate tht ticks

g(2,1)=gramm('x',variable_normalised_values_sorted,'y',risk_scores_sorted,'color',labels_sorted_names,'subset',labels_sorted==1 | labels_sorted==2);
g(2,1).set_names('x','Variable value','y','Risk score','color','Category');
g(2,1).geom_point('alpha',0.2); %Scatter plot
g(2,1).stat_glm('distribution','normal','geom','solid_area');
g(2,1).stat_ellipse('type','95percentile','geom','line','patch_opts',{'FaceAlpha',0.1,'LineWidth',2,'LineStyle','--'});
% g(2,1).stat_summary('bin_in',10);
g(2,1).set_point_options('base_size',3);
g(2,1).set_layout_options('Position',[0 0 0.8 0.8],...
    'legend',false,... % No need to display legend for side histograms
    'legend_pos',[0.83 0.75 0.2 0.2],...
    'margin_height',[0.1 0.02],...
    'margin_width',[0.1 0.02],...
    'redraw',true);
g(2,1).axe_property('Xlim',[min(variable_normalised_values_sorted) max(variable_normalised_values_sorted)],'Ylim',[0 1],'Ygrid','off','Box','on');

%Create y data histogram on the right
g(3,1)=gramm('x',risk_scores_sorted,'color',labels_sorted_names,'subset',labels_sorted==1 | labels_sorted==2);
g(3,1).set_layout_options('Position',[0.70 0.045 0.2 0.76],...
    'legend',false,...
    'redraw',true);
g(3,1).set_names('x','');
g(3,1).stat_bin('geom','stacked_bar','fill','all','nbins',50); %histogram
g(3,1).coord_flip();
g(3,1).axe_property('Xlim',[0 1],'visible','off');

%Set global axe properties
g.axe_property('box','on','TickDir','in','XGrid','off','GridColor',[0.5 0.5 0.5],'FontSize',15);
g.set_color_options('map',[125/255   1 125/255;1   125/255   125/255; 0 0 0]);
g.draw();

exportgraphics(f,['var',num2str(variable_number),'.png']);

end

%% Tsne significant variables
variable_location = single.empty;
for i = 1:size(var_weights_signifiant,1)
variable_number = i;
variable_information = var_weights_signifiant(variable_number,:);
variable_contribution = contribution(variable_number,:);

selected_variable = variable_information.Var1;
selected_definition = variable_information.name;
selected_group = variable_information.group;

variable_location(i) = find(table_variable_names == selected_variable);
end
variable_original_values = table2array(ukb_data(:,variable_location));
variable_normalised_values = table2array(ukb_data(:,variable_location));

rng(8)
selected_labels = labels((labels==1) | (labels==2));
Y = tsne(variable_normalised_values((labels==1) | (labels==2),:));
f = figure('Position',[680,447,531,531]);
gscatter(Y(:,1),Y(:,2),selected_labels,[125/255   1 125/255;1   125/255   125/255])
xlabel('Dimension 1')
ylabel('Dimension 2')
ax = gca;
ax.FontSize = 15;

exportgraphics(f,'tsne_allsig.png');

%% Tsne significant variables per group
variable_location = single.empty;
selected_var_weights_signifiant = var_weights_signifiant(var_weights_signifiant.group == "Spirometry",:);
for i = 1:size(selected_var_weights_signifiant,1)
variable_number = i;
variable_information = selected_var_weights_signifiant(variable_number,:);
variable_contribution = contribution(variable_number,:);

selected_variable = variable_information.Var1;
selected_definition = variable_information.name;
selected_group = variable_information.group;

variable_location(i) = find(table_variable_names == selected_variable);
end
variable_original_values = table2array(ukb_data(:,variable_location));
variable_normalised_values = table2array(ukb_data(:,variable_location));

rng(8)
selected_labels = labels((labels==1) | (labels==2));
Y = tsne(variable_normalised_values((labels==1) | (labels==2),:));
f = figure('Position',[680,447,531,531]);
gscatter(Y(:,1),Y(:,2),selected_labels,[125/255   1 125/255;1   125/255   125/255])
xlabel('Dimension 1')
ylabel('Dimension 2')
ax = gca;
ax.FontSize = 15;

exportgraphics(f,'tsne_Spirometry.png');

%% Pie chart
X = var_weights_signifiant.Node_contributions;
labels_group = var_weights_signifiant.group;
groups = unique(var_weights_signifiant.group);
groups_percentages = double.empty;
for group_id = 1:length(groups)
    selected_group = groups(group_id,1);
    X_ids = find(labels_group == selected_group);
    selected_X = X(X_ids);
    groups_percentages(group_id,1) = sum(selected_X);
end
groups2 = groups;
groups2 = strrep(groups2,"_"," ");
groups2 = string(groups2);

groups_percentages = groups_percentages ./ (sum(groups_percentages));

% significant_total = sum(groups_percentages);
% non_significance = 1 - significant_total;
% groups2 = [groups2;"Non Sig"];
% groups_percentages = [groups_percentages;non_significance];

f = figure('Position',[251,305,1241,608]);

pie_plot = pie(groups_percentages,groups2);
groups_percentages2 = string(round(groups_percentages.*100,2));
groups_percentages = strcat(string(groups_percentages2),repmat("%",length(groups2),1));
groups_percentages = strcat(" - ",groups_percentages);
groups3 = strcat(groups2,groups_percentages);
L = legend(groups3,'Location','Eastoutside','FontSize',19,'Interpreter','none');
delete(findobj(pie_plot,'Type','text'))
pie_plot(2:2:end) = [];

exportgraphics(f,'pie_sig2.png');

%% Age sex analysis
data = readtable('C:\Users\Home\Desktop\Oxford_original\OxfordCVM\src\modelling\NeuroPM\io\ukb_num');
age = data.x21003_2_0;
sex = data.x31_0_0;

selected_labels = labels((labels==1) | (labels==2));
selected_age = age((labels==1) | (labels==2),:);
selected_sex = sex((labels==1) | (labels==2),:);
selected_sex = string(selected_sex);
selected_sex(selected_sex == "1") = "Male";
selected_sex(selected_sex == "0") = "Female";

risk_scores = risk_scores((labels==1) | (labels==2));
[selected_age_sorted,sorting_id] = sort(selected_age,'ascend');
risk_scores_sorted = risk_scores(sorting_id);
selected_labels_sorted = selected_labels(sorting_id);
selected_sex_sorted = selected_sex(sorting_id);

selected_age_sorted_categorical = string(selected_age_sorted);
selected_age_sorted_categorical((selected_age_sorted >= 40) & (selected_age_sorted <= 49)) = '40-49';
selected_age_sorted_categorical((selected_age_sorted >= 50) & (selected_age_sorted <= 59)) = '50-59';
selected_age_sorted_categorical((selected_age_sorted >= 60) & (selected_age_sorted <= 69)) = '60-69';
selected_age_sorted_categorical((selected_age_sorted >= 70) & (selected_age_sorted <= 79)) = '70-79';
selected_age_sorted_categorical((selected_age_sorted >= 80) & (selected_age_sorted <= 89)) = '80-89';
selected_age_sorted_categorical = categorical(selected_age_sorted_categorical);

f = figure('Position',[598,447,613,531]);
labels_sorted_names = categorical(selected_labels_sorted);
labels_sorted_names(labels_sorted_names == categorical(1)) = 'Backround';
labels_sorted_names(labels_sorted_names == categorical(2)) = 'Disease';
labels_sorted_names = removecats(labels_sorted_names,{'1','2'});
labels_sorted_names = reordercats(labels_sorted_names,{'Backround','Disease'});
g=gramm('x',selected_age_sorted_categorical,'y',risk_scores_sorted,'color',labels_sorted_names);
g.set_names('x','Age group','y','Risk score','color','Category');
g.set_layout_options('legend',false);
% g.geom_jitter('width',0.4,'height',0);
g.stat_boxplot();
g.set_point_options('base_size',3);
g.axe_property('box','on','TickDir','in','XGrid','off','GridColor',[0.5 0.5 0.5],'FontSize',15);
g.set_color_options('map',[125/255   1 125/255;1   125/255   125/255; 0 0 0]);
g.draw();

exportgraphics(f,'age.png');

f = figure('Position',[598,447,613,531]);
labels_sorted_names = categorical(selected_labels_sorted);
labels_sorted_names(labels_sorted_names == categorical(1)) = 'Backround';
labels_sorted_names(labels_sorted_names == categorical(2)) = 'Disease';
labels_sorted_names = removecats(labels_sorted_names,{'1','2'});
labels_sorted_names = reordercats(labels_sorted_names,{'Backround','Disease'});
g=gramm('x',categorical(selected_sex_sorted),'y',risk_scores_sorted,'color',labels_sorted_names);
g.set_names('x','Sex','y','Risk score','color','Category');
g.set_layout_options('legend',false);
% g.geom_jitter('width',0.4,'height',0);
g.stat_boxplot();
% g.stat_violin('fill','transparent');
g.set_point_options('base_size',3);
g.axe_property('box','on','TickDir','in','XGrid','off','GridColor',[0.5 0.5 0.5],'FontSize',15);
g.set_color_options('map',[125/255   1 125/255;1   125/255   125/255; 0 0 0]);
% g.coord_flip();
g.draw();

exportgraphics(f,'Sex.png');

%% pca components
selected_labels = labels((labels==1) | (labels==2));
selected_mapped_X = mappedX((labels==1) | (labels==2),:);

f = figure('Position',[680,447,531,531]);
gscatter(selected_mapped_X(:,1),selected_mapped_X(:,2),selected_labels,[125/255   1 125/255;1   125/255   125/255])
xlabel('Dimension 1')
ylabel('Dimension 2')
ax = gca;
ax.FontSize = 15;
xlim([-1 1])
ylim([-0.6 0.601])
exportgraphics(f,'cPCA.png');

%% Cluter mapping

variable_location = single.empty;
for i = 1:size(var_weights_signifiant,1)
variable_number = i;
variable_information = var_weights_signifiant(variable_number,:);
variable_contribution = contribution(variable_number,:);

selected_variable = variable_information.Var1;
selected_definition = variable_information.name;
selected_group = variable_information.group;

variable_location(i) = find(table_variable_names == selected_variable);
end
variable_original_values = table2array(ukb_data(:,variable_location));
variable_normalised_values = table2array(ukb_data(:,variable_location));

%%% sorting by group
[groups_sorted,sorting_id] = sort(var_weights_signifiant.group,'ascend');
groups_sorted2 = cell.empty;
for p = 1:length(groups_sorted)
    A = string(groups_sorted(p));
    A = strrep(A,"_"," ");
    groups_sorted2{p,1} = char(A);
end

var_weights_signifiant_sorted = var_weights_signifiant(sorting_id,:);
variable_normalised_values_sorted = variable_normalised_values(:,sorting_id);

%%%% BACKGROUND
background_subjects = variable_normalised_values_sorted(labels==1,:);
background_subjects2 = cov(background_subjects);

cgo = clustergram(background_subjects,...
                  'Standardize','none',...
                  'Symmetric',true,...
                  'ColorMap','redgreencmap',...
                  'ColumnLabels',groups_sorted2,...
                  'RowLabels',[],...
                  'DisplayRange',5,...
                  'Cluster','row',...
                  'ColumnPDist','correlation',...
                  'RowPDist','correlation',...
                  'Linkage','average',...
                  'Dendrogram',0.9,...
                  'DisplayRatio',0.15);

f = figure('Position',[192,46,1235,942]);
plot(cgo)
ax = gca;
ax.FontSize = 7;
exportgraphics(ax,'cluster_bg.png');








background_disease_subjects = variable_normalised_values((labels==1) | (labels==2),:);

selected_variables = var_weights_signifiant(1:10,:);

cgo = clustergram(background_disease_subjects(:,1:10),'Standardize','none','Cluster','row');
cgo.Dendrogram = 1;
cgo.ColumnPDist = 'Euclidean';
cgo.Linkage = 'average';
cgo.Symmetric = 1;
% cgo.ColumnLabels = [];
cgo.DisplayRange = 5;
cgo.Colormap = redgreencmap;




%%
ax = g(2,1).facet_axes_handles;


[cubicCoef,stats,ctr] = polyfit(variable_normalised_values_sorted_background,risk_scores_sorted_background,1);
cubicFit = polyval(cubicCoef,variable_normalised_values_sorted_background,[],ctr);
alpha = 0.05;
[yfit,delta] = polyconf(cubicCoef,variable_normalised_values_sorted_background,stats,'alpha',alpha);
plot(variable_normalised_values_sorted_background,yfit,'-g','LineWidth',1,'Parent',ax)
plot(variable_normalised_values_sorted_background,yfit-delta,'--g','LineWidth',0.5,'Parent',ax)
plot(variable_normalised_values_sorted_background,yfit+delta,'--g','LineWidth',0.5,'Parent',ax)

[cubicCoef,stats,ctr] = polyfit(variable_normalised_values_sorted_disease,risk_scores_sorted_disease,1);
cubicFit = polyval(cubicCoef,variable_normalised_values_sorted_disease,[],ctr);
alpha = 0.05;
[yfit,delta] = polyconf(cubicCoef,variable_normalised_values_sorted_disease,stats,'alpha',alpha);
plot(variable_normalised_values_sorted_disease,yfit,'-r','LineWidth',1,'Parent',ax)
plot(variable_normalised_values_sorted_disease,yfit-delta,'--r','LineWidth',0.5,'Parent',ax)
plot(variable_normalised_values_sorted_disease,yfit+delta,'--r','LineWidth',0.5,'Parent',ax)

%%% Values
scatter(variable_normalised_values_sorted_background,risk_scores_sorted_background,'g','.','SizeData',20)
scatter(variable_normalised_values_sorted_disease,risk_scores_sorted_disease,'r','.','SizeData',20)

%%% Fitting
[cubicCoef,stats,ctr] = polyfit(variable_normalised_values_sorted_background,risk_scores_sorted_background,3);
cubicFit = polyval(cubicCoef,variable_normalised_values_sorted_background,[],ctr);
alpha = 0.05;
[yfit,delta] = polyconf(cubicCoef,variable_normalised_values_sorted_background,stats,'alpha',alpha);
plot(variable_normalised_values_sorted_background,yfit,'-g','LineWidth',3)
plot(variable_normalised_values_sorted_background,yfit-delta,'--g','LineWidth',2)
plot(variable_normalised_values_sorted_background,yfit+delta,'--g','LineWidth',2)

[cubicCoef,stats,ctr] = polyfit(variable_normalised_values_sorted_disease,risk_scores_sorted_disease,3);
cubicFit = polyval(cubicCoef,variable_normalised_values_sorted_disease,[],ctr);
alpha = 0.05;
[yfit,delta] = polyconf(cubicCoef,variable_normalised_values_sorted_disease,stats,'alpha',alpha);
plot(variable_normalised_values_sorted_disease,yfit,'-r','LineWidth',3)
plot(variable_normalised_values_sorted_disease,yfit-delta,'--r','LineWidth',2)
plot(variable_normalised_values_sorted_disease,yfit+delta,'--r','LineWidth',2)

box on
grid on
xlabel([char(selected_definition),' - ',char(selected_group)],'Interpreter','none','FontWeight','bold')
ylabel('Risk scores','FontWeight','bold')
% title([char(selected_definition),' - ',char(selected_group)],'Interpreter','none')
xlim([min(variable_normalised_values_sorted) max(variable_normalised_values_sorted)]);
ax = gca;
ax.FontSize = 12;
legend('Control','Hypertensive','Cubic fitting','FontSize',10,'FontWeight','bold');