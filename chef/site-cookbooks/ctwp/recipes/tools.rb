# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-25

packages = %w{gettext subversion lftp sshpass ruby-dev}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

#
# Install wordmove https://github.com/welaika/wordmove
#
gem_package "wordmove" do
  action :install
  notifies :create, "cookbook_file[wordmove-1.2.0/sql_adapter.rb]", :immediately
end

# Fix for wordmove 1.2.0 version
cookbook_file "wordmove-1.2.0/sql_adapter.rb" do
  dest = '/var/lib/gems/1.9.1/gems/wordmove-1.2.0/lib/wordmove/sql_adapter.rb'

  path dest
  source "wordmove/sql_adapter.rb"
  only_if { ::File.exists? dest }
  mode 0755

  action :nothing
end

#
# Install xDebug php package
#
php_pear "xdebug" do
  action :install
  zend_extensions ['xdebug.so']
  directives(
    :remote_enable => "on",
    :remote_connect_back => "on",
    :idekey => "vagrant"
  )
end

%w{apache2 cgi cli}.each do |mod|
    link "/etc/php5/#{mod}/conf.d/xdebug.ini" do
      to "#{node['php']['ext_conf_dir']}/xdebug.ini"
    end
end


#
# Setup WordPress i18n Tools
#
subversion "Checkout WordPress i18n tools." do
  repository    'http://i18n.svn.wordpress.org/tools/trunk/'
  revision      'HEAD'
  destination   File.join(node[:ctwp][:src_path], 'wp-i18n');
  action        :sync
  user          "root"
  group         "root"
end

execute "echo 'alias makepot.php=\"#{node[:ctwp][:makepot]}\"' >> #{node[:ctwp][:bash_profile]}" do
  not_if "grep 'alias makepot.php' #{node[:ctwp][:bash_profile]}"
end

#
# Setup Composer
#
directory File.join(node[:ctwp][:src_path], 'composer') do
  recursive true
end

execute node[:ctwp][:composer][:install] do
  user  "root"
  group "root"
  cwd   File.join(node[:ctwp][:src_path], 'composer')
end

link node[:ctwp][:composer][:link] do
  to File.join(node[:ctwp][:src_path], 'composer/composer.phar')
end

directory node[:ctwp][:composer][:home] do
  user  "vagrant"
  group "vagrant"
  recursive true
end

#
# Setup PHP Code Sniffer
#
execute "phpcs-install" do
  user  "vagrant"
  group "vagrant"
  environment ({'COMPOSER_HOME' => node[:ctwp][:composer][:home]})
  command <<-EOH
    #{node[:ctwp][:composer][:link]} global require #{node[:ctwp][:phpcs][:composer]}
  EOH
end

directory File.join(node[:ctwp][:src_path], node[:ctwp][:phpcs][:sniffs]) do
  recursive true
end

git File.join(node[:ctwp][:src_path], node[:ctwp][:phpcs][:sniffs]) do
  repository "https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git"
  reference  "master"
  user "root"
  group "root"
  action :sync
end

execute "echo 'export PATH=~/.composer/vendor/bin:$PATH' >> #{node[:ctwp][:bash_profile]}" do
  not_if "grep 'export PATH=~/.composer/vendor/bin:$PATH' #{node[:ctwp][:bash_profile]}"
end

execute "phpcs-add-alias" do
  command <<-EOS
    echo 'alias #{node[:ctwp][:phpcs][:alias]}="phpcs -p -s -v --standard=WordPress-Core"' >> #{node[:ctwp][:bash_profile]}
  EOS
  not_if "grep 'alias #{node[:ctwp][:phpcs][:alias]}=' #{node[:ctwp][:bash_profile]}"
end

#
# Allow SSH connection to any host
#
execute "ssh-allow-hosts" do
  command <<-EOS
    echo "Host *\\nStrictHostKeyChecking no\\nUserKnownHostsFile=/dev/null" >> #{node[:ctwp][:ssh_config]}
  EOS

  not_if "grep 'UserKnownHostsFile=/dev/null' #{node[:ctwp][:ssh_config]}"
end

execute "lftp-allow-hosts" do
  command <<-EOS
    echo "\\nset ssl:verify-certificate off" >> #{node[:ctwp][:lftp_config]}
  EOS

  not_if "grep 'set ssl:verify-certificate off' #{node[:ctwp][:lftp_config]}"
end

execute "phpcs-set-config" do
  user  "vagrant"
  group "vagrant"
  command <<-EOS
    /home/vagrant/.composer/vendor/bin/phpcs --config-set installed_paths #{File.join(node[:ctwp][:src_path], node[:ctwp][:phpcs][:sniffs])}
  EOS
end

file node[:ctwp][:bash_profile] do
  owner 'vagrant'
  group 'vagrant'
end

file node[:ctwp][:ssh_config] do
  owner 'vagrant'
  group 'vagrant'
end

