#!/usr/bin/env bash
# WordPress Vagrant config
# Packages installed:  mysql 5.5, php5 with mysql drivers, apache2, git

# Unlock the root and give it a password? (YES/NO)
ROOT=YES

# Add vhosts
sudo cp -Rv /vagrant/vhosts/* /etc/apache2/sites-available/

avail=/etc/apache2/sites-available/$1.conf
enabled=/etc/apache2/sites-enabled/
site=`ls /vagrant/vhosts/`

if [ "$#" != "1" ]; then
    echo "Available virtual hosts: $site"
    sudo a2ensite $site
else

    if test -e $avail; then
        sudo ln -s $avail $enabled
    else
         "$avail virtual host does not exist! Please create one!$site"
    fi
fi

echo "Booting the machine..."
sudo service apache2 restart

if [ ! -f /var/log/firsttime ];
then
	sudo touch /var/log/firsttime

    # Set credentials for MySQL
	sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password vagrant"
	sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password vagrant"

    # Install packages
	sudo apt-get update
	sudo apt-get -y install mysql-server-5.5 php5-mysql apache2 git libapache2-mod-php5 php5-curl

    # Install WordPress specific recommendations
    sudo apt-get -y install php5-cli php5-dev php5-fpm php5-cgi php5-mysql php5-xmlrpc php5-curl php5-gd php5-imagick php-apc php-pear php5-imap php5-mcrypt php5-pspell

    # Create WordPress database
    # sudo mysql -uroot -p$DB_PASSWORD -e "CREATE DATABASE $DB_NAME"

    # Add timezones to database
    mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -uroot -pvagrant mysql

    # Download WordPress
    # sudo git clone https://github.com/WordPress/WordPress.git -b $REPO /home/vagrant/shared/wordpress
    
    # Create wp-config.php
    # sudo mv /home/vagrant/shared/wordpress/wp-config-sample.php /home/vagrant/shared/wordpress/wp-config.php
    # sudo sed -i "s/database_name_here/$DB_NAME/" /home/vagrant/shared/wordpress/wp-config.php
    # sudo sed -i "s/username_here/root/" /home/vagrant/shared/wordpress/wp-config.php
    # sudo sed -i "s/password_here/$DB_PASSWORD/" /home/vagrant/shared/wordpress/wp-config.php    

    # Allow URL rewrites
    sudo a2enmod rewrite
    sudo sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default

    # php5-mysql comes w/mysql drivers, but we still have to update php.ini to use them.
    sudo sed -i 's/;pdo_odbc.db2_instance_name/;pdo_odbc.db2_instance_name\nextension=pdo_mysql.so/' /etc/php5/apache2/php.ini
	
    # Install curl & wp-cli
    sudo apt-get -y install curl
    # cd ~/ && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    # sudo mv wp-cli.phar /usr/bin/wp && sudo chmod +x /usr/bin/wp

    # Restart machine, obviously
    sudo service apache2 restart
fi

# Unlock root and set password	
if [ $ROOT = 'YES' ]
then
	sudo usermod -U root
	echo -e "password\npassword" | sudo passwd root
fi