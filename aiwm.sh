#! /bin/bash

# check if don't exists file front-page.php
if [ ! -f "front-page.php" ]; then
  echo "${tmagenta}File front-page.php not found!${treset}"
  exit 1
fi 

function listBackup(){
  wp ai1wm list-backups
}

function restoreBackup(){
  listBackup

  cd ../../ai1wm-backups

  backup_files=$(ls -t | grep '\.wpress')

  PS3='Please enter your choice: '
  select backup_file in $backup_files
  do
    wp ai1wm restore $backup_file
    wp rewrite flush
    exit 0
  done
}

function makeBackup(){
  cd ../../ai1wm-backups

  current_files=$(ls | grep '\.wpress')
  echo "Current files: $current_files"
  wp ai1wm backup
  last_file=$(ls -t | head -n1)
  cp $last_file /home/serii/Downloads
  echo "${tgreen}Backup created!${treset}"
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
  wp rewrite flush
}

select choice in  "List" "Make Backup" "Download Backup" "Restore Backup" "Exit"; do
  case $choice in
    "List" ) listBackup;;
    "Make Backup" ) makeBackup;;
    "Download Backup" ) downloadBackup;;
    "Restore Backup" ) restoreBackup;;
    "Exit" ) exit;;
  esac
done
