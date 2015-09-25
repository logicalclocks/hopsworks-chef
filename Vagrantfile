VAGRANTFILE_API_VERSION = "2"

Vagrant::Config.run do |config|

 config.vm.box = "14.04" 
 config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box"
 config.vm.customize ["modifyvm", :id, "--memory", 9000]
 config.vm.customize ["modifyvm", :id, "--cpus", "1"]
 config.vm.network :bridged
 config.vm.forward_port 22, 1022
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
	  "user" => "glassfish"
     },

     }

      chef.add_recipe "kagent::install"
      chef.add_recipe "ndb::install"
      chef.add_recipe "hops::install"
      chef.add_recipe "hopsworks::install"
#      chef.add_recipe "spark::install"
#      chef.add_recipe "zeppelin::install"
      chef.add_recipe "ndb::mgmd"
      chef.add_recipe "ndb::ndbd"
      chef.add_recipe "ndb::mysqld"
      chef.add_recipe "hops::nn"
      chef.add_recipe "hops::dn"
      chef.add_recipe "hops::rm"
      chef.add_recipe "hops::nm"
      chef.add_recipe "hops::jhs"
#      chef.add_recipe "zeppelin::default"
#      chef.add_recipe "spark::master"
#      chef.add_recipe "spark::slave"
  end 

end
