# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-25

default[:ctwp][:src_path]              = '/usr/local/share'
default[:ctwp][:makepot]               = '/usr/bin/php /usr/local/share/wp-i18n/makepot.php'
default[:ctwp][:bash_profile]          = '/home/vagrant/.bash_profile'
default[:ctwp][:ssh_config]            = '/home/vagrant/.ssh/config'

default[:ctwp][:composer][:install]    = 'curl -sS https://getcomposer.org/installer | php'
default[:ctwp][:composer][:link]       = '/usr/local/bin/composer'
default[:ctwp][:composer][:home]       = '/home/vagrant/.composer'

default[:ctwp][:phpcs][:composer]       = 'squizlabs/php_codesniffer=*'
default[:ctwp][:phpcs][:sniffs]         = 'wpcs'
default[:ctwp][:phpcs][:alias]          = 'wpcs'

default[:ctwp][:user] = 'vagrant'
default[:ctwp][:group] = 'vagrant'

default[:ctwp][:cli][:dir] = '/usr/share/wp-cli'
default[:ctwp][:cli][:lnk] = '/usr/local/bin/wp'
default[:ctwp][:cli][:cfg] = '/home/vagrant/.wp-cli/config.yml'

default[:ctwp][:host] = "wordpress.local"
default[:ctwp][:homeurl] = ""
default[:ctwp][:siteurl] = ""
default[:ctwp][:docroot_dir] = "/var/www/wordpress"

default[:ctwp][:dbhost] = "localhost"
default[:ctwp][:dbname] = "wordpress"
default[:ctwp][:dbprefix] = "wp_"
default[:ctwp][:locale] = "en_US"
default[:ctwp][:default_plugins] = {
  'meta-box' => "meta-box",
  'github-updater' => "https://github.com/afragen/github-updater/archive/master.zip",
  'wp-sync-db' => "https://github.com/wp-sync-db/wp-sync-db/archive/master.zip",
  'wp-sync-db-media-files' => "https://github.com/wp-sync-db/wp-sync-db-media-files/archive/master.zip"
}

default[:ctwp][:debug_mode] = false
default[:ctwp][:savequeries] = false
default[:ctwp][:force_ssl_admin] = false
