clc
clear all
close all

%% Survival analysis preparation
ukb_outcomes_path = [pwd,'/outcomes_analysis/ukb_num_norm_outcomes.csv'];
opts = detectImportOptions(ukb_outcomes_path);
opts = setvartype(opts, 'string');
ukb_outcomes = readtable(ukb_outcomes_path,opts);
outcomes_eid = ukb_outcomes.eid;

labels   = readtable('io/labels_select.csv'); % N patients with arbitrary number of columns
pat_ids = labels.df___ignore_cols_;
bp_group = labels.bp_group;
sex = labels.Sex;

[~,Locb] = ismember(string(pat_ids),outcomes_eid);
ukb_outcomes = ukb_outcomes(Locb,:);

pseudotimes_file  = readtable('io/pseudotimes.csv'); % N patients with arbitrary number of columns
global_pseudotimes = pseudotimes_file.global_pseudotimes;

%% Identifying death ids, circulatory death ids, events ids
%%%% Finding all-cause death ids
death_ids = find((string(ukb_outcomes.X40000_0_0) ~= "NA") == 1);

%%%% Finding circulatory diseases death ids
[circ_death_ids] = extract_circdeath(ukb_outcomes,death_ids);

%%%% Extracting patient information
ukb_outcomes_diedpatients = ukb_outcomes(death_ids,:);
ukb_outcomes_diedpatients_circ = ukb_outcomes(circ_death_ids,:);

%%%% Extracting patients with events
[htk_ids,stk_ids,ang_ids,...
 ukb_outcomes_agehtk,ukb_outcomes_agestk,ukb_outcomes_ageang,...   
 time_htk,time_stk,time_ang,...
 labels_heartattack,labels_stroke,labels_angina] = extract_events(ukb_outcomes,labels);
[events_ids,ia,ic] = unique([htk_ids;stk_ids;ang_ids]);
age_events = [ukb_outcomes_agehtk;ukb_outcomes_agestk;ukb_outcomes_ageang];
age_events = age_events(ia);
labels_events = [labels_heartattack;labels_stroke;labels_angina];
labels_events = labels_events(ia);
time_events = [time_htk;time_stk;time_ang];
time_events = time_events(ia);

%% Survival analysis (survival probability - cumulative hazard)
%%%% Circulatory deaths without events
events = 0;
selected_group = circ_death_ids;
tag = 'circ_deaths';
[stats_bp] = extract_survival_bp(ukb_outcomes,selected_group,bp_group,events,events_ids,age_events,tag);
[stats_hs] = extract_survival_hs(ukb_outcomes,selected_group,global_pseudotimes,events,events_ids,age_events,tag);
%%%% Circulatory deaths with events
events = 1;
selected_group = [circ_death_ids;events_ids];
tag = 'circ_deaths_events';
[stats_bp] = extract_survival_bp(ukb_outcomes,selected_group,bp_group,events,events_ids,age_events,tag);
[stats_hs] = extract_survival_hs(ukb_outcomes,selected_group,global_pseudotimes,events,events_ids,age_events,tag);
%%%% All-cause deaths
events = 0;
selected_group = death_ids;
tag = 'allcause_deaths';
[stats_bp] = extract_survival_bp(ukb_outcomes,selected_group,bp_group,events,events_ids,age_events,tag);
[stats_hs] = extract_survival_hs(ukb_outcomes,selected_group,global_pseudotimes,events,events_ids,age_events,tag);

%% Gender analysis
%%%% Circulatory deaths with events
events = 1;
selected_group = [circ_death_ids;events_ids];
tag = 'circ_deaths_events';
[stats_bp] = extract_survival_bp_sex(ukb_outcomes,sex,selected_group,bp_group,events,events_ids,age_events,tag);
[stats_hs] = extract_survival_hs_sex(ukb_outcomes,sex,selected_group,global_pseudotimes,events,events_ids,age_events,tag);
