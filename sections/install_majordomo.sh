#!/bin/bash

showMessage "Installing MajorDoMo..."

# BASIC INSTALL

#majordomo_branch
if [ $majordomo_branch == "a" ]; then
  #download alpha
  showMessage "Downloading ALPHA branch."
  wget https://github.com/sergejey/majordomo/archive/refs/heads/alpha.zip
  runSudo "unzip alpha.zip -d /var/www/"
  runSudo "mv -f /var/www/majordomo-alpha/* /var/www/"
  runSudo "mv -f /var/www/majordomo-alpha/.htaccess /var/www/"
  runSudo "rm -Rf /var/www/majordomo-alpha"
  rm alpha.zip
else
  #download master
  showMessage "Downloading MASTER branch."
  wget https://github.com/sergejey/majordomo/archive/refs/heads/master.zip
  runSudo "unzip master.zip -d /var/www/"
  runSudo "mv -f /var/www/majordomo-master/* /var/www/"
  runSudo "mv -f /var/www/majordomo-master/.htaccess /var/www/"
  runSudo "rm -Rf /var/www/majordomo-master"
  rm master.zip
fi

showMessage "Changing files ownership."
runSudo "chown -Rf www-data:www-data /var/www"
showMessage "Removing index.html."
runSudo "rm /var/www/index.html"
showMessage "Updating file attributes."
runSudo "find /var/www/ -type f -exec chmod 0666 {} \;"
showMessage "Updating dirs attributes."
runSudo "find /var/www/ -type d -exec chmod 0777 {} \;"


showMessage "Updating config file."
runSudo "mv /var/www/config.php.sample /var/www/config.php"
#replaceString "/var/www/config.php" "'DB_PASSWORD', ''" "'DB_PASSWORD', '$db_root'"
sudo sed -i "s/'DB_PASSWORD', ''/'DB_PASSWORD', '$db_root'/" /var/www/config.php
#replaceString "/var/www/config.php" "'\/var\/www'" "'\/var\/www'"
sudo sed -i "s/'\/var\/www'/'\/var\/www'/" /var/www/html/config.php

# DATABASE
showMessage "Installing MajorDoMo database."
mysql -u root -p$db_root << EOF
CREATE DATABASE db_terminal CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

mysql -u root -p$db_root db_terminal<./resources/initial_db.sql

# SERVICE
showMessage "Installing MajorDoMo service."
runSudo "cp ./resources/service_script.sh /etc/init.d/majordomo"
runSudo "chmod 0755 /etc/init.d/majordomo"
runSudo "update-rc.d majordomo defaults"
runSudo "service majordomo start"

# runSudo "(Warning!!!)
sudo sh -c 'echo "www-data ALL=(ALL) NOPASSWD: ALL">/etc/sudoers.d/010_www-data-nopasswd'

# Allow audio for www-data
sudo usermod -aG audio www-data

# UPDATE ALL MODULES
showMessage "Updating MajorDoMo modules..."
wget -q http://localhost/modules/market/update_iframe.php?mode2=update_all

# Log rotate
runSudo "cp ./resources/logrotate_majordomo /etc/logrotate.d/majordomo"

showMessage "MajorDoMo installed."
