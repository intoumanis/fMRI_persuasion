
library(rstatix)
library(ggplot2)
library(ggpubr)
library(openxlsx)
library(dplyr)
library(RColorBrewer)
library(wesanderson)
library(lme4)
library(nparLD)
library(lmerTest)
library(jtools)

Sys.setlocale(,'greek')

# Load the data

data = read.xlsx('Dataset.xlsx')
str(data)
data$condition=factor(data$condition, levels = c('sugar-containing','non-edible','sugar-free'))
data$Block=factor(data$Block)
data$ProductID = factor(data$ProductID)
data$SubjectID = factor(data$SubjectID)
str(data)
summary(data)

### Descriptive statistics
length(which(is.na(data$RT)))*100/nrow(data)
mean(data$bid)
sd(data$bid)
length(which(data$bid>0))*100/nrow(data)
data %>% wilcox_test(bid ~ 1, mu = 0)
mean(data$RT, na.rm=T)
sd(data$RT, na.rm=T)


# Aggregate the data within subject, block and condition and calculate the deltas
df = aggregate(data$bid, list(data$SubjectID, data$Block, data$condition), FUN = mean)
colnames(df)=c('id','block','condition','bid')
str(df)

test_df = df
test_df$bid[which(test_df$block=='1')] = - test_df$bid[which(test_df$block=='1')]
delta_df = aggregate(test_df$bid, list(test_df$id, test_df$condition), FUN = sum)
colnames(delta_df)=c('id','condition','bid')
str(delta_df)

### Compare the conditions in terms of the delta of WTP
delta_df %>%
  group_by(condition) %>%
  identify_outliers(bid)

delta_df %>%
  group_by(condition) %>%
  shapiro_test(bid)

ggqqplot(delta_df, 'bid', facet.by = 'condition')

res.aov = delta_df %>% anova_test(dv = bid, wid = id, within = condition)
get_anova_table(res.aov)

pwc = delta_df %>%
  pairwise_t_test(
    bid ~ condition, paired = T,
    p.adjust.method = "BH", digits=3
  )
pwc

delta_df %>%
  cohens_d(
    bid ~ condition, paired = T
  )

pwc <- pwc %>% add_xy_position(x = "condition")


g1 = ggboxplot(
  delta_df, x = "condition", y = "bid",
  fill='condition', add='jitter', add.params = list(size=0.5)
)+
  scale_y_continuous(limits = c(-30,40), breaks = seq(-30,40,10))+
  scale_fill_manual(values=c('royalblue','darkmagenta','forestgreen'))+
  scale_color_manual(values=c('royalblue','darkmagenta','forestgreen'))+
  ylab('?? WTP')+
  xlab('')+
  geom_hline(yintercept = 0, lty=2) +
  stat_pvalue_manual(pwc, hide.ns = T, tip.length = 0, size=8, bracket.size = 0.7) +
  stat_summary(fun=mean, geom="point", shape=15, size=3, color="black") +
  theme(
    text=element_text(size=16),
    axis.text.y = element_text(size=12),
    legend.position = 'none'
  )

g1


# Corrected dWTP
str(delta_df)
combine_df = data.frame('delta_sugar_containing' = delta_df$bid[delta_df$condition=='sugar-containing'] - delta_df$bid[delta_df$condition=='non-edible'],
                        'delta_sugar_free' = delta_df$bid[delta_df$condition=='sugar-free'] - delta_df$bid[delta_df$condition=='non-edible'])
str(combine_df)

Nsubs = 50
corrected_df = data.frame('corrected_dWTP' = c(combine_df$delta_sugar_containing, combine_df$delta_sugar_free),
                          'condition' = c(rep('sugar-containing', Nsubs), rep('sugar-free', Nsubs)),
                          'id' = 1:Nsubs)

traits = aggregate(list(data$age, data$BMI, data$conformity, data$susceptibility, data$extraversion, data$agreeableness, data$openness, data$conscientiousness, data$neurotisicm),
                   list(data$SubjectID),
                   FUN='mean')
colnames(traits) = c('id','age','bmi','conformity','susceptibility','extraversion','agreeableness','openness','conscientiousness','neurotisicm')

corrected_df = cbind(corrected_df, traits[,2:10])

# sugar-free
cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$age, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$bmi, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$conformity, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$susceptibility, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$extraversion, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$agreeableness, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$openness, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$conscientiousness, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-free')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-free')$neurotisicm, method='spearman')


# sugar-containing
cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$age, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$bmi, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$conformity, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$susceptibility, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$extraversion, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$agreeableness, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$openness, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$conscientiousness, method='spearman')

cor.test(subset(corrected_df, condition=='sugar-containing')$corrected_dWTP,
         subset(corrected_df, condition=='sugar-containing')$neurotisicm, method='spearman')


corrected_ps = p.adjust(c(0.855,0.0052,0.698,0.588,0.805,0.511,0.047,0.227,0.083,0.889,0.514,0.743,0.959,0.889,0.301,0.742,0.5,0.946), method='BH')
corrected_ps

# Do also categorical
sex = factor(data$sex[seq(1,nrow(data),180)])
education = factor(data$education[seq(1,nrow(data),180)])

corrected_df = cbind(corrected_df, sex, education)

corrected_df %>%
  group_by(condition) %>%
  t_test(corrected_dWTP ~ sex)

corrected_df %>%
  group_by(condition) %>%
  anova_test(corrected_dWTP ~ education)



# Save deltas for ISC contrast
deltas = data.frame('sugar_containing' = delta_df$bid[delta_df$condition=='sugar-containing'] - delta_df$bid[delta_df$condition=='non-edible'],
                  'sugar_free' = delta_df$bid[delta_df$condition=='sugar-free'] - delta_df$bid[delta_df$condition=='non-edible'],
                  # 'non_edible' = delta_df$bid[delta_df$condition=='non-edible'],
                  'combined_score' =  delta_df$bid[delta_df$condition=='sugar-free'] - delta_df$bid[delta_df$condition=='sugar-containing'])
#write.csv(deltas, 'results/deltas.csv', row.names = F)


### Product characteristics
test_data = data
test_data$bid[which(test_data$Block=='1')] = - test_data$bid[which(test_data$Block=='1')]
delta_data = aggregate(cbind(test_data$bid, test_data$sweetness, test_data$familiarity, test_data$tastiness),
                       list(test_data$SubjectID, test_data$ProductID, test_data$condition), FUN = sum)
colnames(delta_data)=c('SubjectID','ProductID','condition','delta_WTP','sweetness','familiarity','tastiness')
delta_data$sweetness = delta_data$sweetness/2
delta_data$familiarity = delta_data$familiarity/2
delta_data$tastiness = delta_data$tastiness/2
delta_data$condition = factor(delta_data$condition, levels = c('non-edible','sugar-containing','sugar-free'))
str(delta_data)

model1 = lmer(delta_WTP ~ tastiness + familiarity + sweetness +(1|SubjectID), data = subset(delta_data, condition=='sugar-containing'))
summ(model1)

model2 = lmer(delta_WTP ~ tastiness + familiarity + sweetness +(1|SubjectID), data = subset(delta_data, condition=='sugar-free'))
summ(model2)

export_summs(model1, model2, model.names = c('Delta of WTP for sugar-containing','Delta of WTP for sugar-free'),
             error_format = "{std.error}", statistics = character(0), digits=3)



g1 = ggplot(subset(delta_data, condition != 'non-edible'), aes(tastiness, delta_WTP, color=condition))+
  geom_smooth(method = 'lm', se = F) +
  scale_color_manual(values=c('royalblue','forestgreen'))+
  theme_classic()+
  scale_x_continuous(limits=c(1,7), breaks=1:7) +
  coord_cartesian(ylim = c(-10,10))+
  geom_hline(yintercept = 0, lty=2) +
  ylab('Delta of WTP (MU)') +
  xlab('Tastiness') +
  theme(
    text=element_text(size=10),
    legend.position = 'top'
  )

g2 = ggplot(subset(delta_data, condition != 'non-edible'), aes(sweetness, delta_WTP, color=condition))+
  geom_smooth(method = 'lm', se = F) +
  scale_color_manual(values=c('royalblue','forestgreen'))+
  theme_classic()+
  scale_x_continuous(limits=c(1,7), breaks=1:7) +
  coord_cartesian(ylim = c(-10,10))+
  geom_hline(yintercept = 0, lty=2) +
  xlab('Sweetness') +
  ylab('')+
  theme(
    text=element_text(size=10),
    legend.position = 'top'
  )

g3 = ggplot(subset(delta_data, condition != 'non-edible'), aes(familiarity, delta_WTP, color=condition))+
  geom_smooth(method = 'lm', se = F) +
  scale_color_manual(values=c('royalblue','forestgreen'))+
  theme_classic()+
  scale_x_continuous(limits=c(1,7), breaks=1:7) +
  coord_cartesian(ylim = c(-10,10))+
  geom_hline(yintercept = 0, lty=2) +
  xlab('Familiarity') +
  ylab('')+
  theme(
    text=element_text(size=10),
    legend.position = 'top'
  )

g = ggarrange(g1, g2, g3, common.legend = T, nrow = 1)
g

#ggsave('results/Delta_WTP_pretest.png', dpi=600, width=180, height=80, units='mm')

cor.test(delta_data$delta_WTP, delta_data$tastiness, data = subset(delta_data, condition == 'sugar-free'))
cor.test(delta_data$delta_WTP, delta_data$sweetness, data = subset(delta_data, condition == 'sugar-free'))




### Compare genders

beh = read.xlsx('Participants.xlsx')
beh = beh[-which(is.na(beh[,1])),]
beh = beh[order(beh[,1]),]
gender = ifelse(beh[,5]=="??????????????", 'F', 'M')
table(gender)

delta_df = cbind(delta_df, 'gender' = factor(c(rep(gender, 3))))
str(delta_df)

delta_df %>%
  group_by(condition, gender) %>%
  identify_outliers(bid)

delta_df %>%
  group_by(condition, gender) %>%
  shapiro_test(bid)

res.aov <- anova_test(
  data = delta_df, dv = bid, wid = id,
  between = gender, within = condition
)
get_anova_table(res.aov)




delta_df %>% friedman_effsize(bid ~ condition |id)

pwc = delta_df %>%
  wilcox_test(
    bid ~ condition, paired = T,
    p.adjust.method = "BH"
  )
pwc

delta_df %>%
  wilcox_effsize(
    bid ~ condition, paired = T
  )

pwc <- pwc %>% add_xy_position(x = "condition")


g1 = ggboxplot(
  delta_df, x = "condition", y = "bid",
  fill='condition', add='jitter', add.params = list(size=0.5)
)+
  scale_y_continuous(limits = c(-30,40), breaks = seq(-30,40,10))+
  scale_fill_manual(values=c('royalblue','darkmagenta','forestgreen'))+
  scale_color_manual(values=c('royalblue','darkmagenta','forestgreen'))+
  ylab('??WTP (MU)')+
  xlab('')+
  geom_hline(yintercept = 0, lty=2) +
  stat_pvalue_manual(pwc, hide.ns = T, tip.length = 0) +
  stat_summary(fun=mean, geom="point", shape=15, size=3, color="black") +
  theme(
    text=element_text(size=8),
    legend.position = 'none'
  )

g1


