# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-25

# !!! For Linux you need to install "nfs" package !!!
# Ubuntu: apt-get -y install nfs-kernel-server nfs-common
# CentOS: yum -y install nfs-utils nfs-utils-lib

HOSTNAME = 'wordpress.codetiburon.local'
IP_ADDRESS = '192.168.33.10'

CHEF_DIR = './chef'
DOCUMENT_ROOT = '/vagrant/wordpress'

# Wordpress database tables prefix ('wp_' by default)
DB_NAME = 'wordpress'
TABLE_PREFIX = 'wp_'

# MySQL password for root user
ROOT_PASSWORD = 'root'

Vagrant.require_version '>= 1.5'
Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.box_url = 'https://vagrantcloud.com/ubuntu/trusty64'
  config.ssh.forward_agent = true

  config.vm.hostname = HOSTNAME
  config.vm.network :private_network, :ip => IP_ADDRESS

  if Vagrant::Util::Platform.windows?
    sync_options = {
      :mount_options => ["dmode=775", "fmode=775"]
    }
  else
    sync_options = {
      :nfs => { :mount_options => ["dmode=775", "fmode=775"] }
    }
  end

  config.vm.synced_folder ".", "/vagrant", sync_options

  if Vagrant.has_plugin? 'vagrant-hostmanager'
    # update "host" file for host machine also
    config.hostmanager.manage_host = true
    config.hostmanager.enabled = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  end

  config.vm.provider :virtualbox do |vb|
    vb.name = HOSTNAME
    vb.customize [ 'modifyvm', :id, '--memory', '1024' ]
    vb.customize [ 'modifyvm', :id, '--cpuexecutioncap', '50' ]
    vb.customize [ 'modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize [ 'modifyvm', :id, '--natdnsproxy1', 'on' ]
  end

  config.vm.provision :chef_solo do |chef|
    chef.roles_path = File.join CHEF_DIR, 'roles'
    chef.environments_path = File.join CHEF_DIR, 'environments'
    chef.cookbooks_path = [
      File.join(CHEF_DIR, 'cookbooks'),
      File.join(CHEF_DIR, 'site-cookbooks')
    ]

    chef.add_role 'wordpress'
    chef.environment = "development"

    chef.json = {
      :mysql => {
        :server_root_password => ROOT_PASSWORD,
      },
      :apache => {
        :docroot_dir     => DOCUMENT_ROOT
      },
      :ctwp => {
        :docroot_dir     => DOCUMENT_ROOT,
        :host            => HOSTNAME,
        :dbprefix        => TABLE_PREFIX,
        :dbname          => DB_NAME
      }
    }
  end
end
