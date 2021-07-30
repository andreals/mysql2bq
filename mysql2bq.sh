#!/bin/bash

# Creating global vars
user=$1
password=$2
host=$3
folder=$4
project_id=$5
dataset=$6

# Running 'getdumpfiles.sh'...
echo "Running 'getdumpfiles.sh'..."
./getdumpfiles.sh "$user" "$password" "$host" "$folder"

# Running 'dump2csv.sh'...
echo "Running 'dump2csv.sh'..."
./dump2csv.sh

# Running 'upload2bq.sh'...
echo "Running 'upload2bq.sh'..."
./upload2bq.sh "$project_id" "$dataset"