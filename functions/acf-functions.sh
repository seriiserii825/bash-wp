#!/bin/bash

function wpImport(){
  wp acf clean
  wp acf import --all
}


function wpExport(){
  rm -rf acf
  wp acf export --all
}

function getGroupsLabels(){
  local file_path=$1
  local labels=()
  # read each item in the JSON array to an item in the Bash array
  readarray -t my_array < <(jq --compact-output '.[0].fields[]' $file_path)

  for item in "${my_array[@]}"; do
    local label=$(jq --raw-output '.label' <<< "$item")
    local type=$(jq --raw-output '.type' <<< "$item")
    if [ $type == "group" ]; then
      labels+=($label)
    fi
  done
  echo "${labels[@]}"
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
    read -p "Enter type of the field" field_type
    # check if field type is empty
    if [ -z "$field_type" ]; then
      field_type="text"
    fi
    read -p "Enter width, by default is 100: " width
    local result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields[.[0].fields['${group_index}'].sub_fields| length] += {
    "key": "'${id}'",
    "label": "'${field_name}'",
    "name": "'${name}'",
    "aria-label": "",
    "type": "'${field_type}'",
    "instructions": "",
    "required": 0,
    "conditional_logic": 0,
    "wrapper": {
    "width": "'${width}'",
    "class": "",
    "id": ""
  },
  "default_value": "",
  "maxlength": "",
  "placeholder": "",
  "prepend": "",
  "append": "",
  "return_format": "'${field_type}'",
}')
echo $result > $file_path
done
}
