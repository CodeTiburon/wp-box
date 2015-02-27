# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-25

packages = %w{git zip unzip gcc perl make jq php5-mysql php5-intl php5-curl php5-gd}
binary = ::File.join(node[:ctwp][:cli][:dir], 'phar', 'wp-cli.phar')

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
  end
end

git node[:ctwp][:cli][:dir] do
  repository "https://github.com/wp-cli/builds.git"
  action :sync
end

file binary do
  mode '0755'
  action :create
end

link node[:ctwp][:cli][:lnk] do
  to binary
end

directory '/home/vagrant/.wp-cli' do
  recursive true
  owner node[:ctwp][:user]
  group node[:ctwp][:group]
end

directory '/home/vagrant/.wp-cli/commands' do
  recursive true
  owner node[:ctwp][:user]
  group node[:ctwp][:group]
end

template '/home/vagrant/.wp-cli/cli.config.yml' do
  source "cli.config.yml.erb"
  owner node[:ctwp][:user]
  group node[:ctwp][:group]
  mode "0644"

  variables(
    :docroot_dir => File.join(node[:ctwp][:docroot_dir], node[:ctwp][:siteurl])
  )
end

git 'home/vagrant/.wp-cli/commands/dictator' do
  repository "https://github.com/danielbachhuber/dictator.git"
  user node[:ctwp][:user]
  group node[:ctwp][:group]
  action :sync
end
