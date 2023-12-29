#!/bin/bash

source /home/serii/Documents/bash-wp/functions/acf-functions.sh

file_path=$(fzf)

select action in "Add" "Remove" "Edit" "Exit"
do
  case $action in
    Add)
      select type in "Group" "Field"
      do
        case $type in
          Group)
            read -p "Enter the name of the group: " group_name
            newGroup "$group_name" "tab" $file_path
            newGroup "$group_name" "group" $file_path
            exit 0
            ;;
          Field)
            read -p "Enter the name of the field: " field_name
            newGroup $field_name "field" $file_path
            exit 0
            ;;
        esac
      done
      ;;
    Remove)
      removeGroup $file_path
      ;;
    Edit)
      echo "Edit"
      ;;
    Exit)
      echo "Exit"
      break
      ;;
  esac
done
