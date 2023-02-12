actions :glassfish_configure_network, :glassfish_configure_monitoring, :glassfish_configure_logging, :glassfish_configure, :glassfish_configure_realm

attribute :domain_name, :kind_of => String, :default => nil
attribute :domains_dir, :kind_of => String, :default => nil
attribute :password_file, :kind_of => String, :default => nil
attribute :username, :kind_of => String, :default => nil
attribute :admin_port, :kind_of => Integer, :default => 4848
attribute :target, :kind_of => String, :default => "server-config"
attribute :asadmin, :kind_of => String, :default => nil
attribute :admin_pwd, :kind_of => String, :default => nil
attribute :internal_port, :kind_of => Integer, :default => 8182