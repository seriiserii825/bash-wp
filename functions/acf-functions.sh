#!/bin/bash

function newGroup(){
  local id="$(openssl rand -base64 12)"
  local name=$1
  local type=$2
  local file_path=$3
  local slug=$(echo $name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  cat $file_path | jq '.[0].fields[.[0].fields| length] += {
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
}'
}

export -f newGroup

function removeGroup(){
  local file_path=$1
  local labels=()

  for i in "$(jq -r '.[0].fields[]' $file_path)"; do
    # local key=$(echo $i | jq -r .key)
    local label=$(echo $i | jq -r .label)
    labels+=($label)
  done

  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    local key=$(jq -r '.[0].fields[] | select(.label == "'${elem}'") | .key' $file_path)
    echo $key
    break
  done
  # key=$1
  # file_path=$2
  # local result=$(cat $file_path | jq 'del(.[0].fields['${key}'])')
}
