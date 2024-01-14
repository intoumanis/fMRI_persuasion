
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
library(readxl)

options("scipen"=100, "digits"=4)

# Load the data and fix the order of the columns
data_sugarfree = read_excel('D:/fmri_sugar/results/glm_roi/avgbeta_sugarfree.xlsx')[,-1]
#data_sugarfree = data_sugarfree[,-which(colnames(data_sugarfree)=='subject-sub-0')]
data_nonedible = read_excel('D:/fmri_sugar/results/glm_roi/avgbeta_nonedible.xlsx')[,-1]
#data_nonedible = data_nonedible[,-which(colnames(data_nonedible)=='subject-sub-0')]
data_sugar = read_excel('D:/fmri_sugar/results/glm_roi/avgbeta_sugar.xlsx')[,-1]
#data_sugar = data_sugar[,-which(colnames(data_sugar)=='subject-sub-0')]

rois = data_sugarfree$ROI
data_sugarfree = data_sugarfree[,-1]
data_nonedible = data_nonedible[,-1]
data_sugar = data_sugar[,-1]

subjects = colnames(data_sugarfree)
data_sugarfree = data_sugarfree[,sort(subjects, index.return=T)$ix]
data_nonedible = data_nonedible[,sort(subjects, index.return=T)$ix]
data_sugar = data_sugar[,sort(subjects, index.return=T)$ix]

# Specify ROIs
vmPFC_sugarfree = as.numeric(as.vector(data_sugarfree[which(rois=="Frontal_Med_Orb_L"),]))
na_sugarfree = as.numeric(as.vector(data_sugarfree[which(rois=="N_Acc_L"),]))
hg_sugarfree = as.numeric(as.vector(data_sugarfree[which(rois=="Occipital_Sup_L"),]))

vmPFC_nonedible = as.numeric(as.vector(data_nonedible[which(rois=="Frontal_Med_Orb_L"),]))
na_nonedible = as.numeric(as.vector(data_nonedible[which(rois=="N_Acc_L"),]))
hg_nonedible = as.numeric(as.vector(data_nonedible[which(rois=="Occipital_Sup_L"),]))

vmPFC_sugar = as.numeric(as.vector(data_sugar[which(rois=="Frontal_Med_Orb_L"),]))
na_sugar = as.numeric(as.vector(data_sugar[which(rois=="N_Acc_L"),]))
hg_sugar = as.numeric(as.vector(data_sugar[which(rois=="Occipital_Sup_L"),]))

# Load the deltas and divide participants
deltas = read.csv('D:/fmri_sugar/results/deltas.csv')
delta_sugarfree = deltas$sugar_free
group = ifelse(delta_sugarfree > median(delta_sugarfree), 'persuaded', 'not_persuaded')
table(group)

df = data.frame('beta' = c(vmPFC_sugarfree, na_sugarfree, hg_sugarfree,
                           vmPFC_nonedible, na_nonedible, hg_nonedible,
                           vmPFC_sugar, na_sugar, hg_sugar),
                'ROI' = c(rep(c(rep('vmPFC',50), rep('NAcc',50), rep('SOG',50)), 3)),
                'group' = c(rep(group, 3*3)),
                'condition' = c(rep('sugar-free', 50*3), rep('non-edible', 50*3), rep('sugar-containing', 50*3)),
                'id' = c(rep(1:50, 3*3)))
str(df)
df$group = factor(df$group, levels = c('persuaded','not_persuaded'), labels=c('Persuaded', 'Not persuaded'))
df$ROI = factor(df$ROI, levels = c('vmPFC','NAcc','SOG'))
df$condition = factor(df$condition, levels = c('sugar-containing', 'non-edible', 'sugar-free'))
str(df)

# Statistics and visualization
df %>%
  group_by(condition, group, ROI) %>%
  identify_outliers(beta)

df %>%
  group_by(condition, group, ROI) %>%
  shapiro_test(beta)

res.aov <- anova_test(
  data = df, dv = beta, wid = id,
  between = group, within = c(condition, ROI)
)
get_anova_table(res.aov)

# Comparing ROIs
df %>%
  group_by(group, condition) %>%
  anova_test(dv = beta, wid = id, within = ROI) %>%
  get_anova_table()

df %>%
  group_by(group, condition) %>%
  pairwise_t_test(
    beta ~ ROI, paired = TRUE, 
    p.adjust.method = "BH"
  ) %>%
  filter(condition!='non-edible')

# Comparing conditions
df %>%
  group_by(group, ROI) %>%
  anova_test(dv = beta, wid = id, within = condition) %>%
  get_anova_table()

df %>%
  group_by(group, ROI) %>%
  pairwise_t_test(
    beta ~ condition, paired = TRUE, 
    p.adjust.method = "BH"
  )


ggboxplot(
  df, x = "ROI", y = "beta", facet.by = 'condition',
  color = "group", add = 'jitter', add.params = list(size=1), size=1
)+
  scale_color_manual(values=c('cadetblue4','darkorange3'))+
  ylab('Beta coefficients')+
  xlab('')+
  geom_hline(yintercept = 0, lty=2)+
  theme(
    text=element_text(size=12),
    axis.text.y = element_text(size=12),
    legend.position = 'top',
    legend.title = element_blank(),
    legend.text = element_text(face='bold'),
    strip.text.x = element_text(size = 10, color = "black", face = "bold"),
    strip.background=element_rect(fill="white")
  )

ggsave('D:/fmri_sugar/results/important/glm.png', dpi=600, width=300, height=150, units = 'mm')

# control
t.test(df$beta[df$ROI=='SOG'], mu=0)


# More exploratory
all_ps = c()

for(i in 1:nrow(data)){
  this_roi = as.numeric(as.vector(data[i,]))
  this_p = t.test(this_roi ~ group)$p.value
  all_ps[i] = this_p
}

all_ps = p.adjust(all_ps, method = 'BH')
sort(all_ps)


