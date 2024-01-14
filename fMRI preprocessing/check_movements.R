
library(ggplot2)
library(ggrepel)

# Load the confound data
setwd('D:/fmri_sugar/other/movements')
Nsubs = length(dir(pattern='.tsv'))

fd = c()

for(i in 1:Nsubs){
  
  thisFile = read.table(paste('sub-',i,'_task-narrative_desc-confounds_timeseries.tsv', sep=''), header = T)[-1,]  # Slow
  thisFD = as.numeric(thisFile$framewise_displacement)
  fd = c(fd, mean(thisFD))
  
}

df = data.frame(fd, 'id'=paste('sub', 1:Nsubs, sep=''))
str(df)

ggplot(df, aes(x=1, y=fd, label = id)) +
  geom_jitter(position = position_jitter(seed = 1)) +
  geom_text_repel(aes(label = id), position = position_jitter(seed = 1)) +
  scale_x_continuous(limits = c(0, 2)) +
  scale_y_continuous(limits = c(0,0.6), breaks = seq(0,0.6,0.1)) +
  geom_hline(yintercept = 0.5, lty = 2) +
  ylab('Framewise Displacement (mm)') +
  xlab('') +
  labs(title = 'Our data') +
  theme_classic() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(face = 'bold', size=14),
        text = element_text(size=16))

ggplot(df, aes(x=fd)) + 
  geom_histogram(color="black", fill="lightblue") +
  geom_vline(xintercept = 0.5, lty = 2, lwd=1.5) +
  theme_classic()+
  ylab('Framewise Displacement (mm)') +
  xlab('')+
  theme(axis.text.x = element_text(face = 'bold', size=14),
        axis.text.y = element_text(face = 'bold', size=14),
        text = element_text(size=16))

ggsave(file = "/home/intoumanis/sugar/results/Movements.png", last_plot(), width = 180, height = 180, units = 'mm', dpi = 300)