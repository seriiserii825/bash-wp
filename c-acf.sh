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
select action in "${tyellow}ShowGroups${treset}" "${tblue}EditGroup${treset}" "${tgreen}AddGroup${treset}" "${tmagenta}RemoveGroup${treset}"  "${tyellow}ShowFields${treset}" "${tblue}EditField${treset}" "${tgreen}AddField${treset}" "${tmagenta}RemoveField${treset}" "${tmagenta}Exit${treset}"
do
  case $action in
    "${tyellow}ShowGroups${treset}")
      showFields $file_path
      ;;
    "${tblue}EditGroup${treset}")
      editGroup $file_path
      ;;
    "${tgreen}AddGroup${treset}")
      read -p "Enter the name of the group: " group_name
      newGroup "$group_name" "tab" $file_path
      newGroup "$group_name" "group" $file_path
      ;;
    "${tmagenta}RemoveGroup${treset}")
      removeGroup $file_path
      ;;
    "${tyellow}ShowFields${treset}")
      showSubFields $file_path
      ;;
    "${tblue}EditField${treset}")
      editSubField $file_path
      ;;
    "${tgreen}AddField${treset}")
      addSubField $file_path
      ;;
    "${tmagenta}RemoveField${treset}")
      echo "remove field"
      ;;
    "${tmagenta}Exit${treset}")
      echo "Exit"
      break
      ;;
  esac
done
