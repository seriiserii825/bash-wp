#!/bin/bash

if [ ! -f "front-page.php" ]
then
  echo "This script must be run from the root of the theme"
  exit 1
fi

if [ ! -d "acf" ]
then
  mkdir acf
fi
cd acf

source /home/serii/Documents/bash-wp/functions/acf-functions.sh

wp acf export --all

file_path=$(fzf)

anew=yes
while [ "$anew" = yes ]; do
  anew=no
  select action in "Show" "Add" "Remove" "Edit" "Exit"
  do
    case $action in
      Show)
        showFields $file_path
        anew=yes
        break
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
        anew=yes
        break
        ;;
      Remove)
        showFields $file_path
        removeGroup $file_path
        anew=yes
        break
        ;;
      Edit)
        echo "Edit"
        ;;
      Exit)
        echo "Exit"
        anew=yes
        break
        ;;
    esac
  done
done

