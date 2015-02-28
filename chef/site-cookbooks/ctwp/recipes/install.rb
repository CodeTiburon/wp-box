# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-25

require 'shellwords'
docroot = ::File.join node[:ctwp][:docroot_dir], node[:ctwp][:siteurl]

# Install worpdress if it doesn't exist
bash "wordpress-core-download" do
  user node[:ctwp][:user]
  group node[:ctwp][:group]

  code <<-EOS.gsub /\s+/m, ' '
    WP_CLI_CONFIG_PATH=#{Shellwords.shellescape(node[:ctwp][:cli][:cfg])} wp core download
    --path=#{docroot}
    --locale=#{Shellwords.shellescape(node[:ctwp][:locale])}
    --force
  EOS

  not_if { ::File.exists? File.join docroot, 'wp-login.php' }
end

file File.join(docroot, "wp-config.php") do
  action :delete
  backup false
end

bash "wordpress-core-config" do
  user node[:ctwp][:user]
  group node[:ctwp][:group]
  cwd File.join(docroot)

  code <<-EOH
    WP_CLI_CONFIG_PATH=#{Shellwords.shellescape(node[:ctwp][:cli][:cfg])} wp core config \\
    --dbhost=#{Shellwords.shellescape(node[:ctwp][:dbhost])} \\
    --dbname=#{Shellwords.shellescape(node[:ctwp][:dbname])} \\
    --dbuser=root \\
    --dbpass=#{node[:mysql][:server_root_password]} \\
    --dbprefix=#{Shellwords.shellescape(node[:ctwp][:dbprefix])} \\
    --locale=#{Shellwords.shellescape(node[:ctwp][:locale])} \\
    --extra-php <<-PHP
/** Addinional configurations */
define( 'WP_HOME', 'http://#{File.join(node[:ctwp][:host], node[:ctwp][:homeurl]).sub(/\/$/, '')}' );
define( 'WP_SITEURL', 'http://#{File.join(node[:ctwp][:host], node[:ctwp][:siteurl]).sub(/\/$/, '')}' );
define( 'WP_POST_REVISIONS', 3 );
define( 'AUTOSAVE_INTERVAL', 300 );
define( 'WP_DEBUG', #{node[:ctwp][:debug_mode]} );
define( 'JETPACK_DEV_DEBUG', #{node[:ctwp][:debug_mode]} );
define( 'FORCE_SSL_ADMIN', #{node[:ctwp][:force_ssl_admin]} );
define( 'SAVEQUERIES', #{node[:ctwp][:savequeries]} );
PHP
EOH
# end of "wordpress-core-config" bash resource
end

# Create database if it does not exist
execute "wordpress-create-database" do
  command "/usr/bin/mysqladmin -uroot -p\"#{node[:mysql][:server_root_password]}\" create #{node[:ctwp][:dbname]}"

  not_if do
    # Make sure gem is detected if it was just installed earlier in this recipe
    require 'rubygems'
    Gem.clear_paths
    require 'mysql'

    m = Mysql.new "localhost", "root", node[:mysql][:server_root_password]
    m.list_dbs.include? node[:ctwp][:dbname]
  end

  notifies :run, "bash[wordpress-core-install]", :immediately
  notifies :run, "execute[wordpress-import-database]", :immediately
end

bash "wordpress-core-install" do
  user node[:ctwp][:user]
  group node[:ctwp][:group]
  cwd File.join(docroot)

  code <<-EOS.gsub /\s+/m, ' '
    WP_CLI_CONFIG_PATH=#{Shellwords.shellescape(node[:ctwp][:cli][:cfg])} wp core install
    --url=http://#{File.join(node[:ctwp][:host], node[:ctwp][:siteurl])}
    --title='CT WordPress'
    --admin_user=admin
    --admin_password=admin
    --admin_email=admin@#{File.join(node[:ctwp][:host])}
  EOS

  not_if { File.exists? File.join(docroot, 'dump.sql') }
  action :nothing
end

execute "wordpress-import-database" do
  command <<-EOS.gsub /\s+/m, ' '
     /usr/bin/mysql -uroot -p"#{node[:mysql][:server_root_password]}" -D#{node[:ctwp][:dbname]}
       < "#{File.join(docroot, 'dump.sql')}"
  EOS

  only_if { File.exists? File.join(docroot, 'dump.sql') }
  action :nothing
end

#
# Installs wordpress plugins
#
node[:ctwp][:default_plugins].each do |name, src|
  bash "wordpress-#{name}-install" do
    user node[:ctwp][:user]
    group node[:ctwp][:group]
    cwd File.join(docroot)

    code "WP_CLI_CONFIG_PATH=#{Shellwords.shellescape(node[:ctwp][:cli][:cfg])} wp plugin install #{Shellwords.shellescape(src)}"
    not_if { File.exists? File.join(docroot, 'wp-content', 'plugins', name) }

    if src =~ /^https:\/\/github.com\//
      notifies :run, "ruby_block[wordpress-#{name}-rename]", :immediately
    end
  end

  ruby_block "wordpress-#{name}-rename" do
    block do
      plugins = ::File.join docroot, 'wp-content', 'plugins'
      branch = ::File.basename src, ".zip"

      ::File.rename File.join(plugins, name + '-' + branch), File.join(plugins, name)
    end

    action :nothing
  end
end

#
# Change owner for document root
#
directory File.join(node[:ctwp][:docroot_dir], node[:ctwp][:homeurl]) do
  recursive true
  owner node[:ctwp][:user]
  group node[:ctwp][:group]
end

#
# Configure Apache virtual hosts
#
apache_site "000-default" do
  enable false
end

web_app node[:ctwp][:host] do
  template "apache.site.erb"
  docroot node[:ctwp][:docroot_dir]
  server_name node[:fqdn]
end

bash "create-ssl-keys" do
  user "root"
  group "root"
  cwd File.join(node[:apache][:dir], 'ssl')

  code <<-EOS
    openssl genrsa -out server.key 2048
    openssl req -new -key server.key -subj '/C=JP/ST=Wakayama/L=Kushimportoto/O=My Corporate/CN=#{node[:fqdn]}' -out server.csr
    openssl x509 -in server.csr -days 365 -req -signkey server.key > server.crt
  EOS

  not_if { File.size? File.join(node[:apache][:dir], 'ssl', 'server.crt') }
  notifies :restart, "service[apache2]"
end


iptables_rule "iptables.rules"
