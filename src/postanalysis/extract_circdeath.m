function [circ_death_ids] = extract_circdeath(ukb_outcomes,death_ids)
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

% % % figure('Position',[488,424,694,420]);
% % % histogram(ukb_outcomes_causes2_forplot,'LineWidth',1.5)
% % % ax = gca;
% % % ax.FontSize = 15;
% % % xlabel('Cause of death');
% % % ylabel('Number of deaths');
% % % box off
% % % hold on
% % % bar(categorical("I"),length(death_ids_circulatory),'FaceColor',[1 0.37 0.41])
% % % exportgraphics(ax,'death_causes_primary_hist.png')

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

% % % figure('Position',[488,424,694,420]);
% % % histogram(ukb_outcomes_causes2_forplot,'LineWidth',1.5)
% % % ax = gca;
% % % ax.FontSize = 15;
% % % xlabel('Cause of death');
% % % ylabel('Number of deaths');
% % % box off
% % % hold on
% % % bar(categorical("I"),length(death_ids_circulatory),'FaceColor',[1 0.37 0.41])
% % % exportgraphics(ax,'death_causes_secondary_hist.png')

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

% % % figure('Position',[488,424,694,420]);
% % % histogram(ukb_outcomes_causes2_forplot,'LineWidth',1.5)
% % % ax = gca;
% % % ax.FontSize = 15;
% % % xlabel('Cause of death');
% % % ylabel('Number of deaths');
% % % box off
% % % hold on
% % % bar(categorical("I"),length(death_ids_circulatory),'FaceColor',[1 0.37 0.41])
% % % exportgraphics(ax,'death_causes_combined_hist.png')

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

circ_death_ids = death_ids(overall_death_ids);

end