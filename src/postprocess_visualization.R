library(ggplot2)

# # merge with UKB data
# #pseudotimes = merge(pseudotimes, df, all.x=TRUE, by = "Record.Id")
# pseudotimes = cbind(pseudotimes, model1.a.1$sub) # temp temp temp!
# 
# # plot per bp_group
# pdf("p1.pdf", width = 20, height = 10)
# ggplot(pseudotimes, aes(y=V1_pseudotimes,
#                         x=as.factor(bp_group),
#                         fill=as.factor(bp_group))) + 
#   geom_boxplot() + 
#   geom_point(aes(fill=as.factor(bp_group)),
#              position=position_jitterdodge()) + 
#   scale_fill_discrete(breaks=c("0","1","2"),
#                       labels=c("Other","Healthy","Disease")) + 
#   ggtitle("all subjects all variables: disease category and BP") + 
#   theme(legend.title = element_blank(),
#         axis.text.x = element_blank(),
#         axis.title.x=element_blank())
# dev.off()
