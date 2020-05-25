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
  vms.each_with_index do |vm, idx|
    id = vm[:id]
    box = vm[:box] || id
    id = "#{vm_id_prefix}#{id}" if vm_id_prefix
    config.vm.define(id) do |node|
      node.vm.box = box
      node.vm.box_url = vm[:box_url]
      node.vm.network "private_network", ip: "192.168.35.#{100 + idx}"
      node.vm.synced_folder ".", "/vagrant", type: "nfs",
                            linux__nfs_options: ['rw','no_subtree_check','all_squash','async']

      node.vm.provider("virtualbox") do |virtual_box|
        virtual_box.cpus = n_cpus if n_cpus
        virtual_box.memory = memory if memory
      end
    end
  end
end
