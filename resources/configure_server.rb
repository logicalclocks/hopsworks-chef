actions :glassfish_configure_network, :glassfish_configure_monitoring, :glassfish_configure_logging, :glassfish_configure

attribute :domain_name, :kind_of => String, :default => nil
attribute :password_file, :kind_of => String, :default => nil
attribute :username, :kind_of => String, :default => nil
attribute :admin_port, :kind_of => Integer, :default => 4848
attribute :target, :kind_of => String, :default => "server"
attribute :asadmin, :kind_of => String, :default => nil