echo -e "--- ### ----------------------------------------------------------------------------------- ### ---"
echo -e "--- ### This script installs necessary packages for Laravel development,                    ### ---"
echo -e "--- ### on a Vagrant / VirtualBox machine, and adapted from                                 ### ---"
echo -e "--- ### http://silverstripe-webdevelopment.com/tricks/creating-a-development-machine/, and  ### ---"
echo -e "--- ### https://gist.github.com/rrosiek/8190550.                                            ### ---"
echo -e "--- ###                                                                                     ### ---"
echo -e "--- ### This set-up is based on a Vagrant box running Ubuntu 16.04, with a L.A.M.P stack.   ### ---"
echo -e "--- ### The particular Vagrant box used with this set-up can be found at                    ### ---"
echo -e "--- ### https://atlas.hashicorp.com/ubuntu/boxes/xenial64.                                  ### ---"
echo -e "--- ### ----------------------------------------------------------------------------------- ### ---\n"

echo -e "Ok, lets begin setting up our server...\n\n"

echo -e "Check to see if our machine has already been set-up...\n"

if [ ! -f "/root/provisioned" ]; then

    echo -e "Set system timezone to 'Pacific/Auckland'.\n"
    sudo timedatectl set-timezone Pacific/Auckland

    DATE_STARTED=$(date)
    # Replace email with your own.
    DEVELOPER_EMAIL_ADDRESS=youremail@example.com
    echo -e "SCRIPT INSTALL STARTED AT $DATE_STARTED.\n"

    echo -e "Truncate build log (/vagrant/vm_build.log).\n"
    sudo echo "" > /vagrant/vm_build.log 

    echo -e "Initialize SSH, if not already done.\n"
    sudo touch ~/.ssh/config
    sudo ssh-keygen -t rsa -b 4096 -C "[ubuntu]" >> /vagrant/vm_build.log 2>&1

    echo -e "Lets update our packages list, and currently installed packages...\n"
    sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade >> /vagrant/vm_build.log 2>&1 
	
	sudo echo "Installing recent version of Virtualbox Guest Additions\n" 
	sudo apt-get -y install virtualbox-guest-dkms >> /vagrant/vm_build.log 2>&1
	sudo usermod --append --groups vboxsf ubuntu >> /vagrant/vm_build.log 2>&1 
	sudo apt autoremove --purge 2>&1 

    echo -e "Install base packages, if not already installed.\n"
    sudo apt-get -y install vim curl build-essential python-software-properties git zip unzip tcl>> /vagrant/vm_build.log 2>&1

    echo -e "Set-up initial default Git configuration.\n"
    sudo git config --global core.filemode false >> /vagrant/vm_build.log 2>&1 

    echo -e "Install subversion (SVN).\n"
    sudo apt-get -y install subversion >> /vagrant/vm_build.log 2>&1

    echo -e "Install and set-up PHP7.2.\n"
    sudo apt-get purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "` >> /vagrant/vm_build.log 2>&1
    sudo add-apt-repository ppa:ondrej/php >> /vagrant/vm_build.log 2>&1
    sudo apt-get update >> /vagrant/vm_build.log 2>&1 
    sudo apt-get -y install php7.2 >> /vagrant/vm_build.log 2>&1

    echo -e "Install necessary PHP modules.\n"
    sudo apt-get -y install libapache2-mod-php7.2 php7.2-mcrypt php7.2-tidy php7.2-gd php7.2-curl php7.2-zip php7.2-mbstring php7.2-dom php7.2-cli php7.2-json php7.2-common php7.2-opcache php7.2-readline php7.2-xml php7.2-mysql php7.2-fpm >> /vagrant/vm_build.log 2>&1 

    echo -e "Enable PHP7.2 modules, if not enabled by default.\n"
    sudo phpenmod -v php7.2 mcrypt tidy gd curl zip mbstring dom cli json common opcache readline xml mysql fpm >> /vagrant/vm_build.log 2>&1

    echo -e "Set-up PHP timezone (to 'Pacific/Auckland').\n"
    sudo chown ubuntu:root /etc/php/7.2/apache2/php.ini
    sudo echo "date.timezone = Pacific/Auckland" >> /etc/php/5.6/apache2/php.ini
    sudo chown root:root /etc/php/7.2/apache2/php.ini
    sudo chown ubuntu:root /etc/php/7.2/cli/php.ini
    sudo echo "date.timezone = Pacific/Auckland" >> /etc/php/5.6/cli/php.ini
    sudo chown root:root /etc/php/7.2/cli/php.ini

    echo -e "Install Apache server.\n"
    sudo apt-get -y install apache2 >> /vagrant/vm_build.log 2>&1

    echo -e "Set-up / enable Apache modules.\n"
    sudo a2enmod rewrite >> /vagrant/vm_build.log 2>&1
    sudo a2enmod vhost_alias >> /vagrant/vm_build.log 2>&1
    sudo a2enmod authz_core >> /vagrant/vm_build.log 2>&1
    sudo a2enmod authz_dbd >> /vagrant/vm_build.log 2>&1
    sudo service apache2 restart >> /vagrant/vm_build.log 2>&1

    echo -e "Set-up MySQL and phpMyAdmin (for development purposes ONLY).\n"
    DBHOST=localhost
    DBUSER=ubuntu
    DBPASSWD=ubuntu
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"
    sudo apt-get -y install mysql-server phpmyadmin >> /vagrant/vm_build.log 2>&1

    echo -e "Set-up Apache server default.\n"
    echo -e "This will show system information with phpinfo() /var/www/server-default/index.php.\n"
    sudo mkdir /var/www/server-default  >> /vagrant/vm_build.log 2>&1
    sudo touch /var/www/server-default/index.php 
    sudo echo "<?php phpinfo();" > /var/www/server-default/index.php

    echo -e "Set-up default sites-enabled for Apache.\n\n"

    echo -e "--- ### ------------------------------------------------------------------------ ### ---"
    echo -e "--- ### DO NOT ENABLE 'server-default.localhost' SITE ON A PRODUCTION SERVER !!! ### ---"
    echo -e "--- ### THIS WILL HAVE **SEVERE** SECURITY IMPLICATIONS !!!                      ### ---"
    echo -e "--- ### THE SAME IDEALLY GOES FOR 'phpmyadmin.localhost' AS WELL !!!             ### ---"
    echo -e "--- ### ------------------------------------------------------------------------ ### ---\n\n"

    sudo echo "<VirtualHost *:80>
        ServerName phpmyadmin.localhost
        ServerAlias phpmyadmin.localhost
        DocumentRoot /usr/share/phpmyadmin
        <Directory /usr/share/phpmyadmin>
        Options FollowSymLinks
        DirectoryIndex index.php
        <IfModule mod_php.c>
            <IfModule mod_mime.c>
                AddType application/x-httpd-php .php
            </IfModule>
            <FilesMatch ".+\.php$">
                SetHandler application/x-httpd-php
            </FilesMatch>
            php_flag magic_quotes_gpc Off
            php_flag track_vars On
            php_flag register_globals Off
            php_admin_flag allow_url_fopen On
            php_value include_path .
            php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
            php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/:/usr/share/doc/phpmyadmin/:/usr/share/php/phpseclib/
        </IfModule>
        </Directory>

        # Authorize for setup
        <Directory /usr/share/phpmyadmin/setup>
            <IfModule mod_authz_core.c>
                <IfModule mod_authn_file.c>
                    AuthType Basic
                    AuthName \"phpMyAdmin Setup\"
                    AuthUserFile /etc/phpmyadmin/htpasswd.setup
                </IfModule>
                Require valid-user
            </IfModule>
        </Directory>

        # Disallow web access to directories that don't need it
        <Directory /usr/share/phpmyadmin/libraries>
            Require all denied
        </Directory>
        <Directory /usr/share/phpmyadmin/setup/lib>
            Require all denied
        </Directory>
    </VirtualHost>

    <VirtualHost *:80>
        ServerName server-default.localhost
        ServerAlias server-default.localhost
        DocumentRoot /var/www/server-default
        <Directory /usr/share/phpmyadmin>
            Options FollowSymLinks
            DirectoryIndex index.php
        </Directory>        
    </VirtualHost>

    <VirtualHost *:80>
        ServerName localhost
        ServerAlias localhost *.localhost
        ServerAdmin webmaster@localhost

        DocumentRoot /var/www
        VirtualDocumentRoot /var/www/%-2+/

        <Directory />
            Options FollowSymLinks
            AllowOverride None
        </Directory>

        <Directory /var/www >
            Options Indexes FollowSymLinks MultiViews
            AllowOverride All
            Order allow,deny
            allow from all
            RewriteEngine On
            SetEnv HTTP_MOD_REWRITE On
            RewriteBase /
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        LogLevel debug
        
    </VirtualHost>" > /etc/apache2/sites-enabled/000-default.conf 
    sudo service apache2 restart >> /vagrant/vm_build.log 2>&1

    echo -e "Installing Composer, globally, for PHP package management.\n"
    curl -sS https://getcomposer.org/installer | php >> /vagrant/vm_build.log 2>&1
    sudo mv composer.phar /usr/local/bin/composer >> /vagrant/vm_build.log 2>&1
	
	echo -e "Setup Redis cache.\n"
	sudo apt-get install redis-server php-redis
	
	echo -e "Configure max memory for Redis, as well as how Redis will select what to remove when the max memory is reached.\n"
	sudo echo "
	maxmemory 256mb
	maxmemory-policy allkeys-lru
	" > /etc/redis/redis.config
	
	echo -e "Restarting Redis service...\n"
	sudo systemctl restart redis-server.service
	
	echo -e "Enable Redis on system boot.\n"
	sudo systemctl enable redis-server.service

	sudo echo -e "Restart any Apache and PHP-FPM processes after Redis configuration.\n"
	sudo service apache2 restart
	sudo service php7.2-fpm restart

    echo -e "Add Node 9.x (for Bower, Grunt, NPM, etc).\n"
	curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash - >> /vagrant/vm_build.log 2>&1 
    sudo apt-get update >> /vagrant/vm_build.log 2>&1 

    echo -e "Installing NodeJS and NPM.\n"
    sudo apt-get -y install nodejs npm >> /vagrant/vm_build.log 2>&1

    echo -e "Installing Gulp, Bower, cross-env.\n"
    npm install -g gulp bower cross-env --force --no-bin-links >> /vagrant/vm_build.log 2>&1
    
    echo -e "Remove Laravel test project, if it already exists.\n"
    if [ -d "/var/www/laravel-test" ]; then 
        sudo chown -R ubuntu:ubuntu /var/www/laravel-test
        sudo chmod -R 777 /var/www/laravel-test
        rm -rf /var/www/laravel-test /vagrant/vm_build.log 2>&1 
		rm -rf /var/www/laravel-test/.*
    fi

    echo -e "Set-up database for Laravel test site."
    LARAVEL_TEST_DB=laravel_test
    mysql -uroot -p$DBPASSWD -e "DROP DATABASE IF EXISTS $LARAVEL_TEST_DB" >> /vagrant/vm_build.log 2>&1
    mysql -uroot -p$DBPASSWD -e "CREATE DATABASE IF NOT EXISTS $LARAVEL_TEST_DB" >> /vagrant/vm_build.log 2>&1
    mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON $LARAVEL_TEST_DB.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASSWD'" > /vagrant/vm_build.log 2>&1
    mysql -uroot -p$DBPASSWD -e "FLUSH PRIVILEGES" >> /vagrant/vm_build.log 2>&1

    echo -e "Create test Laravel site.\n"
	mkdir /var/www/laravel-test >> /vagrant/vm_build.log 2>&1
    sudo chown ubuntu:www-data /var/www/ -R >> /vagrant/vm_build.log 2>&1
    cd /var/www/ >> /vagrant/vm_build.log 2>&1
    composer create-project laravel/laravel laravel-test >> /vagrant/vm_build.log 2>&1
    cd laravel-test >> /vagrant/vm_build.log 2>&1
	echo -e "Install Redis composer package for use with Laravel.\n"
	composer require predis/predis >> /vagrant/vm_build.log 2>&1
	echo -e "Create .env file for Laravel test project.\n"
	echo "APP_NAME=\"Laravel Test\"
	      APP_ENV=local
          APP_KEY=base64:9IOxeGk525vXJ6OvOFMsOT8F2EZkiORMMssYWBIwd9o=
          APP_DEBUG=true
          APP_LOG_LEVEL=debug
          APP_URL=http://laravel-test.localhost

          # You can make this up
          USER_NAME='Testy McTestFace'
          USER_EMAIL=admin@laravel-test.com
          USER_PASSWORD=P@ssw0rd55

          DB_CONNECTION=mysql
          DB_HOST=127.0.0.1
          DB_PORT=3306
          DB_DATABASE=laravel_test
          DB_USERNAME=root
          DB_PASSWORD=ubuntu

          BROADCAST_DRIVER=log
          CACHE_DRIVER=file
          SESSION_DRIVER=file
          SESSION_LIFETIME=120
          QUEUE_DRIVER=sync

          REDIS_HOST=127.0.0.1
          REDIS_PASSWORD=null
          REDIS_PORT=6379

          MAIL_DRIVER=smtp
          MAIL_HOST=smtp.mailtrap.io
          MAIL_PORT=2525
          MAIL_USERNAME=null
          MAIL_PASSWORD=null
          MAIL_ENCRYPTION=null

          PUSHER_APP_ID=
          PUSHER_APP_KEY=
          PUSHER_APP_SECRET=" > .env
		  
	echo -e "Run initial database migrations for Laravel test project.\n"
    php artisan migrate --seed >> /vagrant/vm_build.log 2>&1
	echo -e "Create fresh Laravel app key (used for hashing)\n"
	php artisan key:generate
	echo -e "Set owner/group of storage directory (and any sub-directories) to 'www-data:www-data'.\n"
    chmod -R 0755 storage >> /vagrant/vm_build.log 2>&1
	chown -R www-data:www-data storage >> /vagrant/vm_build.log 2>&1
	
	echo -e "Install NPM dependencies for Laravel test project."
	npm install --force --no-bin-links
	
	echo -e "Run 'npm run dev' and 'npm run prod' to compile front-end assets with WebPack and Laravel-Mix.\n"
	echo -e "This could take a few minutes, depending on your networking and guest/host machine capabilities.\n"
	npm run dev && npm run prod >> /vagrant/vm_build.log 2>&1
	
    echo -e "Leaving Laravel test project directory (/var/www/laravel-test), going into /home/ubuntu...\n"
    cd /home/ubuntu >> /vagrant/vm_build.log 2>&1 

    echo -e "Set-up / install PHPDox.\n"
    wget https://github.com/theseer/phpdox/releases/download/0.10.1/phpdox-0.10.1.phar  >> /vagrant/vm_build.log 2>&1
    chmod +x phpdox-0.10.1.phar >> /vagrant/vm_build.log 2>&1
    sudo mv phpdox-0.10.1.phar /usr/local/bin/phpdox >> /vagrant/vm_build.log 2>&1

    echo -e "Set-up / install squizlabs/php_codesniffer with Composer.\n"
    composer global require "squizlabs/php_codesniffer=*" >> /vagrant/vm_build.log 2>&1

    echo -e "--- ### ------------------------------------------------------------------------------------------------------- ### ---"
    echo -e "--- ### Creating user 'laraveldev' for SFTP.                                                               ### ---"
    echo -e "--- ### NOTE: DO NOT SET PASSWORD THIS WAY ON PRODUCTION MACHINE!!!                                             ### ---"
    echo -e "--- ### NOTE: THIS IS FOR DEVELOPMENT PURPOSES ONLY!!!                                                          ### ---"
    echo -e "--- ### ------------------------------------------------------------------------------------------------------- ### ---\n"
    sudo useradd -u 74583 -p $(echo laraveldev | openssl passwd -1 -stdin) -m laraveldev >> /vagrant/vm_build.log 2>&1
    sudo chown -R laraveldev:www-data /var/www >> /vagrant/vm_build.log 2>&1
    sudo usermod -d /var/www laraveldev >> /vagrant/vm_build.log 2>&1
    echo -e "SFTP user 'laraveldev' with password 'laraveldev' created."
    echo -e "When SFTP'ing into server as this user, you will automatically ."
    echo -e "go into /var/www directory.\n"
    
    if [ ! -f "/root/provisioned" ]; then 
        echo -e "Now the set-up has finished, create a file to show that the machine has been 'provisioned'."
        sudo touch /root/provisioned 
        sudo chmod a-w /root/provisioned    
    fi
    
    echo -e "SCRIPT INSTALL STARTED AT $DATE_STARTED.\n"
    DATE_FINISHED=$(date)
    echo -e "SCRIPT INSTALL FINISHED AT $DATE_FINISHED.\n\n"

    echo -e "--- ### ---------------------------------------------------------------------------------------------------------------- ### ---"
    echo -e "--- ### Put these entries in your Windows (the host O.S) hosts file, e.g. C:\ Windows \ System32 \ drivers \ etc \ hosts ### ---"
    echo -e "--- ###                                                                                                                  ### ---"
    echo -e "--- ### 127.0.0.1:8080                   localhost                                                                       ### ---"
    echo -e "--- ### 127.0.0.1:8080/phpmyadmin/       phpmyadmin.localhost                                                            ### ---"
    echo -e "--- ### 127.0.0.1:8080                   server-default.localhost                                                        ### ---"                                                           ### ---"
    echo -e "--- ### 127.0.0.1:8080                   laravel-test.localhost                                                          ### ---"
    echo -e "--- ###                                                                                                                  ### ---"
    echo -e "--- ### Note: if you are using a Linux-based O.S as your host O.S, put the above entries in /etc/hosts                   ### ---"
    echo -e "--- ###                                                                                                                  ### ---"
    echo -e "--- ### For the site's defined above, you can access them in your browser as follows:                                    ### ---"
    echo -e "--- ###                                                                                                                  ### ---"
    echo -e "--- ### phpMyAdmin => http://laravel-test.localhost:8080                                                                 ### ---"
    echo -e "--- ### Server Default => http://server-default.localhost:8080                                                           ### ---"
    echo -e "--- ###                                                                                                                  ### ---"
    echo -e "--- ### Note: the 'Server Default' site displays PHP/System information.                                                 ### ---"
    echo -e "--- ###                                                                                                                  ### ---"
    echo -e "--- ### DO NOT ENABLE THE ABOVE SERVER DEFAULT SITE ON A PRODUCTION SERVER !!!                                           ### ---"
    echo -e "--- ### THAT WILL HAVE **SEVERE** SECURITY IMPLICATIONS !!!                                                              ### ---"
    echo -e "--- ### THE SAME IDEALLY GOES FOR PHPMYADMIN AS WELL !!!                                                                 ### ---"
    echo -e "--- ### ---------------------------------------------------------------------------------------------------------------- ### ---"
else
    echo -e "You have already provisioned this Vagrant machine!"
    echo -e "Run 'vagrant halt && vagrant destroy && vagrant up --provision'"
    echo -e "from your host machine to recreate and re-provision your machine."
fi 
