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
- [WordMove](https://github.com/welaika/wordmove)
- [WordPress CodeSniffer](https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards)
- [PHP xDebug extension](http://xdebug.org/) - it is already configured for remote debugging from your IDE (idekey option is set to "vagrant")

Wordpress plugins:
- [WP DB Sync](https://github.com/wp-sync-db/wp-sync-db)
- [WP Sync DB Media Files](https://github.com/wp-sync-db/wp-sync-db-media-files)
- [GitHub Updater](https://github.com/afragen/github-updater)