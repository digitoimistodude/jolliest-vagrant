# Jolliest vagrant

This story won't be short. 

**tl;dr;** This is a simple vagrant server with minimal provisioning, originally created for local development environment for multiple WordPress projects.

So... I created already two vagrant-repositories before this one. Started to modify them to my needs and noticed that commit after commit I got more and more stuck with stuff I didn't need or wasn't patient enough to learn how to configure thoroughly. So ended up removing those repositories and learn everything from scratch. There are too many vagrant setups and I have probably tried most of them.

Chef and puppet are crazy by their configurations and learning curve. Managed to handle them but after all I'm more of a bash guy, so naturally this version of my vagrant setup will use only simple bash script. Keep it simple, stupid.

Tried  to make up distinctive name for this and noticed *server for multiple projects* anagrams to *scrump of jolliest perverter*. That's why this is the **jolliest vagrant** ever.

## Recommendations

1. Mac OS X
2. Simple knowledge of web servers
3. WordPress projects under the same folder
4. [wpstack-rolle](https://github.com/ronilaukkarinen/wpstack-rolle) in use

## What's inside?

- Vagrantfile with speed optimizations, nfs mounts, 4 GB of RAM, 2 CPU cores
- Ubuntu 12.04.5 LTS (Precise Pangolin)
- MySQL 5.5
- PHP 5.3.10 with mod_rewrite

## Installation

1. Install [Virtualbox](https://www.virtualbox.org/)
2. Install vagrant (`brew install vagrant` on OS X powered by [Homebrew](http://brew.sh/))
3. Clone this repo to your home directory
4. Modify **Vagrantfile**: `config.vm.box` and `config.vm.box_url` to match your production server OS, `config.vm.network` for IP (I recommend it to be `10.1.2.3` to prevent collisions with other subnets)
5. If you store your projects in different folder than *~/Projects*, change the correct path to `config.vm.synced_folder`
6. Edit or add packages to match your production server packages in **provision.sh** if needed
7. Add `10.1.2.3 somesite.dev` to your **/etc/hosts**
8. Run `vagrant up`. This can take a moment.

If you make any changes to **Vagrantfile**, run `vagrant reload` or `vagrant up --provision` if the server is not running, or if you change **provision.sh** while running, run `vagrant provision`.

## Post-installations

Since I want to make this as simple as possible and this will be the single VM for multiple projects that does not need to change much over time, I want extra stuff to be installed manually.

1. SSH to your vagrant box by `vagrant ssh`
2. You may want to remove the default "It works!" -page. Do this by `rm /var/www/index.html`
3. `cd /var/www/` and `ls`. You should see all your projects and a directory listing when you go to localhost with your browser

#### 1. Installing FastCGI

Another speed improving trick is to use FastCGI as Server API instead of the default Apache Handler. This is based on [HowtoForge's article](http://www.howtoforge.com/using-php5-fpm-with-apache2-on-ubuntu-12.04-lts):

1. `sudo apt-get -y install apache2-mpm-worker libapache2-mod-fastcgi php5-fpm php5`
2. `sudo a2enmod actions fastcgi alias`
3. `service apache2 restart`
4. `sudo pico -w /etc/apache2/conf.d/php5-fpm.conf`

        <IfModule mod_fastcgi.c>
            AddHandler php5-fcgi .php
            Action php5-fcgi /php5-fcgi
            Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
            FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host 127.0.0.1:9000 -pass-header Authorization
        </IfModule>
5. `sudo service apache2 restart`
6. `sudo echo "<?php phpinfo();" > /var/www/info.php`
7. Now you should see *FPM/FastCGI* in the third row "Server API" when you go to [localhost/info.php](http://localhost/info.php)

#### 2. Installing Alternative PHP cache

Alternative PHP cache speeds up PHP processing. This tutorial is based on [Digital Ocean's article](https://www.digitalocean.com/community/tutorials/how-to-install-alternative-php-cache-apc-on-a-cloud-server-running-ubuntu-12-04):

1. `sudo apt-get -y install php-pear php5-dev make libpcre3-dev`
2. `sudo pecl install apc`, choose or press return when asked
3. `sudo pico -w /etc/php5/fpm/php.ini` (normally */etc/php5/apache2/php.ini*, but we are using fpm), scroll all the way down and add to the last line:

        extension = apc.so
        apc.shm_size = 64
        apc.stat = 0

4. `sudo cp /usr/share/php/apc.php /var/www` and `sudo service apache2 restart  && sudo service php5-fpm restart`
5. You should now see APC info when you go to [localhost/apc.php](http://localhost/apc.php) with your browser

#### 3. More speed with configs

I have attached **confs** folder which includes custom *my.cnf* and *php.ini* for you to tweak on. After customizing them further just ssh to vagrant and `sudo cp /vagrant/confs/my.cnf /etc/mysql/my.cnf` and `sudo cp /vagrant/confs/php.ini /etc/php5/fpm/php.ini`. Then run proper restarts `sudo service apache2 restart  && sudo service php5-fpm restart && sudo service mysql restart`

### How to add new vhost

It's simple to manage multiple projects with apache's sites-enabled configs. If your project name is `jolly`, and located in *~/Projects/jolly*, just add new config to vhosts. *vhosts/jolly.dev.conf* would then be:

    <VirtualHost *:80>
    
      ServerAdmin webmaster@jolly
      ServerName  jolly.dev
      ServerAlias www.jolly.dev
      DirectoryIndex index.html index.php
      DocumentRoot /var/www/jolly
      LogLevel warn
      ErrorLog  /var/www/jolly/error.log
      CustomLog /var/www/jolly/access.log combined
    
    </VirtualHost>

Run `vagrant provision` and boom! http://jolly.dev points to your project file.

## Sequel Pro settings for MySQL

Choose **SSH** tab and add following settings.

| Setting | Input field |
|---|---|
| Name: | vagrant mysql |
| MySQL Host: | 127.0.0.1 |
| Username: | root |
| Password: | vagrant |
| Database: | *optional* |
| Port: | 3306 |
| SSH Host: | 10.1.2.3 |
| SSH User: | vagrant |
| SSH Password: | vagrant |
| SSH Port: | 22 |