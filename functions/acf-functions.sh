#!/bin/bash

function wpImport(){
  wp acf clean
  wp acf import --all
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

function showFields(){
  local file_path=$1
  my_array=($(getGroupsLabels $file_path))
  for label in "${my_array[@]}"; do
    echo "${tgreen}$label${treset}"
  done
}

function showSubFields(){
  local file_path=$1
  labels=($(getGroupsLabels $file_path))
  for label in "${labels[@]}"; do
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${label}'" and .type == "group") | .key' $file_path)
    local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
    readarray -t sub_fields < <(jq --compact-output '.[0].fields['${group_index}'].sub_fields[]' $file_path)

    echo "${tblue}$label${treset}"
    for item in "${sub_fields[@]}"; do
      local sub_label=$(jq --raw-output '.label' <<< "$item")
      local sub_type=$(jq --raw-output '.type' <<< "$item")
      local sub_width=$(jq --raw-output '.wrapper.width' <<< "$item")
      if [[ $sub_width == '' ]]; then
        echo "${tgreen}$sub_label: $sub_type${treset}"
      else
        echo "${tgreen}$sub_label: $sub_type${treset} ${tyellow}($sub_width)${treset}"
      fi
    done
  done
}

function editGroup(){
  local file_path=$1
  labels=($(getGroupsLabels $file_path))

  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
    read -p "Enter the name of the group: " group_name
    if [[ $group_name == '' ]]; then
      group_name=$elem
    fi
    local result=$(cat $file_path | jq '.[0].fields['${group_index}'].label = "'${group_name}'"')
    echo $result > $file_path

    local key_tab=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "tab") | .key' $file_path)
    local tab_index=$(jq '.[0].fields | map(.key) | index("'${key_tab}'")' $file_path)
    local result_tab=$(cat $file_path | jq '.[0].fields['${tab_index}'].label = "'${group_name}'"')
    echo $result_tab > $file_path

    local slug=$(echo $group_name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    local slug_result=$(cat $file_path | jq '.[0].fields['${group_index}'].name = "'${slug}'"')
    echo $slug_result > $file_path
    wpImport
    break
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
    "label": "'${name}'",
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
  wpImport
}

function removeGroup(){
  local file_path=$1
  local labels=($(getGroupsLabels $file_path))

  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    local key_tab=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "tab") | .key' $file_path)
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local result_tab=$(cat $file_path | jq 'del(.[0].fields[] | select(.key == "'${key_tab}'"))')
    echo $result_tab > $file_path
    local result_group=$(cat $file_path | jq 'del(.[0].fields[] | select(.key == "'${key_group}'"))')
    echo $result_group > $file_path
    wpImport
    break
  done
}

function addSubField(){
  local file_path=$1
  local id="field_$(openssl rand -base64 12)"
  local labels=($(getGroupsLabels $file_path))
  echo "${tblue}Select group:${treset}"
  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    read -p "Enter the name of the field: " field_label
    local fiedl_name=$(echo $field_label | tr ' ' '_')
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
    echo "${tmagenta}Select the type of the field${treset}"
    select type in "text" "image" "wysiwyg" "textarea" "gallery" "repeater"; do
      [[ $type ]] || continue
      break
    done
    echo "${tblue}Select width of field:${treset}"
    echo "${tmagenta}Choose the width of the field${treset}"
    select width in "100" "50" "33" "25" "20"; do
      [[ $width ]] || continue
      break
    done
    if [[ $type == 'image' || $type == 'gallery' ]]; then
      local result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields[.[0].fields['${group_index}'].sub_fields| length] += {
      "key": "'${id}'",
      "label": "'${field_label}'",
      "name": "'${field_name}'",
      "aria-label": "",
      "type": "'${type}'",
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
    "return_format": "url",
  }')
  echo $result > $file_path
elif [[ $type == 'wysiwyg' ]]; then
  local result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields[.[0].fields['${group_index}'].sub_fields| length] += {
  "key": "'${id}'",
  "label": "'${field_label}'",
  "name": "'${field_name}'",
  "aria-label": "",
  "type": "'${type}'",
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
"toolbar": "basic",
"media_upload": 0
}')
echo $result > $file_path
elif [[ $type == 'repeater' ]]; then
  local result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields[.[0].fields['${group_index}'].sub_fields| length] += {
    "key": "'${id}'",
    "label": "'${field_label}'",
    "name": "'${field_name}'",
    "aria-label": "",
    "type": "'${type}'",
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
    "layout": "table",
    "button_label": "Add Row",
    "sub_fields": []
  }')
echo $result > $file_path
else
  local result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields[.[0].fields['${group_index}'].sub_fields| length] += {
  "key": "'${id}'",
  "label": "'${field_label}'",
  "name": "'${field_name}'",
  "aria-label": "",
  "type": "'${type}'",
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
"append": ""
}')
echo $result > $file_path
fi
wpImport
break
done
}

function editSubField() {
  local file_path=$1
  local labels=($(getGroupsLabels $file_path))
  echo "${tblue}Select group:${treset}"
  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
    local sub_fields=$(jq --compact-output '.[0].fields['${group_index}'].sub_fields[]' $file_path)
    local sub_fields_labels=()
    for item in "${sub_fields[@]}"; do
      local sub_label=$(jq --raw-output '.label' <<< "$item")
      sub_fields_labels+=($sub_label)
    done
    echo "${tyellow}Select field:${treset}"
    COLUMNS=1
    select field in "${sub_fields_labels[@]}"; do 
      [[ $field ]] || continue
      echo "${tmagenta}Leave empty if you don't want to change the name of the field${treset}"
      read -p "Enter the name of the field: " field_label
      if [[ $field_label == '' ]]; then
        field_label=$field
      fi
      local field_name=$(echo $field_label | tr ' ' '_')
      local key_field=$(jq -r '.[0].fields['${group_index}'].sub_fields[] | select(.label == "'${field}'") | .key' $file_path)
      local field_index=$(jq '.[0].fields['${group_index}'].sub_fields | map(.key) | index("'${key_field}'")' $file_path)
      local label_result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields['${field_index}'].label = "'${field_label}'"')
      echo $label_result > $file_path
      local name_result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields['${field_index}'].name = "'${field_name}'"')
      echo $name_result > $file_path
      echo "${tblue}Select type of field:${treset}"
      echo "${tmagenta}Choose exit if you don't want to change the type of the field${treset}"
      select type in "text" "image" "wysiwyg" "textarea" "gallery" "exit"; do
        [[ $type ]] || continue
        if [[ $type == 'exit' ]]; then
          break
        fi
        local type_result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields['${field_index}'].type = "'${type}'"')
        echo $type_result > $file_path
        if [[ $type == 'image' || $type == 'gallery' ]]; then
          local return_format_result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields['${field_index}'].return_format = "url"')
          echo $return_format_result > $file_path
        fi
        if [[ $type == 'wysiwyg' ]]; then
          local toolbar_result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields['${field_index}'].toolbar = "basic"')
          echo $toolbar_result > $file_path
          local media_upload_result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields['${field_index}'].media_upload = 0')
          echo $media_upload_result > $file_path
        fi
        break
      done
      echo "${tblue}Select width of field:${treset}"
      echo "${tmagenta}Choose exit if you don't want to change the width of the field${treset}"
      select width in "100" "50" "33" "25" "20" "exit"; do
        [[ $width ]] || continue
        if [[ $width == 'exit' ]]; then
          break
        fi
        local width_result=$(cat $file_path | jq '.[0].fields['${group_index}'].sub_fields['${field_index}'].wrapper.width = "'${width}'"')
        echo $width_result > $file_path
        break
      done
      break
    done
    wpImport
    break
  done
}


function removeField(){
  local file_path=$1
  local labels=($(getGroupsLabels $file_path))
  echo "${tblue}Select group:${treset}"
  COLUMNS=1
  select elem in "${labels[@]}"; do 
    [[ $elem ]] || continue
    local key_group=$(jq -r '.[0].fields[] | select(.label == "'${elem}'" and .type == "group") | .key' $file_path)
    local group_index=$(jq '.[0].fields | map(.key) | index("'${key_group}'")' $file_path)
    local sub_fields=$(jq --compact-output '.[0].fields['${group_index}'].sub_fields[]' $file_path)
    local sub_fields_labels=()
    for item in "${sub_fields[@]}"; do
      local sub_label=$(jq --raw-output '.label' <<< "$item")
      sub_fields_labels+=($sub_label)
    done
    echo "${tyellow}Select field:${treset}"
    COLUMNS=1
    select field in "${sub_fields_labels[@]}"; do 
      [[ $field ]] || continue
      local key_field=$(jq -r '.[0].fields['${group_index}'].sub_fields[] | select(.label == "'${field}'") | .key' $file_path)
      local field_index=$(jq '.[0].fields['${group_index}'].sub_fields | map(.key) | index("'${key_field}'")' $file_path)
      local result=$(cat $file_path | jq 'del(.[0].fields['${group_index}'].sub_fields['${field_index}'])')
      echo $result > $file_path
      wpImport
      break
    done
    break
  done
}
