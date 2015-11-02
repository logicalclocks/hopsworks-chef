require 'vagrant-omnibus'

Vagrant.configure("2") do |c|

  if Vagrant.has_plugin?("vagrant-cachier")
    c.cache.auto_detect = false
    c.cache.enable :apt
  end
  c.omnibus.cache_packages = false

  c.omnibus.chef_version = "12.4.3"
  c.vm.box = "opscode-ubuntu-14.04"
  c.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20150924.0.0/providers/virtualbox.box"
  c.vm.hostname = "default-ubuntu-1404.vagrantup.com"

# HTTP webserver
  c.vm.network(:forwarded_port, {:guest=>8080, :host=>8080})
# HTTPS webserver
  c.vm.network(:forwarded_port, {:guest=>8081, :host=>8081})
# Glassfish webserver
  c.vm.network(:forwarded_port, {:guest=>4848, :host=>4848})
# HDFS webserver
  c.vm.network(:forwarded_port, {:guest=>50070, :host=>50070})
# 
  c.vm.network(:forwarded_port, {:guest=>50075, :host=>50075})
# YARN webserver
  c.vm.network(:forwarded_port, {:guest=>8088, :host=>8088})
# Elasticsearch rpc port
  c.vm.network(:forwarded_port, {:guest=>9200, :host=>9200})
# Flink webserver
  c.vm.network(:forwarded_port, {:guest=>9088, :host=>9088})

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
                 }
     },
     "hadoop"  =>    {
     	        "yarn" => {
		      "user" => "glassfish"
		 },
		 "mr" => {
		      "user" => "glassfish"
		 },
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
	  "worker" =>    { 
       	 	      "private_ips" => ["10.0.2.15"]
          }
     },
     "zeppelin" => {
	  "user" => "glassfish",
	  "default" =>    { 
       	 	      "private_ips" => ["10.0.2.15"]
          }
     },

     }

      chef.add_recipe "kagent::install"
      chef.add_recipe "ndb::install"
      chef.add_recipe "hops::install"
      chef.add_recipe "hopsworks::install"
      chef.add_recipe "spark::install"
      chef.add_recipe "flink::install"
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
      chef.add_recipe "elastic::default"
      chef.add_recipe "zeppelin::default"
      chef.add_recipe "spark::master"
      chef.add_recipe "spark::worker"
      chef.add_recipe "flink::jobmanager"
      chef.add_recipe "flink::taskmanager"
      chef.add_recipe "hopsworks::default"
  end 


#  c.vm.provision :shell, :path => "bootstrap.sh"
end
