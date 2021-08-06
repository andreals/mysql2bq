#!/bin/bash

# Function to convert CREATE TABLE statement in BigQuery Schema JSON-file.
generate_schema_file() {
    
    content=$(zcat "$1")
    backupfilename=$(echo "$1" | sed -e "s/dumpfiles\//dumpfiles\/backups\//g")
    table=""
    filename=""
    jsoncontent=""

    while read -r a; do

        if [[ $a =~ "CREATE TABLE" ]]; then

            table=$(echo $a | grep -Po '\`(.+)\`' | sed -e "s/\`//g")
            filename="bqfiles/$table.json"
            rm -rf "$filename"

        elif [[ $a =~ "PRIMARY" ]]; then
            break
        elif [[ $table != "" ]]; then

            read -a arr <<< $a
            column=$(echo ${arr[0]} | sed -e "s/\`//g")
            type=$(echo ${arr[1]})
            if [[ $type =~ "int" ]]; then
                type="INTEGER"
            elif [[ $type =~ "enum" ]] || [[ $type =~ "varchar" ]] || [[ $type =~ "char" ]] || [[ $type =~ "text" ]]; then
                type="STRING"
            elif [[ $type =~ "decimal" ]]; then
                type="NUMERIC"
            elif [[ $type =~ "bit" ]]; then
                type="BOOL"
            elif [[ $type =~ "float" ]] || [[ $type =~ "double" ]]; then
                type="FLOAT"
            fi

            mode=""
            if [[ $a =~ "NOT NULL" ]]; then
                mode="NULLABLE"
            fi

            json="{\"name\": \"${column}\", \"type\": \"${type}\", \"mode\": \"${mode}\"},"
            jsoncontent="${jsoncontent}${json}"

        fi

    done <<< "$(echo "$content")"

    jsoncontent=$(echo "$jsoncontent" | sed -e 's/,$//g')
    jsoncontent="[$jsoncontent]"
    echo "$jsoncontent" > "$filename"

    mv "$1" "$backupfilename"
}

# Function to convert INSERT INTO statement in CSV-file.
generate_csv_file() {
    
    content=$(zcat "$1")
    backupfilename=$(echo "$1" | sed -e "s/dumpfiles\//dumpfiles\/backups\//g")
    table=""
    filename=""

    while read -r a; do
        
        if [[ $a =~ "INSERT INTO" ]]; then
        
            table=$(echo $a | grep -Po '\`(.+)\`' | sed -e "s/\`//g")
            filename="bqfiles/$table.csv"
            rm -rf "$filename"
        
        elif [[ $table != "" ]]; then
        
            csv=$(echo $a | sed -e "s/0000-00-00//g" | sed -e "s/0000-00-00 00:00:00//g" | sed -e "s/NULL//g" | sed -e "s/null//g")
            csv=$(echo "$csv" | sed -e 's/,$//g')
            csv=$(echo "$csv" | sed -e 's/;$//g')
            csv=$(echo "$csv" | sed -e 's/)$//g')
            csv=$(echo "$csv" | sed -e 's/^(//g')
            echo "$csv" >> "$filename"

        fi

    done <<< "$(echo "$content")"

    mv "$1" "$backupfilename"
}

# Creating global vars
path=$(echo "$0" | sed -e "s/dump2csv.sh//g")

# List all dump files of directory.
for entry in "$path"dumpfiles/*; do
    
    if [ $entry != "dumpfiles/backups" ]; then
        
        if [[ $entry =~ "-schema." ]]; then
            generate_schema_file $entry
        else
            generate_csv_file $entry
        fi

    fi

done