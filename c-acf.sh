#!/bin/bash

source /home/serii/Documents/bash-wp/functions/acf-functions.sh

file_path=$(fzf)

select action in "Show" "Add" "Remove" "Edit" "Exit"
do
  case $action in
    Show)
      showFields $file_path
      ;;
    Add)
      select type in "Group" "Field"
      do
        case $type in
          Group)
            read -p "Enter the name of the group: " group_name
            newGroup "$group_name" "tab" $file_path
            newGroup "$group_name" "group" $file_path
            ;;
          Field)
            addSubField $file_path
            ;;
        esac
      done
      ;;
    Remove)
      showFields $file_path
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
