
setwd('../data_raw')
folders = list.dirs(recursive = F, full.names = F)

for(participant in folders){
  
  setwd(participant)
  files=dir(pattern='.csv')
  
  # Read the data of one subject
  data = read.csv(files[1])
  
  # Find the scanning onset, offset and moment of each volume (be careful - slice time correction realigned all slices in the middle of each TR)
  scanning_onset = data$Scanning_onset[2]
  scanning_offset = na.omit(data$key_resp_3.started)[1] + na.omit(data$key_resp_3.rt)[1]
  TR = 2
  volume_moments = seq(scanning_onset, scanning_offset, 2) + TR/2

  # Onset of images (in volumes)
  pictures_block1_onset = c()
  for(i in 3:92){
    thisPicture = data$image.started[i]
    pictures_block1_onset = c(pictures_block1_onset, which(volume_moments > thisPicture)[1])
  }
  
  pictures_block2_onset = c()
  for(i in 96:185){
    thisPicture = data$image.started[i]
    pictures_block2_onset = c(pictures_block2_onset, which(volume_moments > thisPicture)[1])
  }
  
  pictures_duration = 4

  # Type of images
  pictures_block1_type = ifelse(data[3:92,2]==1,'SugarFree',ifelse(data[3:92,2]==0,'SugarContaining','NonEdible'))
  pictures_block2_type = ifelse(data[96:185,2]==1,'SugarFree',ifelse(data[96:185,2]==0,'SugarContaining','NonEdible'))
  
  # Onset of the narrative, relative to the scanning onset
  narrative_start = na.omit(data$sound_1.started)[1]
  narrative_onset = which(volume_moments > narrative_start)[1]
  narrative_duration = 425
  
  # Summarize everything in a dataframe
  events = data.frame('onset' = c(pictures_block1_onset, narrative_onset, pictures_block2_onset),
                      'duration' = c(rep(pictures_duration,90),narrative_duration,rep(pictures_duration,90)),
                      'trial_type' = c(pictures_block1_type,'narrative',pictures_block1_type),
                      'block' = c(rep(1,90), 0, rep(2,90)))
  
  # Save it as a .tsv file
  write.table(events, file = paste("../../data_bids/",participant,"/func/",participant,"_task-narrative_events.tsv", sep=""), row.names=F, sep="\t")
  
  setwd('..')
}

