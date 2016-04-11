actions :generate

attribute :domain_name, :kind_of => String, :name_attribute => true
attribute :admin_pwd, :kind_of => String, :default => nil
attribute :username, :kind_of => String, :default => nil

default_action :generate
