#!/bin/bash

function showFields(){
  local file_path=$1
  # read each item in the JSON array to an item in the Bash array
  readarray -t my_array < <(jq --compact-output '.[0].fields[]' $file_path)

  for item in "${my_array[@]}"; do
    local label=$(jq --raw-output '.label' <<< "$item")
    local type=$(jq --raw-output '.type' <<< "$item")
    if [ $type == "group" ]; then
      echo "$label"
    fi
  done
}

function showSubFields(){
  local file_path=$1
  # read each item in the JSON array to an item in the Bash array
  readarray -t my_array < <(jq --compact-output '.[0].fields[]' $file_path)

  for item in "${my_array[@]}"; do
    local label=$(jq --raw-output '.label' <<< "$item")
    local type=$(jq --raw-output '.type' <<< "$item")

    if [ $type == "group" ]; then
      local key_group=$(jq -r '.[0].fields[] | select(.label == "'${label}'" and .type == "group") | .key' $file_path)
      local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
      readarray -t sub_fields < <(jq --compact-output '.[0].fields['${group_index}'].sub_fields[]' $file_path)

      echo "${tblue}$label${treset}"
      for item in "${sub_fields[@]}"; do
        local sub_label=$(jq --raw-output '.label' <<< "$item")
        local sub_type=$(jq --raw-output '.type' <<< "$item")
        echo "${tgreen}$sub_label: $sub_type${treset}"
      done
    fi
  done
}

function editGroup(){
  local file_path=$1
  local labels=()
  readarray -t my_array < <(jq --compact-output '.[0].fields[]' $file_path)

  for item in "${my_array[@]}"; do
    local label=$(jq --raw-output '.label' <<< "$item")
    local type=$(jq --raw-output '.type' <<< "$item")
    if [ $type == "group" ]; then
      labels+=($label)
    fi
  done

  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
    read -p "Enter the name of the group: " group_name
    local result=$(cat $file_path | jq '.[0].fields['${group_index}'].label = "'${group_name}'"')
    echo $result > $file_path
    showFields $file_path
  done
}

function newGroup(){
  local id="$(openssl rand -base64 12)"
  local name=$(echo $1 | tr ' ' '_')
  local type=$2
  local file_path=$3
  local slug=$(echo $name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
  if [ $type == "tab" ]; then
    local result=$(cat $file_path | jq '.[0].fields[.[0].fields| length] += {
    "key": "field_'${id}'",
    "label": "'${name}'_Tab",
    "type": "tab",
    "placement": "top",
    "endpoint": 0,
    "date": "2010-01-07T19:55:99.999Z",
    "xml": "xml_samplesheet_2017_01_07_run_09.xml",
    "status": "OKKK",
    "message": "metadata loaded into iRODS successfullyyyyy"
  }')
  echo $result > $file_path
elif [ $type == "group" ]; then
  local result=$(cat $file_path | jq '.[0].fields[.[0].fields| length] += {
  "key": "field_'${id}'",
  "label": "'${name}'",
  "name": "'${slug}'",
  "type": "group",
  "instructions": "",
  "required": 0,
  "conditional_logic": 0,
  "wrapper": {
  "width": "",
  "class": "",
  "id": "",
},
"layout": "block",
"sub_fields": [],
"placement": "top",
"endpoint": 0,
"date": "2010-01-07T19:55:99.999Z",
"xml": "xml_samplesheet_2017_01_07_run_09.xml",
"status": "OKKK",
"message": "metadata loaded into iRODS successfullyyyyy"
}')
echo $result > $file_path
  fi
}

function getLabels(){
  local file_path=$1
  local labels=()
  # read each item in the JSON array to an item in the Bash array
  readarray -t my_array < <(jq --compact-output '.[0].fields[]' $file_path)

  # iterate through the Bash array
  for item in "${my_array[@]}"; do
    local label=$(jq --raw-output '.label' <<< "$item")
    local type=$(jq --raw-output '.type' <<< "$item")
    labels+=($label)
  done
  echo "${labels[@]}"
}

function removeGroup(){
  local file_path=$1
  local labels=($(getLabels $file_path))

  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    local key_tab=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "tab") | .key' $file_path)
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local result_tab=$(cat $file_path | jq 'del(.[0].fields[] | select(.key == "'${key_tab}'"))')
    echo $result_tab > $file_path
    local result_group=$(cat $file_path | jq 'del(.[0].fields[] | select(.key == "'${key_group}'"))')
    echo $result_group > $file_path
    showFields $file_path
  done
  key=$1
  file_path=$2
  local result=$(cat $file_path | jq 'del(.[0].fields['${key}'])')
}

function addSubField(){
  local id="field_$(openssl rand -base64 12)"
  local file_path=$1
  local labels=($(getLabels $file_path))

  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    read -p "Enter the name of the field: " field_name
    local name=$(echo $field_name | tr ' ' '_')
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
    local result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields[.[0].fields['${group_index}'].sub_fields| length] += {
    "key": "'${id}'",
    "label": "'${field_name}'",
    "name": "'${name}'",
    "aria-label": "",
    "type": "text",
    "instructions": "",
    "required": 0,
    "conditional_logic": 0,
    "wrapper": {
    "width": "",
    "class": "",
    "id": ""
  },
  "default_value": "",
  "maxlength": "",
  "placeholder": "",
  "prepend": "",
  "append": ""
}')
echo $result > $file_path
done
}

