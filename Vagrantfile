require 'vagrant-omnibus'

Vagrant.configure("2") do |c|

  c.omnibus.chef_version = :latest
  c.vm.box = "opscode-ubuntu-14.04"
  c.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
  c.vm.hostname = "default-ubuntu-1404.vagrantup.com"
#  c.vm.network(:forwarded_port, {:guest=>8080, :host=>9191})
#  c.vm.network(:forwarded_port, {:guest=>8181, :host=>8888})
  c.vm.network(:forwarded_port, {:guest=>4848, :host=>4444})
  c.vm.network(:forwarded_port, {:guest=>50070, :host=>51070})
  c.vm.network(:forwarded_port, {:guest=>50075, :host=>51075})
  #c.vm.synced_folder ".", "/vagrant", disabled: true
 # c.ssh.username = 'root'
 # c.ssh.password = 'vagrant'
  c.ssh.insert_key = false

  c.vm.provider :virtualbox do |p|
    p.customize ["modifyvm", :id, "--memory", "9000"]
    p.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    p.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    p.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end


   c.vm.provision :chef_solo do |chef|
     chef.cookbooks_path = "cookbooks"
     chef.json = {
     "vagrant" => "true",
     "ndb" => {
          "mgmd" => { 
     	  	       "private_ips" => ["10.0.2.15"]
	       },
	  "ndbd" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
	  "mysqld" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
	  "memcached" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
          "public_ips" => ["10.0.2.15"],
          "private_ips" => ["10.0.2.15"],
          "enabled" => "true",
     },
     "hopsworks" => {
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
          "user_envs" => "false"
     },
     "zeppelin" => {
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "elastic" => {
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "hdfs" => {
	  "user" => "glassfish"
     },
     "public_ips" => ["10.0.2.15"],
     "private_ips" => ["10.0.2.15"],
     "hops"  =>    {
		 "use_hopsworks" => "true",
		 "rm" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "nn" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "dn" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "nm" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "jhs" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
     "yarn" => {
	  "user" => "glassfish"
     },
     "mr" => {
	  "user" => "glassfish"
     },
      },
     "hadoop"  =>    {
		 "rm" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "nn" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "dn" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "nm" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
		 "jhs" =>    { 
       	  	      "private_ips" => ["10.0.2.15"]
                 },
      },
     "spark" => {
	  "user" => "glassfish",
	  "master" =>    { 
       	 	      "private_ips" => ["10.0.2.15"]
          },
	  "slave" =>    { 
       	 	      "private_ips" => ["10.0.2.15"]
          },
     },

     }

      chef.add_recipe "kagent::install"
      chef.add_recipe "ndb::install"
      chef.add_recipe "hops::install"
      chef.add_recipe "hopsworks::install"
      chef.add_recipe "spark::install"
      chef.add_recipe "zeppelin::install"
      chef.add_recipe "elastic::install"
      chef.add_recipe "ndb::mgmd"
      chef.add_recipe "ndb::ndbd"
      chef.add_recipe "ndb::mysqld"
      chef.add_recipe "hops::ndb"
      chef.add_recipe "hops::nn"
      chef.add_recipe "hops::dn"
      chef.add_recipe "hops::rm"
      chef.add_recipe "hops::nm"
      chef.add_recipe "hops::jhs"
      chef.add_recipe "spark::master"
      chef.add_recipe "spark::slave"
      chef.add_recipe "elastic::default"
      #chef.add_recipe "zeppelin::default"
  end 


  c.vm.provision :shell, :path => "bootstrap.sh"
end
