Vagrant LAMP
============

The implementation includes Apache 2, MySQL 5.5 and PHP 5.5.

Requirements
------------

* VirtualBox <http://www.virtualbox.com/>
* Vagrant <http://vagrantup.com>
* Git <http://git-scm.com>

Usage
-----

### Start up
    $ git clone https://github.com/samacs/lamp-server.git
    $ cd lamp-server
    $ vagrant up

### Connecting

#### Apache
The Apache server is available at <http://localhost:8888>

#### MySQL
The MySQL server is available to external connections through port 8889.

* Username: root
* Password: root

Details
---------
* Ubuntu 14.04 64-bit
* Apache 2
* PHP 5.5
* MySQL 5.5

The web root is pointing to `./htdocs`.

To access your box via ssh, just run:

    $ vagrant ssh
