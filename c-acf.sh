#!/bin/bash

source /home/serii/Documents/bash-wp/functions/acf-functions.sh

if [ ! -f "front-page.php" ]
then
  echo "${tmagenta}front-page.php not found, it's not a wordpress template${treset}"
  exit 1
fi

file_path=acf/page-home.json
# file_path=$(fzf)

if [[ "$file_path" != *"json"* ]]; then
  echo "${tmagenta}File is not json${treset}"
  exit 1
fi

COLUMNS=1
select action in "ShowGroups" "EditGroup" "AddGroup" "ShowSubfields" "AddField" "Remove" "Edit" "Save" "Exit"
do
  case $action in
    ShowGroups)
      showFields $file_path
      ;;
    EditGroup)
      editGroup $file_path
      ;;
    AddGroup)
      read -p "Enter the name of the group: " group_name
      newGroup "$group_name" "tab" $file_path
      newGroup "$group_name" "group" $file_path
      ;;
    ShowSubfields)
      showSubFields $file_path
      ;;
    AddField)
      addSubField $file_path
      ;;
    Remove)
      showFields $file_path
      removeGroup $file_path
      ;;
    Edit)
      echo "Edit"
      ;;
    Save)
      wpImport
      break
      ;;
    Exit)
      echo "Exit"
      break
      ;;
  esac
done
