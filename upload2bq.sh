#!/bin/bash

# Creating global vars
path=$(echo "$0" | sed -e "s/upload2bq.sh//g")
project_id=$1
dataset=$2
date=$(date '+%Y%m%d_%H')

# Going to correct path
cd $path

for entry in bqfiles/*.json; do
    
    backupfilename=$(echo "$entry" | sed -e "s/bqfiles\//bqfiles\/backups\//g")
        
    # Getting tables name...
    table=$(echo "$entry" | grep -Po 'bqfiles\/(.+)\.' | sed -e "s/bqfiles\///g" | sed -e "s/.$//g")
    
    # Uploading data...
    echo "Uploading data of table '$table' in dataset '$dataset' of project '$project_id'..."
    bq load --project_id="$project_id" --replace --source_format=CSV "$dataset.$table" bqfiles/"$table".csv bqfiles/"$table".json
    bq load --project_id="$project_id" --source_format=CSV "${dataset}_TimeMachine.${table}_${date}" bqfiles/"$table".csv bqfiles/"$table".json
    
    # Moving files to backup folder...
    mv "bqfiles/$table.csv" "bqfiles/backups/$table.csv"
    mv "bqfiles/$table.json" "bqfiles/backups/$table.json"

done