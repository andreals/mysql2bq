#!/bin/bash

# Creating global vars
project_id=$1
dataset=$2
tables=()

for entry in bqfiles/*; do
    
    backupfilename=$(echo "$entry" | sed -e "s/bqfiles\//bqfiles\/backups\//g")
    if [ $entry != "bqfiles/backups" ]; then
        
        # Getting tables name...
        table=$(echo "$entry" | grep -Po 'bqfiles\/(.+)\.' | sed -e "s/bqfiles\///g" | sed -e "s/.$//g")
        tables+=($table)

    fi

done

for table in $tables; do
    # Uploading data...
    echo "Uploading data of table '$table' in dataset '$dataset' of project '$project_id'..."
    bq load --project_id="$project_id" --source_format=CSV "$dataset.$table" bqfiles/"$table".csv bqfiles/"$table".json
    
    # Moving files to backup folder...
    mv "bqfiles/$table.csv" "bqfiles/backups/$table.csv"
    mv "bqfiles/$table.json" "bqfiles/backups/$table.json"
done