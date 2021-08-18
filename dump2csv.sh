#!/bin/bash

# Function to convert CREATE TABLE statement in BigQuery Schema JSON-file.
generate_schema_file() {
    
    content=$(zcat "$1")
    backupfilename="backups/$1"
    table=""
    filename=""
    jsoncontent=""

    while read -r a; do

        if [[ $a =~ "CREATE TABLE" ]]; then

            table=$(echo $a | grep -Po '\`(.+)\`' | sed -e "s/\`//g")
            filename="../bqfiles/$table.json"
            rm -rf "$filename"

        elif [[ $a =~ "PRIMARY" || $a =~ ^\) ]]; then
            break
        elif [[ $table != "" ]]; then

            read -a arr <<< $a
            column=$(echo ${arr[0]} | sed -e "s/\`//g")
            type=$(echo ${arr[1]})
            if [[ $type =~ ^int ]] || [[ $type =~ ^tinyint ]] || [[ $type =~ ^smallint ]] || [[ $type =~ ^mediumint ]] || [[ $type =~ ^integer ]] || [[ $type =~ ^bigint ]]; then
                type="INTEGER"
            elif [[ $type =~ ^enum ]] || [[ $type =~ ^binary ]] || [[ $type =~ ^varbinary ]] || [[ $type =~ ^tinyblob ]] || [[ $type =~ ^tinytext ]] || [[ $type =~ ^blob ]] || [[ $type =~ ^varchar ]] || [[ $type =~ ^char ]] || [[ $type =~ ^text ]] || [[ $type =~ ^longtext ]] || [[ $type =~ ^mediumtext ]] || [[ $type =~ ^mediumblob ]] || [[ $type =~ ^longblob ]] || [[ $type =~ ^set ]] || [[ $type =~ ^time ]] || [[ $type =~ ^timestamp ]] || [[ $type =~ ^year ]]; then
                type="STRING"
            elif [[ $type =~ ^decimal ]] || [[ $type =~ ^dec ]]; then
                type="NUMERIC"
            elif [[ $type =~ ^bit ]] || [[ $type =~ ^bool ]]; then
                type="BOOL"
            elif [[ $type =~ ^float ]] || [[ $type =~ ^double ]]; then
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

# Creating global vars
path=$(echo "$0" | sed -e "s/dump2csv.sh//g")

# Going to correct path
cd "${path}/dumpfiles"

# Generate all schema json-files of directory
for entry in *-schema.sql.gz; do
    
    echo "Generating json-file from '${entry}'..."
    generate_schema_file $entry

done

# Generate all data csv-files of directory
for entry in *.sql.gz; do

    echo "Generating csv-file from '${entry}'..."
    table=$(echo "$entry" | grep -Po '\.(.+)\.sql\.gz' | sed -e "s/\.sql\.gz//g" | sed -e "s/\.//g")
    filename="../bqfiles/${table}.csv"
    rm -rf "$filename"

    zcat "$entry" | \
        sed "/^\/\*/d" | \
        ../mysqldump2csv >> \
        "$filename" &

done

# Move all .sql.gz files to backup folder
for entry in *.sql.gz; do
    
    echo "Moving file '${entry}' to backup folder..."
    backupfilename="backups/${entry}"
    mv "$entry" "$backupfilename"

done