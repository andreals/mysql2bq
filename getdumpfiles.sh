#!/bin/bash

# Creating global vars
path=$(echo "$0" | sed -e "s/getdumpfiles.sh//g")
user=$1
password=$2
host=$3
folder=$4

# Getting all dump files
sshpass -p "$password" scp "$user"@"$host":"$folder"*.sql.gz "$path"dumpfiles/.