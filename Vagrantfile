# Author: Nickolay U. Kofanov
# Company: CodeTiburon
# Date: 2015-02-25

HOSTNAME = 'wordpress.local'
IP_ADDRESS = '192.168.33.10'
SYNC_TYPE = 'nfs' # Synchronization type may be 'nfs' or 'rsync'

# If you want to use 'rsync' synchronization on Linux systems
# Ubuntu: apt-get -y install rsync
# CentOS: yum -y install rsync
# --------
# If you want to use 'nfs' synchronization on Linux systems
# Ubuntu: apt-get -y install nfs-kernel-server nfs-common
# CentOS: yum -y install nfs-utils nfs-utils-lib

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

  ## Shared folders

  if Vagrant::Util::Platform.windows?
    sync_options = {
      :mount_options => ["dmode=776", "fmode=775"],
      :owner => 'vagrant',
      :group => 'vagrant'
    }
  else
    if SYNC_TYPE == 'rsync'
      sync_options = {
        :type => 'rsync',
        :mount_options => ["dmode=775", "fmode=775"],
        :owner => 'vagrant',
        :group => 'vagrant',
        :rsync__args => ['--verbose', '--archive', '-z'],
        :rsync__exclude => ['.git/', '.vagrant/'],
        :rsync__auto => true
      }
    else
      sync_options = {
        :nfs => { :mount_options => ["dmode=776", "fmode=775"] }
      }
    end
  end

  config.vm.synced_folder ".", "/vagrant", sync_options

  unless Vagrant::Util::Platform.windows?
    if !Vagrant.has_plugin? 'vagrant-bindfs'
      raise Vagrant::Errors::VagrantError.new,
        "vagrant-bindfs missing, please install the plugin:\nvagrant plugin install vagrant-bindfs"
    else
      config.bindfs.bind_folder "/vagrant", "/vagrant", u: 'vagrant', g: 'vagrant'
    end
  end

  if Vagrant.has_plugin? 'vagrant-hostmanager'
    # update "host" file for host machine also
    config.hostmanager.manage_host = true
    config.hostmanager.enabled = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  end

  config.vm.provider :virtualbox do |vb|
    host = RbConfig::CONFIG['host_os']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      memory = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      cpus = 1
      memory = 1024
    end

    vb.name = HOSTNAME
    vb.customize [ "modifyvm", :id, "--cpus", cpus ]
    vb.customize [ 'modifyvm', :id, '--memory', memory ]
    vb.customize [ 'modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize [ 'modifyvm', :id, '--natdnsproxy1', 'on' ]
  end

  if Vagrant.has_plugin? 'vagrant-omnibus'
    config.omnibus.chef_version = :latest 
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
