# Laravel Vagrant Development Machine

## IMPORTANT: THIS SET-UP WAS CREATED ONLY FOR DEVELOPMENT, AND IS NOT SUITABLE FOR A PRODUCTION ENVIRONMENT!

A [Vagrant](https://www.vagrantup.com/)/[VirtualBox](https://www.virtualbox.org/) dev machine set-up for Laravel development, using the popular [ubuntu/xenial](https://atlas.hashicorp.com/ubuntu/boxes/xenial64) Vagrant box.

This is an adaptation of another similar repository I created for Silverstripe-based development, which can be accessed at [https://github.com/rattfieldnz/silverstripe-vagrant-dev-machine](https://github.com/rattfieldnz/silverstripe-vagrant-dev-machine).

This set-up was created on a Windows 10 host machine, with VirtualBox v5.2.0, Vagrant v2.0.1, and Git Bash (2.1.5). If you have a different host O.S (e.g. a Linux distro), feel free to contribute :).

Credit goes to Nicolaas Thiemen Francken from [Sunny Side Up Web Development](http://sunnysideup.co.nz/) for an [excellent well-documented set-up](http://silverstripe-webdevelopment.com/tricks/creating-a-development-machine/), and also to the following GitHub gists:

* https://gist.github.com/rrosiek/8190550
* https://gist.github.com/asmerkin/df919a6a79b081512366

## Step 1 

Clone this repository to your desired location (e.g. C:\Users\YOURUSERNAME\Desktop).

## Step 2

Go into the new cloned folder, then right click "Git Bash Here".

## Step 3

You should now be in a folder as below:

C:\Users\YOURUSERNAME\Desktop\laravel-vagrant-dev-machine

Enter `vagrant up --provision` to begin creating and provisioning your machine. This can take around 10 to 15 minutes, depending on your host machine's resources.

## Step 4

Once your machine has been created and provisioned, put the following entries into your Windows hosts file (C:\Windows\System32\drivers\etc\hosts):

127.0.0.1:8080                   localhost

127.0.0.1:8080/phpmyadmin/       phpmyadmin.localhost

127.0.0.1:8080                   server-default.localhost

You can access the above sites in your browser like so:

* http://phpmyadmin.localhost:8080
* http://server-default.localhost:8080

You can also access the Laravel test project by visiting http://laravel-test.localhost:8080.

## Step 5

To transfer files from your host machine to the newly-created guest machine via SFTP (e.g. with FileZilla), use the following details:

Host: 127.0.0.1

Username: laraveldev

Password: laraveldev

Port: 2222

Default directory upon SFTP login is /var/www

## Step 6

To access phpMyAdmin, navigate to http://phpmyadmin.localhost:8080 in your browser, and use the following credentials:

* Username: ubuntu
* Password: ubuntu

## Step 7

To see server information (as displayed via PHP's 'phpinfo()' function), navigate to http://server-default.localhost:8080.

----------

If you were experimenting with the set-up and broke the Vagrant machine, never fear! All you need to do is enter the following command to recreate said machine:

`vagrant halt && vagrant destroy && vagrant up --provision`

----------

Want to help contribute and improve this set-up? Feel free to fork this repository and submit a push request. If you would like to adapt this for a Linux host machine, let me know and I'll create branches specific to the Linux distro and version.

Credit goes to Nicolaas Thiemen Francken from Sunny Side Up Web Development for an [excellent well-documented set-up](http://silverstripe-webdevelopment.com/tricks/creating-a-development-machine/), and also to the following GitHub gists:

* https://gist.github.com/rrosiek/8190550
* https://gist.github.com/asmerkin/df919a6a79b081512366

