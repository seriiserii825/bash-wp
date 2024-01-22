#!/bin/bash

if [ ! -f "front-page.php" ]; then
  echo "front-page.php not found"
  exit 1
fi

read -p "Enter the page ID to ignore: " page_id

line=$(awk '/\$ids/{print NR; exit}' inc/func.php)

sed -i  "${line} s/];/,${page_id}];/" inc/func.php
