
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

# Read the data
data = read.csv('../fMRI analysis/deltas.csv')[,2]
threshold = median(data)
group = ifelse(data>threshold, 'influenced', 'not_influenced')
table(group)

setwd('traits')

conformity = read.csv('conformity_scores.csv', header=F)[,1]
susceptibility = read.csv('susceptibility_scores.csv', header=F)[,1]

extraversion = read.csv('extraversion_scores.csv')[,2]
agreeableness = read.csv('agreeableness_scores.csv')[,2]
openness = read.csv('openness_scores.csv')[,2]
conscientiousness = read.csv('conscientiousness_scores.csv')[,2]
neuroticism = read.csv('neuroticism_scores.csv')[,2]

setwd('..')

demographics = read.xlsx('Dataset.xlsx')
age = demographics$age[seq(1,nrow(demographics),180)]
bmi = demographics$BMI[seq(1,nrow(demographics),180)]
sex = demographics$sex[seq(1,nrow(demographics),180)]
education = demographics$education[seq(1,nrow(demographics),180)]

setwd('movements')

files = dir(pattern = '.tsv')
Nsubs = length(files)
fd = c()
for(i in 1:Nsubs){
  thisFile = read.table(paste('sub-',i,'_task-narrative_desc-confounds_timeseries.tsv', sep=''), header = T)[-1,]  # Slow
  thisFD = as.numeric(thisFile$framewise_displacement)
  fd = c(fd, mean(thisFD))
}

tsnr_data = read.csv('tSNR.csv')
tsnr_data = na.omit(tsnr_data)
tsnr = colMeans(tsnr_data)

df = data.frame('group' = group,
                'conformity' = conformity,
                'susceptibility' = susceptibility,
                'extraversion' = extraversion,
                'agreeableness' = agreeableness,
                'openness' = openness,
                'conscientiousness' = conscientiousness,
                'neuroticism' = neuroticism,
                'age' = age,
                'bmi' = bmi,
                'sex' = sex,
                'education' = education,
                'fd' = fd,
                'tsnr' = tsnr)

# Check assumptions for t-test and apply t-test or Wilcoxon test

df %>%
  group_by(group) %>%
  shapiro_test(conformity)
df %>%
  t_test(conformity ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(susceptibility)
df %>%
  t_test(susceptibility ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(extraversion)
df %>%
  t_test(extraversion ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(agreeableness)
df %>%
  t_test(agreeableness ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(openness)
df %>%
  t_test(openness ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(conscientiousness)
df %>%
  t_test(conscientiousness ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(neuroticism)
df %>%
  t_test(neuroticism ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(age)
df %>%
  wilcox_test(age ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(bmi)
df %>%
  t_test(bmi ~ group)

table(df$group, df$sex)
chisq.test(df$group, df$sex)

table(df$group, df$education)
chisq.test(df$group, df$education)

df %>%
  group_by(group) %>%
  shapiro_test(fd)
df %>%
  wilcox_test(fd ~ group)

df %>%
  group_by(group) %>%
  shapiro_test(tsnr)
df %>%
  t_test(tsnr ~ group)
