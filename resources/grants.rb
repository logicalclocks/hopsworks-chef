actions :grants, :kthfs, :creds, :sshkeys

attribute :resource_name, :kind_of => String, :name_attribute => true
attribute :grants_path, :kind_of => String, :default => nil
attribute :kthfs_path, :kind_of => String, :default => nil
attribute :creds_path, :kind_of => String, :default => nil
attribute :graphs_path, :kind_of => String, :default => nil
