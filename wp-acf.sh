#!/bin/bash
# https://salferrarello.com/wp-cli-local-by-flywheel-without-ssh/
has_wp=$(which wp)
if [ -z "$has_wp" ]; then
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp
fi

if [[ ! -f front-page.php ]]; then
  echo "${tmagenta}Go to wp theme folder${treset}"
  exit 1
fi

theme_url=$(pwd)

if [[ ! -f .mysql_sock ]]
then
  echo "${tmagenta}Go to localwp app in tab Database and copy the socket path${treset}"
  echo "${tgreen}Create a file .mysql_sock and paste the path${treset}"
  exit 1
fi

cat .mysql_sock | xclip -selection clipboard

cd ../../../../../

echo "$(pwd)"

if [[ ! -f .localwp-cli.yml ]]
then
  rm wp-cli.local*
  echo "${tblue}need to enter mysql code from clipboard${treset}"
  curl -O https://raw.githubusercontent.com/salcode/wpcli-localwp-setup/main/wpcli-localwp-setup  && bash wpcli-localwp-setup && rm -rf ./wpcli-localwp-setup
fi


cd app/public/wp-content/plugins

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

cd "$theme_url"


if ! grep -Fq "acfwpcli_fieldgroup_paths" functions.php
then
  echo "${tgreen}Added filter to functions.php at the end${treset}"

  cat <<TEST >> "functions.php"
add_filter( 'acfwpcli_fieldgroup_paths', 'add_plugin_path' );
function add_plugin_path( \$paths ) {
    \$paths['my_plugin'] = get_template_directory() . '/acf/';
    return \$paths;
  }
TEST
fi

wp acf
if [ $? -eq 0 ]; then
    echo OK
else
  read -p "${tmagenta}Get mysql sock path from localwp app and paste here: ${treset}" mysql_sock
  echo $mysql_sock > "$theme_url/.mysql_sock"
  echo "${tgreen}Success!${treset}"
fi

