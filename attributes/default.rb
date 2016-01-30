include_attribute "ndb"
include_attribute "spark"
include_attribute "flink"
include_attribute "elastic"
include_attribute "zeppelin"
include_attribute "glassfish"


default[:hopsworks][:user]                    = "glassfish"

node.normal[:glassfish][:variant]             = "payara"
node.normal[:glassfish][:user]                = node[:hopsworks][:user]
node.normal[:hopsworks][:group]               = "glassfish-admin"
node.normal[:glassfish][:group]               = node[:hopsworks][:group]
node.normal[:hopsworks][:admin][:port]        = 4848
node.normal[:hopsworks][:port]                = 8080
node.normal[:glassfish][:admin][:port]        = node[:hopsworks][:admin][:port]
node.normal[:glassfish][:port]                = node[:hopsworks][:port]
node.normal[:glassfish][:version]             = '4.1.152'
node.normal[:glassfish][:base_dir]            = "/usr/local/glassfish"
node.default[:glassfish][:install_dir]          = "/usr/local"
node.normal[:hopsworks][:domains_dir]         = "#{node[:glassfish][:base_dir]}/glassfish/domains"
#node.normal[:glassfish][:domains_dir]         = node[:hopsworks][:domains_dir]
node.normal[:hopsworks][:max_mem]             = 1024
node.normal[:hopsworks][:min_mem]             = 1024
node.normal[:hopsworks][:max_stack_size]      = 512
node.normal[:hopsworks][:max_perm_size]       = 1024
node.normal[:glassfish][:max_mem]             = node[:hopsworks][:max_mem]
node.normal[:glassfish][:min_mem]             = node[:hopsworks][:min_mem]
node.normal[:glassfish][:max_stack_size]      = node[:hopsworks][:max_stack_size]
node.normal[:glassfish][:max_perm_size]       = node[:hopsworks][:max_perm_size]
#node.default[:hopsworks][:package_url]        = node[:download_url] + "/glassfish-#{node[:glassfish][:version]}.zip"
node.default[:hopsworks][:package_url]        = node[:download_url] + "/payara-#{node[:glassfish][:version]}.zip"
node.normal[:glassfish][:package_url]         = node[:hopsworks][:package_url]
default[:hopsworks][:cauth_url]               = "#{node[:download_url]}/otp-auth-1.0.jar"
default[:hopsworks][:war_url]                 = "#{node[:download_url]}/hopsworks.war"

default[:hopsworks][:admin][:user]            = "adminuser"
default[:hopsworks][:admin][:password]        = "adminpw"
default[:glassfish][:cert][:password]         = node[:hopsworks][:admin][:password]

default[:hopsworks][:default][:user]          = "admin@kth.se"
default[:hopsworks][:default][:password]      = "admin"

default[:hopsworks][:twofactor_auth]          = "false"

# # mysql-server may be part of mysql-cluster (ndb)
# default[:mysql][:mysql_bin]               = "#{node[:mysql][:base_dir]}/bin/mysql"
# default[:mysql][:mysql_cnf]               = "#{node[:ndb][:base_dir]}/my.cnf"

default[:hopsworks][:mysql_connector_url]      = "http://snurran.sics.se/hops/mysql-connector-java-5.1.29-bin.jar"

default[:hopsworks][:cert][:cn]             = "sics.se"
default[:hopsworks][:cert][:o]              = "swedish ict"
default[:hopsworks][:cert][:ou]             = "sics"
default[:hopsworks][:cert][:l]              = "kista"
default[:hopsworks][:cert][:s]              = "stockholm"
default[:hopsworks][:cert][:c]              = "se"

 default[:hopsworks][:cert][:password]         = "changeit"
 default[:hopsworks][:master][:password]       = "adminpw"

# default[:bind_address]                    = attribute?('cloud') ? cloud['local_ipv4'] : ipaddress

default[:hopsworks][:public_ips]               = ['10.0.2.15']
default[:hopsworks][:private_ips]              = ['10.0.2.15']

default[:kagent][:enabled]                     = "false"

default[:hopsworks][:smtp]                     = "smtp.gmail.com"
default[:hopsworks][:gmail][:email]            = "hopsworks@gmail.com"
default[:hopsworks][:gmail][:password]         = "password"
default[:hopsworks][:gmail][:placeholder]      = "http://snurran.sics.se/hops/hopsworks.email"

# #quotas
default[:hopsworks][:yarn_default_quota]       = "250"
default[:hopsworks][:hdfs_default_quota]       = "100"
default[:hopsworks][:max_num_proj_per_user]    = "40"

node.normal[:hadoop][:user_envs]               = "false"
