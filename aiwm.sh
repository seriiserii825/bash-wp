#! /bin/bash

# check if don't exists file front-page.php
if [ ! -f "front-page.php" ]; then
    echo "File front-page.php not found!"
    exit 1
fi 


function makeBackup(){
  cd ../../ai1wm-backups

  current_files=$(ls | grep '\.wpress')
  echo "Current files: $current_files"
  wp ai1wm backup
  last_file=$(ls -t | head -n1)
  cp $last_file /home/serii/Downloads
  echo "${tgreen}Backup created!${treset}"
  exit 0
}

function downloadBackup(){
  read -p "Enter domain url: " domain_url
  if [ -z "$domain_url" ]; then
    echo "Domain url is empty!"
    exit 1
  fi

  read -p "Enter backup file name: " backup_file
  if [ -z "$backup_file" ]; then
    echo "Backup file name is empty!"
    exit 1
  fi

  cd ../../ai1wm-backups
  wget "$domain_url/wp-content/ai1wm-backups/$backup_file"
  wp ai1wm restore $backup_file
  exit 0
}

select choice in "Make Backup" "Download Backup" "Exit"; do
  case $choice in
    "Make Backup" ) makeBackup;;
    "Download Backup" ) downloadBackup;;
    "Exit" ) exit;;
  esac
done
