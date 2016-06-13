
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'docker'

  Vagrant.configure(2) do |config|

  #config.vm.box = "momus/centos-swi-prolog"
  #
  #config.vm.network  = "public_network"
  #config.vm.synced_folder = "." , "/vagrant"
  
  config.vm.provider "docker"  do |docker|

    docker.image = "momus/centos-swi-prolog"
    docker.name = "swi_prolog_devel"
    docker.remains_running = false
  end
end
