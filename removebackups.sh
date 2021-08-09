#!/bin/bash

# Creating global vars
path=$(echo "$0" | sed -e "s/removebackups.sh//g")

# Going to correct path
cd $path

# Removing backups of 'dumpfiles' folder...
echo "Removing backups of 'dumpfiles' folder..."
rm -rf dumpfiles/backups/*

# Removing backups of 'bqfiles' folder...
echo "Removing backups of 'bqfiles' folder..."
rm -rf dumpfiles/bqfiles/*