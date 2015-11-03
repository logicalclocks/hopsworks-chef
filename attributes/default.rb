include_attribute "ndb"
include_attribute "spark"
include_attribute "flink"
include_attribute "elastic"
include_attribute "zeppelin"
include_attribute "glassfish"

node.normal[:glassfish][:user]          = "glassfish"
node.normal[:glassfish][:group]         = "glassfish-admin"
node.normal[:glassfish][:admin][:port]  = 4848
node.normal[:glassfish][:port]          = 8080
node.normal[:glassfish][:version]       = '4.1'
node.normal[:glassfish][:base_dir]        = "/usr/local/glassfish"
node.normal[:glassfish][:install_dir]     = "/usr/local/glassfish/versions/current"
node.normal[:glassfish][:domains_dir]     = "#{node[:glassfish][:base_dir]}/glassfish/domains"
node.normal[:glassfish][:max_mem]       = 1024
node.normal[:glassfish][:min_mem]       = 1024
node.normal[:glassfish][:max_stack_size]= 512
node.normal[:glassfish][:max_perm_size] = 1024
#node.normal[:glassfish][:package_url]   = "http://download.java.net/glassfish/#{node[:glassfish][:version]}/release/glassfish-#{node[:glassfish][:version]}.zip"
node.normal[:glassfish][:package_url]   = node[:download_url] + "/glassfish-#{node[:glassfish][:version]}.zip"
default[:glassfish][:cauth_url]           = "#{node[:download_url]}/otp-auth-1.0.jar"

default[:hopsworks][:admin][:user]        = "adminuser"
default[:hopsworks][:admin][:password]    = "adminpw"
default[:glassfish][:cert][:password]     = node[:hopsworks][:admin][:password]

default[:hopsworks][:default][:user]      = "admin@kth.se"
default[:hopsworks][:default][:password]  = "admin"

default[:hopsworks][:twofactor_auth]      = "false"

# mysql-server may be part of mysql-cluster (ndb)
default[:mysql][:mysql_bin]               = "#{node[:mysql][:base_dir]}/bin/mysql"
default[:mysql][:mysql_cnf]               = "#{node[:ndb][:base_dir]}/my.cnf"

default[:hopsworks][:mysql_connector_url] = "http://snurran.sics.se/hops/mysql-connector-java-5.1.29-bin.jar"

default[:karamel][:cert][:cn]             = "hops.kth.se"
default[:karamel][:cert][:o]              = "kth"
default[:karamel][:cert][:ou]             = "ict"
default[:karamel][:cert][:l]              = "kista"
default[:karamel][:cert][:s]              = "stockholm"
default[:karamel][:cert][:c]              = "se"

default[:hopsworks][:cert][:password]     = "changeit"
default[:hopsworks][:master][:password]   = "adminpw"

case node[:hopsworks][:twofactor_auth]
 when "true"
   default[:hopsworks][:war_url]          = "#{node[:download_url]}/hop-dashboard-2pc.war"
 else
   default[:hopsworks][:war_url]          = "#{node[:download_url]}/hopsworks.war"
end

default[:bind_address]                    = attribute?('cloud') ? cloud['local_ipv4'] : ipaddress

default[:hopsworks][:public_ips]          = ['10.0.2.15']
default[:hopsworks][:private_ips]         = ['10.0.2.15']

default[:kagent][:enabled]                = "false"

default[:hopsworks][:smtp]                = "smtp.gmail.com"
default[:hopsworks][:gmail][:email]       = "hopsworks@gmail.com"
default[:hopsworks][:gmail][:password]    = "password"

node.normal[:hadoop][:user_envs]          = "false"

default[:hopsworks][:reinstall]           = "false"

default[:twofactor_auth]                  = "false"
