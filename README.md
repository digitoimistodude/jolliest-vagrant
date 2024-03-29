| :bangbang: | **This repository is no longer actively maintained. The vagrant box still works, but does not receive any further updates other than community contributed fixes. Currently focusing on our [LEMP stack development](https://github.com/digitoimistodude/marlin-vagrant)**  |
|:------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

# Jolliest vagrant

This is a **simple** WordPress optimized vagrant server with **minimal** provisioning, originally created for local development environment for multiple WordPress projects.

This vagrant server can be used as plain local server for serving your files or testing static PHP, but it's also perfect for WordPress development.

Currently successfully tested on Linux (elementary OS), Mac OS X and Windows 10.

See also our LEMP box [marlin-vagrant](https://github.com/digitoimistodude/marlin-vagrant).

## What's inside?

| Feature                 | Version / amount                                                   |
|-------------------------|--------------------------------------------------------------------|
| Ubuntu                  | 12.04.5 LTS (Precise Pangolin)                                     |
| MySQL                   | 5.5                                                                |
| PHP                     | 5.3.10 (optionally 5.5.30)                                       |
| WordPress optimizations | PHP modules recommended for optimal WordPress performance          |
| Vagrant                 | NFS, provision.sh with pre-installed packages, speed optimizations |
| CPU cores               | 2                                                                  |
| RAM                     | 2 GB                                                               |
| Apache                  | 2.2.22 (optionally 2.4.16)                                                            |

## Background

I tried about 30 vagrant setups before this box. I created already two vagrant-repositories before this one. Started to modify them to my needs and noticed that commit after commit I got more and more stuck with stuff I didn't need or wasn't patient enough to learn how to configure thoroughly.

After bashing my head to the wall enough, ended up removing those repositories and learn everything from scratch. There are too many vagrant setups and I have probably tried most of them.

Chef and puppet are crazy by their configurations and learning curve. Managed to handle them but after all I'm more of a bash guy, so naturally this version of my vagrant setup will use only simple bash script. Keep it simple, stupid.

## The story behind the name

Tried  to make up distinctive name for this and noticed *server for multiple projects* anagrams to *scrump of jolliest perverter*. That's why this is the **jolliest vagrant** ever.

## Usage

To start this vagrant box, always run `vagrant up --provision`, with provision -hook to ensure all the stuff are loaded up properly.

## Table of contents

1. [Installation on Mac/Linux](#installation-on-maclinux)
2. [Installation on Windows](#installation-on-windows)
3. [Post-installations](#post-installations)
  1. [Installing FastCGI](#1-installing-fastcgi)
  2. [Installing Alternative PHP cache](#2-installing-alternative-php-cache)
  3. [More speed with configs](#3-more-speed-with-configs)
4. [How to add new vhost](#how-to-add-new-vhost)
5. [How to remove a project or vhost](#how-to-remove-a-project-or-vhost)
6. [Connecting with another computer in LAN](#connecting-with-another-computer-in-lan)
7. [Port forwarding (optional)](#port-forwarding-optional)
8. [SSL / HTTPS (optional)](#ssl--https-optional)
9. [Installing Phpmyadmin (optional)](#installing-phpmyadmin-optional)
10. [Sequel Pro settings for MySQL](#sequel-pro-settings-for-mysql)
11. [Extra](#extra)
  1. [Installing PHP 5.5 and Apache 2.4 with FastCGI](#installing-php-55-and-apache-24-with-fastcgi)
12. [Troubleshooting and issues](#troubleshooting-and-issues)
  1. [Connection timeout](#connection-timeout)
  2. [SSH command responded with a non-zero exit status](#ssh-command-responded-with-a-non-zero-exit-status)
  3. [Corrupted JS/CSS](#corrupted-jscss)
  4. [Other issues](#other-issues)

## Recommendations

1. Mac OS X or Linux
2. Simple knowledge of web servers
3. WordPress projects under the same folder
4. [dudestack](https://github.com/digitoimistodude/dudestack) in use

## Installation on Mac/Linux

1. Install [Virtualbox](https://www.virtualbox.org/)
2. Start Virtualbox, check updates and install all the latest versions of Virtualbox and Oracle VM Virtualbox Extension Pack, if asked
3. Install [vagrant](http://www.vagrantup.com) (**Mac OS X** [Homebrew](http://brew.sh/): `brew install vagrant`)
4. Install vagrant-triggers with command `vagrant plugin install vagrant-triggers`
5. Install VirtualBox Guest Additions -updater vagrant-vbguest with command `vagrant plugin install vagrant-vbguest`
6. Clone this repo to your Projects directory (path `~/Projects/jolliest-vagrant` is depedant in [dudestack](https://github.com/digitoimistodude/dudestack))
7. *(Optional, do this for example if you want to use other image or encounter problems with included Vagrantfile)* If you don't know or don't care, don't do this step. Modify **Vagrantfile**: `config.vm.box` and `config.vm.box_url` to match your production server OS, `config.vm.network` for IP (I recommend it to be `10.1.2.3` to prevent collisions with other subnets) (**For Linux** you need to remove `, :mount_options...` if problems occur with starting the server. Please remove parts that give you errors). **If you don't need to access server from LAN** with co-workers to update WordPress for example, remove completely line with `config.vm.network "public_network"`. You may also need to try different ports than 80 and 443 if your Mac blocks them. For example change the ports to 8080 and 443 (also change triggers accordingly)
8. If you store your projects in different folder than *~/Projects*, change the correct path to `config.vm.synced_folder`
9. Edit or add packages to match your production server packages in **provision.sh** if needed (it's good out of the box though)
10. Add `10.1.2.3 somesite.dev` to your **/etc/hosts**
11. Run `vagrant up --provision`. This can take a moment.

If you make any changes to **Vagrantfile**, run `vagrant reload` or `vagrant up --provision` if the server is not running, or if you change **provision.sh** while running, run `vagrant provision`.

You can always see the apache status by `vagrant ssh`'ing to your vagrant box and typing `sudo service apache2 status`. If it's not started, run `sudo service apache2 start`.

## Installation on Windows

1. Install [Virtualbox](https://www.virtualbox.org/) for Windows
2. Install [Vagrant](http://www.vagrantup.com) for Windows
3. Install [Git](https://git-scm.com/download/win) for Windows
3. Right click My Computer (or This Compu
ter on Windows 10), click Properties, click Advaned System Settings tab, click Environment Variables. Change `VBOX_MSI_INSTALL_PATH` to `VBOX_INSTALL_PATH`. In Windows 10, you can go to Advanced System Settings simply typing it when Start Menu is open.
4. Start `cmd`
5. Navigate to root of `C:\` with double dots `..`
6. `mkdir Projects` to create a project dir and `cd Projects` to enter it
7. Clone this repo to Projects with command `git clone git@github.com:digitoimistodude/jolliest-vagrant.git`
8. Edit `Vagrantfile` with your favorite editor and rename `~/Projects` to `C:/Projects`. Remove `, :mount_options => ['nolock,vers=3,udp,actimeo=2']`
9. Run `vagrant up --provision`, wait when box is installed and Allow access if it asks it. This can take a moment.
10. Add `10.1.2.3 somesite.dev` to your **C:/Windows/system32/drivers/etc/hosts** file and have fun!

## Post-installations

Since I want to make this as simple as possible and this will be the single VM for multiple projects that does not need to change much over time, I want extra stuff to be installed manually. Also, the cleaner the better, besides, what is more fun than installing and configurating things?

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
6. Now you should see *FPM/FastCGI* in the third row "Server API" when you go to [10.1.2.3/info.php](http://10.1.2.3/info.php)

#### 2. Installing Alternative PHP cache

Alternative PHP cache speeds up PHP processing. This tutorial is based on [Digital Ocean's article](https://www.digitalocean.com/community/tutorials/how-to-install-alternative-php-cache-apc-on-a-cloud-server-running-ubuntu-12-04):

1. `sudo apt-get -y install php-pear php5-dev make libpcre3-dev`
2. `sudo pecl install apc`, choose or press return when asked (enter and accept every possible step with their defaults)
3. `sudo pico -w /etc/php5/fpm/php.ini` (normally */etc/php5/apache2/php.ini*, but we are using fpm), scroll all the way down and add to the last line:

        extension = apc.so
        apc.shm_size = 64
        apc.stat = 0

4. `sudo cp /usr/share/php/apc.php /var/www` and `sudo service apache2 restart  && sudo service php5-fpm restart`
5. You should now see APC info when you go to [10.1.2.3/apc.php](http://10.1.2.3/apc.php) with your browser

#### 3. More speed with configs

I have attached **confs** folder which includes custom *my.cnf* and *php.ini* for you to tweak on. 

1. *(Optional)* Customize configs further
2. SSH into your vagrant box (`cd ~/Projects/jolliest-vagrant && vagrant ssh`)
3. Run command `sudo cp /vagrant/confs/my.cnf /etc/mysql/my.cnf && sudo cp /vagrant/confs/php.ini /etc/php5/fpm/php.ini`
4. Run proper restarts `sudo service apache2 restart && sudo service php5-fpm restart && sudo service mysql restart`
5. Config update done! If you want to edit configs later, SSH into vagrant and edit them directly with nano, for example `nano /etc/mysql/my.cnf` etc.

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

## Extra

### Installing PHP 5.5 and Apache 2.4 with FastCGI

If you need newer PHP version, this box doesn't provide it out of the box, because you will also have to upgrade Apache 2.4. This have to be done as post installation (for now). Make sure you are inside the vagrant box (command `vagrant ssh` inside vagrant installation folder `~/Projects/jolliest-vagrant`).

**Please note:** I warn you, this setup is not very straightforward, although I had to do it once and I have written a tutorial for you below. This could take time though and if you need newer stuff, please consider another Vagrant box. I might create a newer box later on when our production server is updated, but for now it is what it is.

First upgdare Apache 2.2 to 2.4 (based on [this tutorial](http://www.ivankrizsan.se/2014/07/17/upgrading-apache-http-server-2-2-to-2-4-on-ubuntu-12-04/)):

1. Backup existing configs (if you have any) with `sudo cp -R /etc/apache2 ~/apache2.2.backup`
2. Backup existing mods list with `cd /etc/apache2/mods-enabled/ && sudo ls -al > ~/enabled-mods.txt`
3. Stop apache: `sudo service apache2 stop`
4. Remove apache2 files: `sudo rm -r /etc/apache2`
5. Remove existing apache: `sudo apt-get remove apache2 && sudo apt-get remove apache2* && sudo apt-get purge apache2 apache2-utils apache2.2-bin apache2-common && sudo apt-get autoremove`
6. Add repository: `sudo apt-add-repository ppa:ondrej/php5` (if you get command not found, run `sudo apt-get install python-sofware-properties` and try again)
7. Update: `sudo apt-get update`
8. Install apache 2.4: `sudo apt-get install apache2`, select Y on `Y or I  : install the package maintainer's version` and check `install the package maintainer's version` when asked
9. Check out your previous modules by `cat /home/vagrant/enabled-mods.txt`
10. `cd /etc/apache2/mods-enabled` and `sudo ls -al`, compare these two outputs and check out which modules are missing
11. Enable mods one by one with these commands: 
`sudo cp /home/vagrant/apache2.2.backup/mods-available/dir.load /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/dir.conf`
`sudo ln -s /etc/apache2/mods-available/dir.load`
`sudo cp /home/vagrant/apache2.2.backup/mods-available/alias.load /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/alias.conf`
`sudo ln -s /etc/apache2/mods-available/alias.load`
`sudo cp /home/vagrant/apache2.2.backup/mods-available/authn_file.load /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/authn_file.load`
`sudo ln -s /etc/apache2/mods-available/authz_groupfile.load`
`sudo ln -s /etc/apache2/mods-available/authz_user.load`
`sudo ln -s /etc/apache2/mods-available/autoindex.conf`
`sudo cp /home/vagrant/apache2.2.backup/mods-available/autoindex.load /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/autoindex.load`
`sudo cp /home/vagrant/apache2.2.backup/mods-available/cgid.load /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/cgid.conf`
`sudo ln -s /etc/apache2/mods-available/cgid.load`
`sudo ln -s /etc/apache2/mods-available/deflate.conf`
`sudo ln -s /etc/apache2/mods-available/deflate.load`
`sudo cp /home/vagrant/apache2.2.backup/mods-available/env.load /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/env.load`
`sudo cp /home/vagrant/apache2.2.backup/mods-available/fastcgi* /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/fastcgi.conf`
`sudo ln -s /etc/apache2/mods-available/fastcgi.load`
`sudo cp /home/vagrant/apache2.2.backup/mods-available/mime.load /etc/apache2/mods-available/`
`sudo ln -s /etc/apache2/mods-available/mime.conf`
`sudo ln -s /etc/apache2/mods-available/mime.load`
`sudo ln -s /etc/apache2/mods-available/reqtimeout.conf`
`sudo ln -s /etc/apache2/mods-available/setenvif.conf`
`sudo ln -s /etc/apache2/mods-available/ssl.conf`
`sudo ln -s /etc/apache2/mods-available/ssl.load`
`sudo ln -s /etc/apache2/mods-available/status.conf`
`sudo ln -s /etc/apache2/mods-available/socache_shmcb.load`
9. Copy default config in place with `sudo cp /home/vagrant/apache2.2.backup/sites-available/default /etc/apache2/sites-available/000-default.conf`
10. Enable mod_rewrite: `sudo a2enmod rewrite`

If you encounter any problems, try reinstalling with `sudo dpkg -P apache2` and `sudo apt-get install apache2` or/and try debugging errors again.

Don't restart apache yet, go straght to this step. Here's the clean way to install PHP 5.5 on Ubuntu 12.04 (based on [this](http://stackoverflow.com/questions/21390544/installing-apache-2-4-and-php-5-5-on-ubuntu-12-04)):

1. Run `sudo apt-add-repository ppa:ondrej/apache2`
2. Update repos with `sudo apt-get update`
4. Install PHP 5.5: `sudo apt-get install php5-common php5-mysqlnd php5-xmlrpc php5-curl php5-gd php5-cli php5-fpm php-pear php5-dev php5-imap php5-mcrypt`
6. Select Y on `Y or I  : install the package maintainer's version` and check `install the package maintainer's version` when asked
7. Check that it's 5.5 with `php -v`
8. Install fpm for 5.5 with `sudo apt-get install libapache2-mod-fastcgi`
9. Enable php5-fpm by `sudo a2enconf php5-fpm && a2enmod actions fastcgi alias`
10. Edit & add following: `pico -w /etc/apache2/conf-available/php5-fpm.conf` (according to helpful tip [here](http://stackoverflow.com/questions/19445686/ubuntu-server-apache-2-4-6-client-denied-by-server-configuration-php-fpm):

````
<IfModule mod_fastcgi.c>
    AddHandler php5-fcgi .php
    Action php5-fcgi /php5-fcgi
    Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
    FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -socket /var/run/php5-fpm.sock -pass-header Authorization

    # NOTE: using '/usr/lib/cgi-bin/php5-cgi' here does not work, 
    #   it doesn't exist in the filesystem!
    <Directory /usr/lib/cgi-bin>
        Require all granted
    </Directory>
</Ifmodule>
````

If you get internal server error or 404 not found with pretty links, add this to `/etc/apache2/apache2.conf` (find existing similar lines and remove them):

````
<Directory />
    Options FollowSymLinks
    AllowOverride None
    Require all denied
</Directory>
<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
````

Restart apache and FPM with `sudo service apache2 restart && sudo service php5-fpm restart`. Exit vagrant ssh and run `vagrant reload && vagrant provision` in Vagrant directory end check out possible errors. Otherwise everything should be good!

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

6. Open an issue to [issue tracker](https://github.com/digitoimistodude/jolliest-vagrant/issues) so we can test and discuss this further.

Earlier this issue was caused because I used 64bit image. On Mac OS X there seems to be problems with virtualization in 64bit environments. Today my vagrant box uses precise32 instead of precise64 and this change has fixed this issue for good. If you still encounter issues with SSH, please [let me know](https://github.com/digitoimistodude/jolliest-vagrant/issues).

### SSH command responded with a non-zero exit status

    ==> default: Checking for guest additions in VM...
    ==> default: Configuring and enabling network interfaces...
    The following SSH command responded with a non-zero exit status.
    Vagrant assumes that this means the command failed!

    /sbin/ifdown eth1 2> /dev/null

    Stdout from the command:
    
    
    
    Stderr from the command:
    
    stdin: is not a tty
    

This is related to the timeout / SSH issue. Please reproduce the same steps in [Connection timeout](#connection-timeout) section.

### Corrupted JS/CSS

VirtualBox had a bug which may cause a file corruption. Adding `EnableSendfile off` to `/etc/apache2/httpd.conf` should fix this.

### Other issues

In any issue, error or trouble, please open an issue to [issue tracker](https://github.com/digitoimistodude/jolliest-vagrant/issues).

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
