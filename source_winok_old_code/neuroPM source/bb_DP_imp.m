


model=["1.a.2","1.b.2","4.b.2"]

for i = 1:length(model)
    
    j=string(model(i));
    dir=strcat('/Users/winok/Documents/Projects/UKBiobank/BB_DP_imp/model',j,'/')

    [pseudotimes_file, FigList, node_contributions, expected_contribution]=bb_DP_run_imp(dir);
    writetable(pseudotimes_file,strcat(dir,'global_pseudotimes.csv'));
    writetable(node_contributions,strcat(dir,'var_weighting.csv'));
    writetable(expected_contribution,strcat(dir,'thr_weighting.csv'));
    savefig(FigList,strcat(dir,'fig_global_pseudotimes'));
    close(findobj(allchild(0), 'flat', 'Type', 'figure'))

end
 

%%% cov

model=["1.a.2","1.b.2","4.b.2"]

for i = 1:length(model)

    j=string(model(i));
    dir=strcat('/Users/winok/Documents/Projects/UKBiobank/BB_DP_imp/model',j,'/cov/')
    
    [pseudotimes_file, FigList, node_contributions, expected_contribution]=bb_DP_run_imp(dir);
    writetable(pseudotimes_file,strcat(dir,'global_pseudotimes.csv'));
    writetable(node_contributions,strcat(dir,'var_weighting.csv'));
    writetable(expected_contribution,strcat(dir,'thr_weighting.csv'));
    savefig(FigList,strcat(dir,'fig_global_pseudotimes'));
    close(findobj(allchild(0), 'flat', 'Type', 'figure'))

 end