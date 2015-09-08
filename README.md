Previous version of WP box is available as release [v1.0.0](https://github.com/CodeTiburon/wp-box/releases/tag/v1.0.0)

# WordPress Application Box

This is a scaffolding that should be used for each new WordPress project in our company.
This box consists of:

- Vagrant
- Ubuntu 14.04 Trusty
- Chef Solo
- WordPress (latest version)

Server software:

- Apache
- PHP
- MySQL

It automatically installs additional tools:

- [WP CLI](http://wp-cli.org/)
- [WP *makepot.php* i18n Tool](http://codex.wordpress.org/I18n_for_WordPress_Developers)
- [WordMove](https://github.com/welaika/wordmove)
- [WordPress CodeSniffer](https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards)
- [PHP xDebug extension](http://xdebug.org/) - it is already configured for remote debugging from your IDE (*idekey* option is set to "vagrant")

WordPress plugins:

- [Meta Box](http://metabox.io/)
- [WP Mail SMTP](https://wordpress.org/plugins/wp-mail-smtp)
- [WP DB Sync](https://github.com/wp-sync-db/wp-sync-db)
- [WP Sync DB Media Files](https://github.com/wp-sync-db/wp-sync-db-media-files)
- [GitHub Updater](https://github.com/afragen/github-updater)

## Vagrant plugins

 - [vagrant-bindfs](https://github.com/gael-ian/vagrant-bindfs) for Linux/OSX hosts.
 - [vagrant-omnibus](https://github.com/chef/vagrant-omnibus) is a vagrant plugin that ensures the desired version of Chef is installed via the platform-specific Omnibus packages.
 - To automatically configure the `host` file on your guest and host (Linux only) machines it is recommended to install 'vagrant-hostmanager' plugin:  
`vagrant plugin install vagrant-hostmanager`
 - [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) is a Vagrant plugin which automatically installs the host's VirtualBox Guest Additions on the guest system.



## WP-BOX Installation

1. Clone the repository. Please note:
   `chef_gem` and `rvm` cookbooks are added to main repository as submodules. Run `git submodule update --init` to clone these cookbooks.
2. Install on of the following 
    1. If you want to use 'rsync' synchronization on Linux systems  
Ubuntu: `apt-get -y install rsync`  
CentOS: `yum -y install rsync`  
Then you should set SYNC_TYPE to 'rsync' in the Vagrantfile
    2. If you want to use 'nfs' synchronization on Linux systems  
Ubuntu: `apt-get -y install nfs-kernel-server nfs-common`  
CentOS: `yum -y install nfs-utils nfs-utils-lib`  
Then you should set SYNC_TYPE to 'nfs' in the Vagrantfile
  
Set additional configurations in the top of the Vagrantfile (like HOSTNAME, TABLE_PREFIX etc.)
Later this configurations will be moved to the separate `config.yml.dist` file.

Now run `vagrant up`:

- if there is no any wordpress installation in the ./wordpress directory, the latest wordpress version will be installed;
- if there is a ./worpdress/dump.sql file it will be automatically imported to the database during vagrant VM installation.

## Defaults

- Domain: wordpress.local
- IP: 192.168.33.10
- Syncronization type: nfs (for Linux only)
- DB name: wordpress
- DB user: root
- DB password: root
- Table prefix: wp_