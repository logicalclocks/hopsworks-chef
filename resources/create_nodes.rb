actions :create_ssh_nodes, :create_config_nodes

attribute :asadmin_cmd, :kind_of => String, :default => nil
attribute :payara_config, :kind_of => String, :default => nil
attribute :domain_name, :kind_of => String, :default => nil
attribute :password_file, :kind_of => String, :default => nil
attribute :username, :kind_of => String, :default => nil
attribute :admin_port, :kind_of => Integer, :default => 4848
attribute :nodedir, :kind_of => String, :default => nil
attribute :glassfish_user_home, :kind_of => String, :default => nil
attribute :nodes, :kind_of => Array, :default => []