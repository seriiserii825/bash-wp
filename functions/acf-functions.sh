#!/bin/bash

function newGroup(){
  local id="$(openssl rand -base64 12)"
  local name=$(echo $1 | tr ' ' '_')
  local type=$2
  local file_path=$3
  local slug=$(echo $name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  local result=$(cat $file_path | jq '.[0].fields[.[0].fields| length] += {
  "key": "field_'${id}'",
  "label": "'${name}'",
  "name": "'${slug}'",
  "aria-label": "",
  "type": "'${type}'",
  "instructions": "",
  "required": 0,
  "conditional_logic": 0,
  "wrapper": {
  "width": "",
  "class": "",
  "id": ""
},
"placement": "top",
"endpoint": 0,
"date": "2010-01-07T19:55:99.999Z",
"xml": "xml_samplesheet_2017_01_07_run_09.xml",
"status": "OKKK",
"message": "metadata loaded into iRODS successfullyyyyy"
}')
echo $result > $file_path
}

export -f newGroup

function removeGroup(){
  local file_path=$1
  local labels=()

# read each item in the JSON array to an item in the Bash array
readarray -t my_array < <(jq --compact-output '.[0].fields[]' $file_path)

# iterate through the Bash array
for item in "${my_array[@]}"; do
  echo "========= start"
  local label=$(jq --raw-output '.label' <<< "$item")
  local type=$(jq --raw-output '.type' <<< "$item")
  if [[ $type == "group" ]]; then
    labels+=($label)
  fi
done

select elem in "${labels[@]}"; do 
  [[ $elem ]] || continue
  local key=$(jq -r '.[0].fields[] | select(.label == "'${elem}'") | .key' $file_path)
  local result=$(cat $file_path | jq 'del(.[0].fields[] | select(.key == "'${key}'"))')
  echo $result > $file_path
  bat $file_path
  exit 0
done
key=$1
file_path=$2
local result=$(cat $file_path | jq 'del(.[0].fields['${key}'])')
}
