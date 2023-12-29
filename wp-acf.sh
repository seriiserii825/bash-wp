#!/bin/bash

if [[ ! -f front-page.php ]]; then
  echo "${tmagenta}Go to wp theme folder${treset}"
  exit 1
fi

theme_url=$(pwd)

clipboard=$(xclip -o -selection clipboard)

# check if clipboard has string
if [[ $clipboard != *"mysqld.sock"* ]]; then
  echo "${tmagenta}mysqld.sock not found in clipboard${treset}"
  echo "${tgreen}Go to localwp app in tab Database and copy the socket path${treset}"
  exit 1
fi

echo "${tgreen}mysqld.sock found in clipboard${treset}"

cd ../../../../../

echo "$(pwd)"

rm wp-cli.local*

curl -O https://raw.githubusercontent.com/salcode/wpcli-localwp-setup/main/wpcli-localwp-setup  && bash wpcli-localwp-setup && rm -rf ./wpcli-localwp-setup

cd app/public/wp-content/plugins

echo "$(pwd)"

# check if exists directory advanced-custom-fields-wpcli
if [[ ! -d advanced-custom-fields-wpcli ]]; then
echo "${tgreen}Installing ACF plugin${treset}"
  git clone https://github.com/hoppinger/advanced-custom-fields-wpcli.git
  echo "${tgreen}Activating ACF plugin${treset}"
  wp plugin activate advanced-custom-fields-wpcli
else
  echo "${tgreen}ACF plugin already installed${treset}"
fi


echo "${tgreen}Go to theme folder${treset}"

cd $theme_url

echo "${tgreen}Added filter to functions.php at the end${treset}"


cat <<TEST >> "functions.php"
add_filter( 'acfwpcli_fieldgroup_paths', 'add_plugin_path' );
function add_plugin_path( \$paths ) {
    \$paths['my_plugin'] = get_template_directory() . '/acf/';
    return \$paths;
  }
TEST

bat functions.php

wp acf

