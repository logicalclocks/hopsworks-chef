actions :restart, :alter_tables, :set_404

attribute :alter_path, :kind_of => String, :default => nil
attribute :domain_name, :kind_of => String, :default => nil

default_action :restart
