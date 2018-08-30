Vagrant.configure("2") do |config|

    config.ssh.insert_key = false
    config.vm.box = "bento/ubuntu-16.04"
    config.vm.box_version = "2.3.5"
    config.vm.box_check_update = false
    config.vm.boot_timeout =3600

    # Enable Hostmanager to manage /etc/hosts
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = false
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.vm.define 'hopsworks0' do |node|
    	node.vm.hostname = 'hopsworks0'
        node.vm.network "private_network", ip: "10.0.2.15"
    end

    config.vm.network :forwarded_port, guest: 22, host: 10022, id: "ssh"
    # MySQL Server
    config.vm.network(:forwarded_port, {:guest=>3306, :host=>3306})
    # karamel http
    config.vm.network(:forwarded_port, {:guest=>9090, :host=>9090})
    # Hopsworks http
    config.vm.network(:forwarded_port, {:guest=>8080, :host=>8080})
    # Glassfish debug port
    config.vm.network(:forwarded_port, {:guest=>9009, :host=>9009})
    # Glassfish admin UI
    config.vm.network(:forwarded_port, {:guest=>4848, :host=>4848})
    # Yarn RM
    config.vm.network(:forwarded_port, {:guest=>8088, :host=>8088})
    # Kibana
    config.vm.network(:forwarded_port, {:guest=>5601, :host=>5601})
    # Grafana Webserver
    config.vm.network(:forwarded_port, {:guest=>3000, :host=>3000})
    # Nodemanager
    config.vm.network(:forwarded_port, {:guest=>8083, :host=>8083})
    # Influx DB admin (because of clash with nodemanager)
    config.vm.network(:forwarded_port, {:guest=>8084, :host=>8084})
    # Influx DB REST API
    config.vm.network(:forwarded_port, {:guest=>8086, :host=>8086})
    # Graphite Endpoint
    config.vm.network(:forwarded_port, {:guest=>2003, :host=>2003})
    # Jupyter
    config.vm.network(:forwarded_port, {:guest=>8888, :host=>8888})
    # membrane proxy
    config.vm.network(:forwarded_port, {:guest=>11112, :host=>11112})


    config.vm.provision "file", source: "~/.vagrant.d/insecure_private_key", destination: "~/.ssh/id_rsa"
    config.vm.provision "shell", inline: "cp /home/vagrant/.ssh/authorized_keys /home/vagrant/.ssh/id_rsa.pub && sudo chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub"

    config.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", 7000]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--nictype1", "virtio"]
      v.customize ["modifyvm", :id, "--name", "hopsworks0"]
      v.customize ["modifyvm", :id, "--cpus", "3"]
    end

   config.vm.provision :chef_solo do |chef|
     chef.channel = "stable"
     chef.cookbooks_path = "cookbooks"
     chef.json = {
     "ntp" => {
          "install" => "true",
     },
     "install" => {
  	  "user" => "vagrant",
          "dir" => "/srv/hops",
     },
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
	"war_url" => "http://snurran.sics.se/hops/hopsworks/0.1.0/hopsworks-jim.war",
	"ear_url" => "http://snurran.sics.se/hops/hopsworks/0.1.0/hopsworks-ear-jim.ear",
        "user_envs" => "false",
        "twofactor_auth" => "false",
#        "anaconda_enabled" => "false",
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
     },
     "hadoop_spark" => {
	  "master" =>    {
       	 	      "private_ips" => ["10.0.2.15"]
          },
	  "worker" =>    {
       	 	      "private_ips" => ["10.0.2.15"]
          }
     },
     "kzookeeper" => {
	  "default" =>      {
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "livy" => {
	  "default" =>      {
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "epipe" => {
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
                   "interface" => "eth0"
          },
          "allow_ssh_access" => "true",
          "enabled" => "true",
	  "default" =>      {
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "kkafka" => {
	  "default" =>      {
   	  	       "private_ips" => ["10.0.2.15"]
	       },
     },
     "cuda" => {
	  "enabled": "false",
     },
     "conda" => {
	  "user": "vagrant",
     },

     "vagrant" => "true",
     }

      chef.add_recipe "kagent::install"
      chef.add_recipe "hopsworks::install"
      chef.add_recipe "tensorflow::install"
      chef.add_recipe "hops::install"
      chef.add_recipe "hopslog::install"
      chef.add_recipe "hopsmonitor::install"
      chef.add_recipe "ndb::install"
      chef.add_recipe "hadoop_spark::install"
      chef.add_recipe "flink::install"
      chef.add_recipe "zeppelin::install"
      chef.add_recipe "elastic::install"
      chef.add_recipe "kzookeeper::install"
      chef.add_recipe "epipe::install"
      chef.add_recipe "livy::install"
      chef.add_recipe "adam::install"
      chef.add_recipe "drelephant::install"
      chef.add_recipe "kkafka::install"
      chef.add_recipe "kagent::default"
      chef.add_recipe "ndb::mgmd"
      chef.add_recipe "ndb::ndbd"
      chef.add_recipe "ndb::mysqld"
      chef.add_recipe "hops::ndb"
      chef.add_recipe "hops::rm"
      chef.add_recipe "hops::nn"
      chef.add_recipe "hops::jhs"
      chef.add_recipe "hadoop_spark::yarn"
      chef.add_recipe "hadoop_spark::historyserver"
      chef.add_recipe "flink::yarn"
      chef.add_recipe "elastic::default"
      chef.add_recipe "livy::default"
      chef.add_recipe "zeppelin::default"
      chef.add_recipe "kzookeeper::default"
      chef.add_recipe "kkafka::default"
      chef.add_recipe "epipe::default"
      chef.add_recipe "hopsworks::default"
      chef.add_recipe "hopsworks::dev"
      chef.add_recipe "hopsmonitor::default"
      chef.add_recipe "hopslog::default"
      chef.add_recipe "hops::dn"
      chef.add_recipe "hops::nm"
      chef.add_recipe "tensorflow::default"
      chef.add_recipe "hopsmonitor::telegraf"

  end

end
