#!/bin/bash

file_path=$(fzf)

function newGroup(){
  id="$(openssl rand -base64 12)"
  name=$1
  slug=$(echo $name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  result=$(cat $file_path | jq '.[0].fields[.[0].fields| length] += {
  "key": "field_'${id}'",
  "label": "'${name}'",
  "name": "'${slug}'",
  "aria-label": "",
  "type": "group",
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

function newTab(){
  id="$(openssl rand -base64 12)"
  name=$1
  slug=$(echo $name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  result=$(cat $file_path | jq '.[0].fields[.[0].fields| length] += {
  "key": "field_'${id}'",
  "label": "'${name}'",
  "name": "'${slug}'",
  "aria-label": "",
  "type": "tab",
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
newGroup $name
}

read -p "Enter the name of the tab: " tab_name
newTab $tab_name
