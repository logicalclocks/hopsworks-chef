actions :create_db, :populate_db, :sshkeys

attribute :resource_name, :kind_of => String, :name_attribute => true
attribute :kthfs_path, :kind_of => String, :default => nil

