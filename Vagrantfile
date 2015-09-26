require 'vagrant-omnibus'

VAGRANTFILE_API_VERSION = "2"

Vagrant::Config.run do |config|

config.omnibus.chef_version = :latest


 config.vm.customize ["modifyvm", :id, "--memory", 9000]
 config.vm.customize ["modifyvm", :id, "--cpus", "1"]
 
# change the network card hardware for better performance
 config.vm.customize ["modifyvm", :id, "--nictype1", "virtio" ]
# config.vm.customize ["modifyvm", :id, "--nictype2", "virtio" ]

 # suggested fix for slow network performance
 # see https://github.com/mitchellh/vagrant/issues/1807
 config.vm.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
 config.vm.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

 config.vm.box = "bento_14.04" 
 config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
 config.vm.network :bridged
 config.vm.forward_port 3306, 4306
 config.vm.forward_port 8080, 9090
 config.vm.forward_port 8181, 9181
 config.vm.forward_port 4848, 5848
 config.vm.forward_port 50070, 52070
 config.vm.forward_port 50075, 52075

   config.vm.provision :chef_solo, :log_level => :debug do |chef|
     chef.log_level = :debug
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
      chef.add_recipe "hops::nn"
      chef.add_recipe "hops::dn"
      chef.add_recipe "hops::rm"
      chef.add_recipe "hops::nm"
      chef.add_recipe "hops::jhs"
      chef.add_recipe "zeppelin::default"
      chef.add_recipe "spark::master"
      chef.add_recipe "spark::slave"
#      chef.add_recipe "elastic::default"
  end 
end
