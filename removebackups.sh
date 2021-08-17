#!/bin/bash

# Creating global vars
path=$(echo "$0" | sed -e "s/removebackups.sh//g")

# Going to correct path
cd $path

# Removing files of 'dumpfiles' folder...
echo "Removing files of 'dumpfiles' folder..."
rm -rf dumpfiles/*.*

# Removing backups of 'dumpfiles' folder...
echo "Removing backups of 'dumpfiles' folder..."
rm -rf dumpfiles/backups/*

# Removing files of 'bqfiles' folder...
echo "Removing files of 'bqfiles' folder..."
rm -rf bqfiles/*.*

# Removing backups of 'bqfiles' folder...
echo "Removing backups of 'bqfiles' folder..."
rm -rf bqfiles/backups/*