# One Vagrantfile to rule them all!
#
# This is a generic Vagrantfile that can be used without modification in
# a variety of situations. Hosts and their properties are specified in
# `vagrant-hosts.yml`. Provisioning is done by a shell script in the directory
# PROVISIONING_SCRIPT_DIR with the same name as the host name.
#
# Author: Bert Van Vreckem <https://github.com/bertvv>
#
# See https://github.com/bertvv/vagrant-shell-skeleton/ for details
#

require 'rbconfig'
require 'yaml'

# set default LC_ALL for all BOXES
ENV["LC_ALL"] = "en_US.UTF-8"

# Set your default base box here
DEFAULT_BASE_BOX = 'bento/almalinux-9'

# Directory containing VM provisioning scripts
PROVISIONING_SCRIPT_DIR = 'provisioning/'

#
# No changes needed below this point
#

VAGRANTFILE_API_VERSION = '2'
PROJECT_NAME = '/' + File.basename(Dir.getwd)

hosts = YAML.load_file('vagrant-hosts.yml')

# {{{ Helper functions

def windows_host?
  Vagrant::Util::Platform.windows?
end

# Set options for the network interface configuration. All values are
# optional, and can include:
# - ip (default = DHCP)
# - netmask (default value = 255.255.255.0)
# - mac
# - auto_config (if false, Vagrant will not configure this network interface
# - intnet (if true, an internal network adapter will be created instead of a
# - bridged (if true, vagrant will create a bridged-adapter network adapter for the interface 
#   instead of a host-only adapter). Can be used with optional bridge value.
# - bridge (adapter that will be chosen for the bridged-adapter network (see bridged).)
#   host-only adapter)
def network_options(host)
  options = {}

  if host.key?('ip')
    options[:ip] = host['ip']
    options[:netmask] = host['netmask'] ||= '255.255.255.0'
  else
    options[:type] = 'dhcp'
  end

  options[:mac] = host['mac'].gsub(/[-:]/, '') if host.key?('mac')
  options[:auto_config] = host['auto_config'] if host.key?('auto_config')
  options[:virtualbox__intnet] = true if host.key?('intnet') && host['intnet']
  options[:bridge] = host['bridge'] if host.key?('bridge')
  options
end

def custom_synced_folders(vm, host)
  return unless host.key?('synced_folders')
  folders = host['synced_folders']

  folders.each do |folder|
    vm.synced_folder folder['src'], folder['dest'], folder['options']
  end
end

# Adds forwarded ports to your Vagrant machine
#
# example:
#  forwarded_ports:
#    - guest: 88
#      host: 8080
def forwarded_ports(vm, host)
  if host.has_key?('forwarded_ports')
    ports = host['forwarded_ports']

    ports.each do |port|
      vm.network "forwarded_port", guest: port['guest'], host: port['host']
    end
  end
end

# }}}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  hosts.each do |host|
    config.vm.define host['name'] do |node|
      node.vm.box = host['box'] ||= DEFAULT_BASE_BOX
      node.vm.box_url = host['box_url'] if host.key? 'box_url'
      node.vm.boot_timeout = 600 #Extends time to boot

      node.vm.hostname = host['name']
      
      # - bridged (if true, vagrant will create a bridged-adapter network adapter for the interface 
      #   instead of a host-only adapter)
      
      if host.key?('bridged') && host['bridged']
        node.vm.network :public_network, **network_options(host)
      else
        node.vm.network :private_network, **network_options(host)
      end

      custom_synced_folders(node.vm, host)
      forwarded_ports(node.vm, host) 

      # Use custom login name/password if specified
      node.ssh.username = host['ssh_username'] if host.key? 'ssh_username'
      node.ssh.password = host['ssh_password'] if host.key? 'ssh_password'

      # Add disks to the VM
      if host.key?('disks') && host['disks'].is_a?(Array)
        host['disks'].each do |disk|
          node.vm.disk :disk, name: disk['name'], size: disk['size']
        end
      end

      # - group: name_of_group_in_VBox
      # - name: name of the vm in VBox
      #
      # Add VM to a VirtualBox group
      node.vm.provider :virtualbox do |vb|
        vb.name = host['vm_name']
        vb.gui = host['show_gui'] || false
        vb.memory = host['memory'] if host.key? 'memory'
        vb.cpus = host['cpus'] if host.key? 'cpus'

        # WARNING: if the name of the current directory is the same as the
        # host name, this will fail.
        #
        # Moves the VM to a VirtualBox Group
        group = host['group'] || PROJECT_NAME 
        group = '/' + group unless group.start_with?('/')
        vb.customize ['modifyvm', :id, '--groups', group]
      end
            
      # Run provisioning script for the VM, if it exists.
      #
      # Both .ps1 scripts or .sh scripts can be used for provisioning.
      
      provisioning_script = PROVISIONING_SCRIPT_DIR + host['name'] 

      if File.exist?(provisioning_script + '.sh') 
        provisioning_script = provisioning_script + '.sh'
        node.vm.provision 'shell', path: provisioning_script

      elsif File.exist?(provisioning_script + '.ps1')
        provisioning_script = provisioning_script + '.ps1'
        node.vm.provision 'shell', path: provisioning_script
        
      else
        node.vm.post_up_message = "WARNING! No provisioning script found for #{host['name']}"
      end
    end
  end
end

# -*- mode: ruby -*-
# vi: ft=ruby :
