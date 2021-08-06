#!/bin/bash

# Creating global vars
user=$1
password=$2
host=$3
folder=$4

# Getting all dump files
sshpass -p "$password" scp "$user"@"$host":"$folder"*.sql.gz dumpfiles/.