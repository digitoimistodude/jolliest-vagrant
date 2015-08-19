# Jolliest vagrant

**tl;dr;** This is a simple vagrant server with minimal provisioning, originally created for local development environment for multiple WordPress projects.

This vagrant server can be used as plain local server for serving your files or testing static PHP, but it's also perfect for WordPress development.

Currently tested on Linux and Mac OS X.

## Background

I tried about 30 vagrant setups before this box. I created already two vagrant-repositories before this one. Started to modify them to my needs and noticed that commit after commit I got more and more stuck with stuff I didn't need or wasn't patient enough to learn how to configure thoroughly.

After bashing my head to the wall enough, ended up removing those repositories and learn everything from scratch. There are too many vagrant setups and I have probably tried most of them.

Chef and puppet are crazy by their configurations and learning curve. Managed to handle them but after all I'm more of a bash guy, so naturally this version of my vagrant setup will use only simple bash script. Keep it simple, stupid.

## The story behind the name

Tried  to make up distinctive name for this and noticed *server for multiple projects* anagrams to *scrump of jolliest perverter*. That's why this is the **jolliest vagrant** ever.

## Usage

To start this vagrant box, always run `vagrant up --provision`, with provision -hook to ensure all the stuff are loaded up properly. Skip to the [Installation](#installation), if you are ready to start.

## Table of contents

1. [Installation](#installation)
2. [Post-installations](#post-installations)
  1. [Installing FastCGI](#1-installing-fastcgi)
  2. [Installing Alternative PHP cache](#2-installing-alternative-php-cache)
  3. [More speed with configs](#3-more-speed-with-configs)
3. [How to add new vhost](#how-to-add-new-vhost)
4. [How to remove a project or vhost](#how-to-remove-a-project-or-vhost)
5. [Connecting with another computer in LAN](#connecting-with-another-computer-in-lan)
6. [Port forwarding (optional)](#port-forwarding-optional)
7. [SSL / HTTPS (optional)](#ssl--https-optional)
8. [Installing Phpmyadmin (optional)](#installing-phpmyadmin-optional)
9. [Sequel Pro settings for MySQL](#sequel-pro-settings-for-mysql)
10. [Troubleshooting and issues](#troubleshooting-and-issues)
  1. [Connection timeout](#connection-timeout)
  2. [Corrupted JS/CSS](#corrupted-jscss)
  3. [Other issues](#other-issues)

## Recommendations

1. Mac OS X or Linux
2. Simple knowledge of web servers
3. WordPress projects under the same folder
4. [dudestack](https://github.com/ronilaukkarinen/dudestack) in use

## What's inside?

- Vagrantfile with speed optimizations, nfs mounts, 2 GB of RAM, 2 CPU cores
- Ubuntu 12.04.5 LTS (Precise Pangolin)
- MySQL 5.5
- PHP 5.3.10 with mod_rewrite + modules recommended for optimal WordPress performance

## Installation

1. Install [Virtualbox](https://www.virtualbox.org/)
2. Install [vagrant](http://www.vagrantup.com) (**Mac OS X** [Homebrew](http://brew.sh/): `brew install vagrant`)
3. Install vagrant-triggers with command `vagrant plugin install vagrant-triggers`
4. Clone this repo to your Projects directory (path `~/Projects/jolliest-vagrant` is depedant in [dudestack](https://github.com/ronilaukkarinen/dudestack))
5. *(Optional, do this for example if you want to use other image or encounter problems with included Vagrantfile)* Modify **Vagrantfile**: `config.vm.box` and `config.vm.box_url` to match your production server OS, `config.vm.network` for IP (I recommend it to be `10.1.2.3` to prevent collisions with other subnets) (**For Linux** you need to remove `, :mount_options...` and you may not need config.trigger.after or part at all. Please remove parts that give you errors)
6. If you store your projects in different folder than *~/Projects*, change the correct path to `config.vm.synced_folder`
7. Edit or add packages to match your production server packages in **provision.sh** if needed
8. Add `10.1.2.3 somesite.dev` to your **/etc/hosts**
9. Run `vagrant up --provision`. This can take a moment.

If you make any changes to **Vagrantfile**, run `vagrant reload` or `vagrant up --provision` if the server is not running, or if you change **provision.sh** while running, run `vagrant provision`.

You can always see the apache status by `vagrant ssh`'ing to your vagrant box and typing `sudo service apache2 status`. If it's not started, run `sudo service apache2 start`.

## Post-installations

Since I want to make this as simple as possible and this will be the single VM for multiple projects that does not need to change much over time, I want extra stuff to be installed manually.

1. Make sure you are in your vagrant directory (`cd ~/Projects/jolliest-vagrant`) and SSH into your vagrant box by `vagrant ssh`
2. You may want to remove the default "It works!" -page. Do this by `rm /var/www/index.html`
3. If you want to check that everything is okay and the folders are linked successfully, you can go to public folder by `cd /var/www/` and `ls`, then you should see all your projects and a directory listing when you go to localhost with your browser.

#### 1. Installing FastCGI

Another speed improving trick is to use FastCGI as Server API instead of the default Apache Handler. This is based on [HowtoForge's article](http://www.howtoforge.com/using-php5-fpm-with-apache2-on-ubuntu-12.04-lts):

1. `sudo apt-get -y install apache2-mpm-worker libapache2-mod-fastcgi php5-fpm php5`
2. `sudo a2enmod actions fastcgi alias`
3. `sudo pico -w /etc/apache2/conf.d/php5-fpm.conf`

        <IfModule mod_fastcgi.c>
            AddHandler php5-fcgi .php
            Action php5-fcgi /php5-fcgi
            Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
            FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host 127.0.0.1:9000 -pass-header Authorization
        </IfModule>
4. `sudo service apache2 restart`
5. `sudo echo "<?php phpinfo();" > /var/www/info.php`
6. Now you should see *FPM/FastCGI* in the third row "Server API" when you go to [http://10.1.2.3/info.php](http://10.1.2.3/info.php)

#### 2. Installing Alternative PHP cache

Alternative PHP cache speeds up PHP processing. This tutorial is based on [Digital Ocean's article](https://www.digitalocean.com/community/tutorials/how-to-install-alternative-php-cache-apc-on-a-cloud-server-running-ubuntu-12-04):

1. `sudo apt-get -y install php-pear php5-dev make libpcre3-dev` (enter and accept every possible step with their defaults)
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

### How to remove a project or vhost

If you remove a project from Projects folder, or rename it, you should also remove/rename `vhosts/projectname.dev.conf` correspondingly and make sure after `vagrant ssh` you don't have that conf to point nonexisting files in `/etc/apache2/sites-enabled` and `/etc/apache2/sites-available`. Otherwise the server (apache) wont' start!

For example, if we create test project to ~/Projects/test and then remove the folder, next time you are starting up apache fails. You will have to `vagrant ssh` and `sudo rm /etc/apache2/sites-enabled/test.dev.conf && sudo rm /etc/apache2/sites-available/test.dev.conf && /vagrant/vhosts/test.dev.conf`.

## Connecting with another computer in LAN

You should be good to go after setting up **/etc/hosts** to `192.168.2.242 jolly.dev` (depending on your local subnet of course) on remote computer. If you have problems like I had, run this command on your vagrant host PC (not inside vagrant ssh!):

    sudo ssh -p 2222 -gNfL 80:localhost:80 vagrant@localhost -i ~/.vagrant.d/insecure_private_key
    
This also helps in some cases where you are unable to open http://localhost in browser window.

### Port forwarding (optional)

`Vagrantfile` has port forwarding included, but Mac OS X has some limitations. If .dev-urls are not reachable from local area network, please add this to `/usr/bin/forwardports` by `sudo nano /usr/bin/forwardports`:

    echo "
    rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 8080
    rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 8443
    " | sudo pfctl -f - > /dev/null 2>&1;
    
    echo "==> Fowarding Ports: 80 -> 8080, 443 -> 8443";
    
    osascript -e 'tell application "Terminal" to quit' & exit;

Chmod it by `chmod +x /usr/bin/forwardports` and run `forwardports`. You have to do this every time after reboot, if you are co-working in LAN.

## SSL / HTTPS (optional)

If you need to use HTTPS-protocol, you will need your own certificate.

### Create a self-signed SSL Certificate for jolliest-vagrant

1. Go to the directory you cloned this repo by `cd ~/Projects/jolliest-vagrant`
2. Make sure you are in your vagrant directory (`cd ~/Projects/jolliest-vagrant`) and SSH into your vagrant box: `vagrant ssh`
3. `sudo a2enmod ssl` to enable SSL
4. `openssl genrsa -des3 -out server.key 1024`
5. `openssl req -new -key server.key -out server.csr`
6. `cp server.key server.key.org`
7. `openssl rsa -in server.key.org -out server.key`
8. `openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt`
9. `sudo cp server.key /etc/apache2/ssl.key`
10. `sudo cp server.crt /etc/apache2/ssl.crt`

Exit SSH and update your site vhost in `~/Projects/jolliest-vagrant/vhosts/vhostname.dev.conf` by adding this


    <VirtualHost *:443>  
      ServerAdmin webmaster@example
      ServerName  example.dev
      ServerAlias www.example.dev
      DirectoryIndex index.html index.php
      DocumentRoot /var/www/example
      LogLevel warn
      ErrorLog  /var/www/example/error.log
      CustomLog /var/www/example/access.log combined

      SSLEngine on
      SSLCertificateFile /etc/apache2/ssl.crt
      SSLCertificateKeyFile /etc/apache2/ssl.key
      SetEnvIf User-Agent ".*MSIE.*" nokeepalive ssl-unclean-shutdown
    </VirtualHost>

11. `vagrant provision` and you should be able to navigate to https://example.dev and start developing.

**Please note:** You can only have one SSL project in the same time, so move VirtualHost entry to the other project conf when you are switching projects.

## Installing Phpmyadmin (optional)

If you use Mac OS X I recommend Sequel Pro, but in other cases phpmyadmin comes pretty handy. Based on [Digital Ocean's tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-12-04).

1. Go to the directory you cloned this repo by `cd ~/Projects/jolliest-vagrant`
2. Make sure you are in your vagrant directory (`cd ~/Projects/jolliest-vagrant`) and SSH into your vagrant box: `vagrant ssh`
3. Install phpmyadmin with `sudo apt-get install phpmyadmin apache2-utils`
4. Choose apache2 when asked, choose yes in the next question about dbconfig-common
5. Type `vagrant` every time when a password is asked
6. `sudo pico -w /etc/apache2/apache2.conf` and add `Include /etc/phpmyadmin/apache.conf` to the bottom
7. Restart apache with `sudo service apache2 restart`
8. Now you can access your phpmyadmin in [localhost/phpmyadmin](http://localhost/phpmyadmin) (if not, make sure you have `10.1.2.3 localhost` added to your /etc/hosts (on your PC, NOT in vagrant ssh) and you have invoked the [ssh LAN command](#connecting-with-another-computer-in-lan).

## Troubleshooting and issues

### Connection timeout

    ==> default: Waiting for machine to boot. This may take a few minutes...
        default: SSH address: 127.0.0.1:2222
        default: SSH username: vagrant
        default: SSH auth method: private key
        default: Error: Connection timeout. Retrying...
        default: Error: Connection timeout. Retrying...
        default: Error: Connection timeout. Retrying...
        default: Error: Connection timeout. Retrying...
        ...

If you encounter this very bizarre issue, 

1. probably something is blocking your ports. Please try to change `auto_correct` to `false` to see if it's about ports. If it is, change guest port to `8080` or some random number over `1024`. Then, change port forwarding settings from `8080 -> 80` or from any port number you specified in guest port section.

2. you have probably messed up with your SSH configs. Please ensure you have set up your SSH precicely with [Bitbucket's "Set up SSH for Git"](https://confluence.atlassian.com/display/BITBUCKET/Set+up+SSH+for+Git) before setting up vagrant.

3. The best is to `vagrant destroy` or remove all traces of vagrant and try from scratch.

4. Also, you may want to disable `nfs` and `mount_options` in your `Vagrantfile`. That helped me two times.

5. Try to boot your vm manually using `Virtualbox`, or add `v.gui = true` inside `config.vm.provider "virtualbox" do |v|` and see if that produces any errors.

6. Open an issue to [issue tracker](https://github.com/ronilaukkarinen/jolliest-vagrant/issues) so we can test and discuss this further.

**Baseline**: My vagrant box doesn't like multiple boxes with SSH, that could cause problems. If nothing else seems to work, it may be 64bit box virtualization issue with your machine. In this case you can try to change precise64 to precise32 box and with 1 CPU according to [this](http://stackoverflow.com/questions/24620599/error-vt-x-not-available-for-vagrant-machine-inside-virtualbox#comment43905920_26475597).

### Corrupted JS/CSS

VirtualBox had a bug which may cause a file corruption. Adding `EnableSendfile off` to `/etc/apache2/httpd.conf` should fix this.

### Other issues

In any issue, error or trouble, please open an issue to [issue tracker](https://github.com/ronilaukkarinen/jolliest-vagrant/issues).

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
