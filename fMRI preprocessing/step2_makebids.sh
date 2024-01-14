#!/bin/bash

# make a dataset_Dscription.json

echo '{"Name":"Expert persuasion on sugar", "BIDSVersion":"1.0.2", "Authors":["Ioannis Ntoumanis", "Julia Sheronova", "Alina Davidova"], "Funding":["list here"]}' > ../data_bids/dataset_description.json
echo '{"TaskName": "Narrative"}' > ../data_bids/task-narrative_bold.json
echo '{"onset": {"LongName": "Onset", "Description": "Onset time for each picture presentation and for the narrative"},
"duration": {"LongName": "Duration", "Description": "Time for which each picture was on the screen or that the narrative was played"},
"trial_type": {"LongName": "Trial Type", "Description": "Indicates the product category of the pictures (sugar-free,sugar-containing,non-edible)"},
"block": {"LongName": "Block", "Description": "Indicates whether each trial belongs to the 1st block of the bidding task (i.e., before the narrative) or to the 2nd block of the bidding task (i.e., after the narrative)"}}'  > ../data_bids/task-narrative_events.json

