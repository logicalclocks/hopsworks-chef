
Vagrant.configure("2") do |c|
  if Vagrant.has_plugin?("vagrant-omnibus")
#    require 'vagrant-omnibus'
    c.omnibus.chef_version = "12.4.3"
  end
  if Vagrant.has_plugin?("vagrant-cachier")
    c.omnibus.cache_packages = true        
    c.cache.scope = :machine
    c.cache.auto_detect = false
    c.cache.enable :apt
    c.cache.enable :gem    
  end
#  c.vm.box = "bento/ubuntu-16.04"
  c.vm.box = "opscode-ubuntu-14.04"
  c.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box"
#   c.vm.box = "bento/centos-7.2"
#  c.vm.box_url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20150924.0.0/providers/virtualbox.box"
#  c.vm.hostname = "default-ubuntu-1404.vagrantup.com"
 
   
  c.ssh.insert_key="false"
# Ssh port on vagrant
  c.vm.network(:forwarded_port, {:guest=>22, :host=>27011})
  c.vm.network(:forwarded_port, {:guest=>8090, :host=>26011})
# MySQL Server
  c.vm.network(:forwarded_port, {:guest=>9090, :host=>13011})

  c.vm.network(:forwarded_port, {:guest=>3306, :host=>20011})
# HTTP webserver
  c.vm.network(:forwarded_port, {:guest=>8080, :host=>14011})
# HTTPS webserver
  c.vm.network(:forwarded_port, {:guest=>8181, :host=>55011})
# Glassfish webserver
  c.vm.network(:forwarded_port, {:guest=>4848, :host=>16011})
# HDFS webserver
  c.vm.network(:forwarded_port, {:guest=>50070, :host=>22011})
# Datanode
  c.vm.network(:forwarded_port, {:guest=>50075, :host=>50011})
# YARN webserver
  c.vm.network(:forwarded_port, {:guest=>8088, :host=>17011})
# Elasticsearch rpc port
  c.vm.network(:forwarded_port, {:guest=>9200, :host=>9211})
# Flink webserver
  c.vm.network(:forwarded_port, {:guest=>9088, :host=>9011})
# Glassfish Debugger port
  c.vm.network(:forwarded_port, {:guest=>9009, :host=>19011})
# Ooozie port
  c.vm.network(:forwarded_port, {:guest=>11000, :host=>25011})
# Dr Elephant
#  c.vm.network(:forwarded_port, {:guest=>11011, :host=>11011})
# Spark History Server
  c.vm.network(:forwarded_port, {:guest=>18080, :host=>18011})
# Kibana Server
  c.vm.network(:forwarded_port, {:guest=>5601, :host=>15011})
# Grafana Server
  c.vm.network(:forwarded_port, {:guest=>3000, :host=>23011})
# Graphite WebServer
  c.vm.network(:forwarded_port, {:guest=>3000, :host=>24011})
# Logstash Server
#  c.vm.network(:forwarded_port, {:guest=>3000, :host=>8181})
  
  c.vm.provider :virtualbox do |p|
    p.customize ["modifyvm", :id, "--memory", "15000"]
    p.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    p.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    p.customize ["modifyvm", :id, "--nictype1", "virtio"]
    p.customize ["modifyvm", :id, "--cpus", "2"]   
  end


   c.vm.provision :chef_solo do |chef|
     chef.cookbooks_path = "cookbooks"
     chef.json = {
     "ntp" => {
          "install" => "true",
#          "user" => "glassfish",
     },
     "install" => {
          "dir" => "/srv/hops"
     },
     "ndb" => {
          "user" => "mysql",
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
#	"war_url" => "http://snurran.sics.se/hops/hopsworks-0.1.0.war",
        "user_envs" => "false",
        "twofactor_auth" => "false",
#        "anaconda_enabled" => "false",        
     },
     "zeppelin" => {
          "user" => "glassfish",
          "group" => "glassfish",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "elastic" => {
          "user" => "glassfish",
          "group" => "glassfish",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
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
     	        "hdfs" => {
                      "user" => "glassfish"
                 },
     	        "yarn" => {
		      "user" => "glassfish"
		 },
		 "mr" => {
		      "user" => "glassfish"
                 },
      },
     "flink"  =>    {
	  "user" => "glassfish",
          "group" => "glassfish",
     },
     "adam"  =>    {
	  "user" => "glassfish",
          "group" => "glassfish",
     },
     "hadoop_spark" => {
	  "version" => "2.1.0",
	  "user" => "glassfish",
          "group" => "glassfish",
	  "master" =>    { 
       	 	      "private_ips" => ["10.0.2.15"]
          },
	  "worker" =>    { 
       	 	      "private_ips" => ["10.0.2.15"]
          }
     },
     "kzookeeper" => {
	  "user" => "glassfish",
          "group" => "glassfish",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "livy" => {
	  "user" => "glassfish",
          "group" => "glassfish",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "epipe" => {
	  "user" => "glassfish",
          "group" => "glassfish",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "kibana" => {
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "hopsmonitor" => {
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "hopslog" => {
     },
     "drelephant" => {
	  "user" => "glassfish",
          "group" => "glassfish",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "dela" => {
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "kagent" => {
          "network" => {
                   "interface" => "enp0s3"
          },
	  "user" => "glassfish",
          "group" => "glassfish",
          "allow_ssh_access" => "true",
          "enabled" => "true",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "kkafka" => {
	  "user" => "glassfish",
          "group" => "glassfish",
	  "default" =>      { 
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "cuda" => {
	  "enabled": "false",
     },
     "vagrant" => "true",
     }

      chef.add_recipe "kagent::install"
      chef.add_recipe "hops::install"
      chef.add_recipe "hopslog::install"
      chef.add_recipe "hopsmonitor::install"      
      chef.add_recipe "hopsworks::install"
      chef.add_recipe "ndb::install"
      chef.add_recipe "hadoop_spark::install"
#      chef.add_recipe "flink::install"
      chef.add_recipe "zeppelin::install"
      chef.add_recipe "elastic::install"
      chef.add_recipe "kzookeeper::install"
      chef.add_recipe "epipe::install"
#      chef.add_recipe "livy::install"
#      chef.add_recipe "adam::install"
#      chef.add_recipe "oozie::install"
      chef.add_recipe "drelephant::install"
      chef.add_recipe "kkafka::install"
#      chef.add_recipe "tensorflow::install"
      chef.add_recipe "ndb::mgmd"
      chef.add_recipe "ndb::ndbd"
      chef.add_recipe "ndb::mysqld"
      chef.add_recipe "hops::ndb"
      chef.add_recipe "hops::nn"
      chef.add_recipe "hops::dn"
      chef.add_recipe "hops::rm"
      chef.add_recipe "hops::nm"
      chef.add_recipe "hops::jhs"
      chef.add_recipe "elastic::default"
      chef.add_recipe "zeppelin::default"
#      chef.add_recipe "flink::yarn"
      chef.add_recipe "hadoop_spark::yarn"
      chef.add_recipe "hadoop_spark::historyserver"
#      chef.add_recipe "livy::default"
      chef.add_recipe "hopslog::default"
      chef.add_recipe "hopsmonitor::default"      
      chef.add_recipe "hopsworks::default"
      chef.add_recipe "hopsmonitor::telegraf"      
#      chef.add_recipe "hopsmonitor::kapacitor"      
      chef.add_recipe "hopsworks::dev"
      chef.add_recipe "epipe::default"
      chef.add_recipe "kzookeeper::default"
#      chef.add_recipe "adam::default"
#      chef.add_recipe "drelephant::default"
      chef.add_recipe "kagent::default"
      chef.add_recipe "kkafka::default"
#      chef.add_recipe "tensorflow::default"
#      chef.add_recipe "oozie::default"

  end 

end
