actions :create_tables, :insert_rows, :sshkeys, :read_pwd

#attribute :resource_name, :kind_of => String, :name_attribute => true
attribute :tables_path, :kind_of => String, :default => nil
attribute :rows_path, :kind_of => String, :default => nil

default_action :create_tables
