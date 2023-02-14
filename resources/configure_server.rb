actions :glassfish_configure_network, :glassfish_configure_monitoring, :glassfish_configure_logging, :glassfish_configure, :glassfish_configure_realm, :change_node_master_password

attribute :domain_name, :kind_of => String, :default => nil
attribute :domains_dir, :kind_of => String, :default => nil
attribute :password_file, :kind_of => String, :default => nil
attribute :username, :kind_of => String, :default => nil
attribute :admin_port, :kind_of => Integer, :default => 4848
attribute :target, :kind_of => String, :default => "server-config"
attribute :asadmin, :kind_of => String, :default => nil
attribute :admin_pwd, :kind_of => String, :default => nil
attribute :internal_port, :kind_of => Integer, :default => 8182

attribute :nodedir, :kind_of => String, :default => nil
attribute :node_name, :kind_of => String, :default => nil
attribute :current_master_password, :kind_of => String, :default => "changeit"
attribute :override_props, :kind_of => Hash, :default => {}