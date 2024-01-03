#!/bin/bash

source /home/serii/Documents/bash-wp/functions/acf-functions.sh

if [ ! -f "front-page.php" ]
then
  echo "${tmagenta}front-page.php not found, it's not a wordpress template${treset}"
  exit 1
fi

file_path=acf/page-home.json
getFilePath $file_path
# file_path=$(fzf)

if [[ "$file_path" != *"json"* ]]; then
  echo "${tmagenta}File is not json${treset}"
  exit 1
fi

COLUMNS=1
select action in "${tblue}ShowGroups${treset}" "${tblue}EditGroup${treset}" "${tblue}AddGroup${treset}" "${tgreen}ShowFields${treset}" "${tgreen}EditField${treset}" "${tgreen}AddField${treset}" "Remove" "Edit" "Save" "Exit"
do
  case $action in
    "${tblue}ShowGroups${treset}")
      showFields $file_path
      ;;
    "${tblue}EditGroup${treset}")
      editGroup $file_path
      ;;
    "${tblue}AddGroup${treset}")
      read -p "Enter the name of the group: " group_name
      newGroup "$group_name" "tab" $file_path
      newGroup "$group_name" "group" $file_path
      ;;
    "${tgreen}ShowFields${treset}")
      showSubFields $file_path
      ;;
    "${tgreen}AddField${treset}")
      addSubField $file_path
      ;;
    "${tgreen}EditField${treset}")
      editSubField $file_path
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
