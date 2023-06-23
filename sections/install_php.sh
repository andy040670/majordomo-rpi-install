#!/bin/bash

showMessage "Installing PHP..."
if checkOS "Ubuntu 22"; then
 showMessage "Ubuntu 22, trying to use another repository for PHP."
 runSudo "apt-get install -y software-properties-common"
 runSudo "add-apt-repository -y ppa:ondrej/php"
 runSudo "apt update -y"
 runSudo "apt-get install -y php7.4"
else
 runSudo "apt-get install -y php"
fi

PHPVERSION=$(ls -Art1 /etc/php | tail -n 1)

showMessage "PHP version installed: $PHPVERSION"
runSudo "apt-get install -y libapache2-mod-php$PHPVERSION"
runSudo "apt-get install -y php$PHPVERSION-mysql"
runSudo "apt-get install -y php$PHPVERSION-common"
runSudo "apt-get install -y php$PHPVERSION-json"
runSudo "apt-get install -y php$PHPVERSION-opcache"
runSudo "apt-get install -y php$PHPVERSION-readline"
runSudo "apt-get install -y php$PHPVERSION-bz2"
runSudo "apt-get install -y php$PHPVERSION-cli"
runSudo "apt-get install -y php$PHPVERSION-curl"
runSudo "apt-get install -y php$PHPVERSION-gd"
runSudo "apt-get install -y php$PHPVERSION-mbstring"
runSudo "apt-get install -y php$PHPVERSION-xml"
runSudo "apt-get install -y php$PHPVERSION-dev"
runSudo "apt-get install -y php$PHPVERSION-bcmath"
#sudo apt-get install -y php$PHPVERSION-mcrypt"
runSudo "apt-get install -y php$PHPVERSION-zip"
runSudo "apt-get install -y php$PHPVERSION-redis"

runSudo 'echo "<?php phpinfo(); ?>">/var/www/php.php'
runSudo 'chown www-data:www-data /var/www/php.php'

# Update php.ini config
runSudo "sed -i '/post_max_size/s/8/200/' /etc/php/$PHPVERSION/apache2/php.ini"
runSudo "sed -i '/upload_max_filesize/s/2/100/' /etc/php/$PHPVERSION/apache2/php.ini"
runSudo "sed -i '/max_file_uploads/s/20/150/' /etc/php/$PHPVERSION/apache2/php.ini"

replaceString "/etc/php/$PHPVERSION/apache2/php.ini" "display_errors = Off" "display_errors = On"
replaceString "/etc/php/$PHPVERSION/apache2/php.ini" "error_reporting = E_ALL \& \~E_DEPRECATED" "error_reporting = E_ALL \& \~E_NOTICE \& \~E_DEPRECATED"

replaceString "/etc/php/$PHPVERSION/cli/php.ini" "display_errors = Off" "display_errors = On"
replaceString "/etc/php/$PHPVERSION/cli/php.ini" "error_reporting = E_ALL \& \~E_DEPRECATED" "error_reporting = E_ALL \& \~E_NOTICE \& \~E_DEPRECATED"

runSudo "service apache2 restart"

showMessage "PHP installed."
