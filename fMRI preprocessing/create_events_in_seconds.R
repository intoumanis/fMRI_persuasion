
setwd('../data_raw')
folders = list.dirs(recursive = F, full.names = F)

for(participant in folders){
  
  setwd(participant)
  files=dir(pattern='.csv')
  
  # Read the data of one subject
  data = read.csv(files[1])
  
  # Find the scanning onset
  scanning_onset = data$Scanning_onset[2]
  
  # Onset of images, relative to the scanning onset
  pictures_block1_onset = data$image.started[3:92] - scanning_onset
  pictures_block2_onset = data$image.started[96:185] - scanning_onset
  pictures_duration = 4
  
  # Type of images
  pictures_block1_type = ifelse(data[3:92,2]==1,'sugar-free',ifelse(data[3:92,2]==0,'sugar-containing','non-edible'))
  pictures_block2_type = ifelse(data[96:185,2]==1,'sugar-free',ifelse(data[96:185,2]==0,'sugar-containing','non-edible'))
  
  # Onset of the narrative, relative to the scanning onset
  narrative_onset = data[95,58] - scanning_onset
  narrative_duration = 425
  
  # If slice timing correction was applied, all onsets should be shifted half a TR later in time
  TR = 2
  pictures_block1_onset = round(pictures_block1_onset + TR/2)
  pictures_block2_onset = round(pictures_block2_onset + TR/2)
  narrative_onset = round(narrative_onset + TR/2)
  
  # Summarize everything in a dataframe
  events = data.frame('onset' = c(pictures_block1_onset, narrative_onset, pictures_block2_onset),
                      'duration' = c(rep(pictures_duration,90),narrative_duration,rep(pictures_duration,90)),
                      'trial_type' = c(pictures_block1_type,'narrative',pictures_block1_type),
                      'block' = c(rep(1,90), 0, rep(2,90)))
  
  # Save it as a .tsv file
  write.table(events, file = paste("../../data_bids/",participant,"/func/",participant,"_task-narrative_events.tsv", sep=""), row.names=F, sep="\t")
  
  setwd('..')
}

