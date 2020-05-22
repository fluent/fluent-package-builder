# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  vms = [
    {
      :id => "debian-buster-amd64",
      :box => "debian/buster64",
    },
    {
      :id => "ubuntu-18.04-x86_64",
      :box => "ubuntu/bionic64",
    },
    {
      :id => "ubuntu-20.04-x86_64",
      :box => "ubuntu/focal64",
    },
    {
      :id => "centos-6-x86_64",
      :box => "centos/6",
    },
    {
      :id => "centos-7-x86_64",
      :box => "centos/7",
    },
    {
      :id => "centos-8-x86_64",
      :box => "centos/8",
    },
  ]

  vm_id_prefix = ENV["BOX_ID_PREFIX"]
  n_cpus = ENV["BOX_N_CPUS"]&.to_i || 2
  memory = ENV["BOX_MEMORY"]&.to_i || 2048
  synced_folder = ENV["BOX_SYNCED_FOLDER"]
  synced_folder = synced_folder.split(":") if synced_folder
  vms.each do |vm|
    id = vm[:id]
    box = vm[:box] || id
    id = "#{vm_id_prefix}#{id}" if vm_id_prefix
    config.vm.define(id) do |node|
      node.vm.box = box
      node.vm.box_url = vm[:box_url]
      node.vm.synced_folder(*synced_folder) if synced_folder
      node.vm.provider("virtualbox") do |virtual_box|
        virtual_box.cpus = n_cpus if n_cpus
        virtual_box.memory = memory if memory
      end
    end
  end

  config.vm.network "public_network"
end
