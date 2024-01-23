#! /bin/bash
if [ ! -f "front-page.php" ]
  then
  echo "${terror}front-page.php not found, it's not a wordpress template${treset}"
  exit 1
fi

select action in "Show pages" "Exit"
do
  case $action in 
    "Show pages")
      wp post list --post_type=page
      echo "show pages"
      ;;
    "Exit")
      exit 0
      ;;
  esac
done
