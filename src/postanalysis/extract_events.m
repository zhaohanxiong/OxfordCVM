function [htk_ids,stk_ids,ang_ids,...
          ukb_outcomes_agehtk,ukb_outcomes_agestk,ukb_outcomes_ageang,...
          time_htk,time_stk,time_ang,...
          labels_heartattack,labels_stroke,labels_angina] = extract_events(ukb_outcomes,labels)
%%%% Heart attack IDS
%%%% FInding Heart attack ids
htk_ids = find((string(ukb_outcomes.X3894_3_0) ~= "NA") == 1);
ukb_outcomes_agehtk = double(ukb_outcomes.X3894_3_0(htk_ids));

%%%%% Age
ukb_outcomes_patients2 = ukb_outcomes(htk_ids,:);
ukb_outcomes_yob2 = double(ukb_outcomes_patients2.X34_0_0);
ukb_outcomes_mob2 = double(ukb_outcomes_patients2.X52_0_0);
ukb_outcomes_daob2 = double(ones(length(ukb_outcomes_mob2),1));
ukb_outcomes_dob2 = datetime(ukb_outcomes_yob2, ukb_outcomes_mob2, ukb_outcomes_daob2);

ukb_outcomes_doa2 = ukb_outcomes_patients2.X53_2_0;
ukb_outcomes_doa2 = datetime(ukb_outcomes_doa2,'InputFormat','yyyy-MM-dd');
ukb_outcomes_ageatcPCA2 = ukb_outcomes_doa2 - ukb_outcomes_dob2;
ukb_outcomes_ageatcPCA22 = hours(ukb_outcomes_ageatcPCA2);
ukb_outcomes_ageatcPCA2 = ukb_outcomes_ageatcPCA22 ./ (24*365);

time_htk = ukb_outcomes_agehtk - ukb_outcomes_ageatcPCA2;

labels_heartattack = labels.bp_group(htk_ids);
labels_heartattack(time_htk <= 0) = [];

htk_ids(time_htk <= 0) = [];

ukb_outcomes_agehtk(time_htk <= 0) = [];

time_htk(time_htk <= 0) = [];

%%%% Stroke IDS
%%%% FInding Stroke ids
stk_ids = find((string(ukb_outcomes.X4056_3_0) ~= "NA") == 1);
ukb_outcomes_agestk = double(ukb_outcomes.X4056_3_0(stk_ids));

%%%%% Age
ukb_outcomes_patients2 = ukb_outcomes(stk_ids,:);
ukb_outcomes_yob2 = double(ukb_outcomes_patients2.X34_0_0);
ukb_outcomes_mob2 = double(ukb_outcomes_patients2.X52_0_0);
ukb_outcomes_daob2 = double(ones(length(ukb_outcomes_mob2),1));
ukb_outcomes_dob2 = datetime(ukb_outcomes_yob2, ukb_outcomes_mob2, ukb_outcomes_daob2);

ukb_outcomes_doa2 = ukb_outcomes_patients2.X53_2_0;
ukb_outcomes_doa2 = datetime(ukb_outcomes_doa2,'InputFormat','yyyy-MM-dd');
ukb_outcomes_ageatcPCA2 = ukb_outcomes_doa2 - ukb_outcomes_dob2;
ukb_outcomes_ageatcPCA22 = hours(ukb_outcomes_ageatcPCA2);
ukb_outcomes_ageatcPCA2 = ukb_outcomes_ageatcPCA22 ./ (24*365);

time_stk = ukb_outcomes_agestk - ukb_outcomes_ageatcPCA2;

labels_stroke = labels.bp_group(stk_ids);
labels_stroke(time_stk <= 0) = [];

stk_ids(time_stk <= 0) = [];

ukb_outcomes_agestk(time_stk <= 0) = [];

time_stk(time_stk <= 0) = [];

%%%% Angina IDS
%%%% FInding Angina ids
ang_ids = find((string(ukb_outcomes.X3627_3_0) ~= "NA") == 1);
ukb_outcomes_ageang = double(ukb_outcomes.X3627_3_0(ang_ids));

%%%%% Age
ukb_outcomes_patients2 = ukb_outcomes(ang_ids,:);
ukb_outcomes_yob2 = double(ukb_outcomes_patients2.X34_0_0);
ukb_outcomes_mob2 = double(ukb_outcomes_patients2.X52_0_0);
ukb_outcomes_daob2 = double(ones(length(ukb_outcomes_mob2),1));
ukb_outcomes_dob2 = datetime(ukb_outcomes_yob2, ukb_outcomes_mob2, ukb_outcomes_daob2);

ukb_outcomes_doa2 = ukb_outcomes_patients2.X53_2_0;
ukb_outcomes_doa2 = datetime(ukb_outcomes_doa2,'InputFormat','yyyy-MM-dd');
ukb_outcomes_ageatcPCA2 = ukb_outcomes_doa2 - ukb_outcomes_dob2;
ukb_outcomes_ageatcPCA22 = hours(ukb_outcomes_ageatcPCA2);
ukb_outcomes_ageatcPCA2 = ukb_outcomes_ageatcPCA22 ./ (24*365);

time_ang = ukb_outcomes_ageang - ukb_outcomes_ageatcPCA2;

labels_angina = labels.bp_group(ang_ids);
labels_angina(time_ang <= 0) = [];

ang_ids(time_ang <= 0) = [];

ukb_outcomes_ageang(time_ang <= 0) = [];

time_ang(time_ang <= 0) = [];

end