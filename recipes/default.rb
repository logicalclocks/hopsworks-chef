require 'json'
node.override = {
  'java' => {
    'install_flavor' => 'oracle',
    'jdk_version' => 7,
    'oracle' => {
      'accept_oracle_download_terms' => true
    }
  }
}
include_recipe 'glassfish::default'

bash 'fix_java_path_for_glassfish_cookbook' do
user "root"
    code <<-EOF
# upstart job in glassfish expects java to be installed in /bin/java
test -f /usr/bin/java && ln -sf /usr/bin/java /bin/java 
EOF
end


private_ip=my_private_ip()
hopsworks_db = "hopsworks"
realmname="kthfsrealm"
mysql_user=node[:mysql][:user]
mysql_pwd=node[:mysql][:password]


tables_path = "#{Chef::Config[:file_cache_path]}/tables.sql"
rows_path = "#{Chef::Config[:file_cache_path]}/rows.sql"


hopsworks_grants "creds" do
  tables_path  "#{tables_path}"
  rows_path  "#{rows_path}"
  action :nothing
end 

 Chef::Log.info("Could not find previously defined #{tables_path} resource")
 template tables_path do
    source File.basename("#{tables_path}") + ".erb"
    owner node[:glassfish][:user]
    mode 0750
    action :create
    variables({
                :private_ip => private_ip
              })
    notifies :create_tables, 'hopsworks_grants[creds]', :immediately
  end 


elastic_ip = private_recipe_ip("elastic","default")

template "#{rows_path}" do
   source File.basename("#{rows_path}") + ".erb"
   owner node[:glassfish][:user]
   mode 0755
   action :create
    variables({
                :elastic_ip => elastic_ip,
                :spark_dir => node[:spark][:dir] + "/spark",                
                :spark_user => node[:spark][:user],
                :hadoop_dir => node[:hadoop][:dir] + "/hadoop",                                
                :yarn_user => node[:hadoop][:yarn][:user],
                :hdfs_user => node[:hdfs][:user],
                :mr_user => node[:hadoop][:mr][:user],
                :flink_dir => node[:flink][:dir] + "/flink",
                :flink_user => node[:flink][:user],
                :zeppelin_dir => node[:zeppelin][:dir] + "/zeppelin",
                :zeppelin_user => node[:zeppelin][:user],
                :ndb_dir => node[:ndb][:dir] + "/mysql-cluster",
                :mysql_dir => node[:mysql][:dir] + "/mysql",
                :elastic_dir => node[:elastic][:dir] + "/elastic",
                :twofactor_auth => node[:twofactor_auth],
                :elastic_user => node[:elastic][:user]
              })
   notifies :insert_rows, 'hopsworks_grants[creds]', :immediately
end



###############################################################################
# config glassfish
###############################################################################

username=node[:hopsworks][:admin][:user]
password=node[:hopsworks][:admin][:password]
domain_name="domain1"
domains_dir = node[:glassfish][:domains_dir]
admin_port = 4848
mysql_host = private_recipe_ip("ndb","mysqld")


jndiDB = "jdbc/hopsworks"
timerDB = "jdbc/hopsworksTimers"

asadmin = "#{node[:glassfish][:base_dir]}/versions/current/bin/asadmin"
admin_pwd="#{domains_dir}/#{domain_name}_admin_passwd"



login_cnf="#{domains_dir}/#{domain_name}/config/login.conf"
file "#{login_cnf}" do
   action :delete
end

template "#{login_cnf}" do
  cookbook 'hopsworks'
  source "login.conf.erb"
  owner node[:glassfish][:user]
  group node[:glassfish][:group]
  mode "0600"
end

glassfish_secure_admin domain_name do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :enable
end


props =  { 
  'datasource-jndi' => jndiDB,
  'password-column' => 'password',
  'group-table' => 'hopsworks.users_groups',
  'user-table' => 'hopsworks.users',
  'group-name-column' => 'group_name',
  'user-name-column' => 'email',
  'group-table-user-name-column' => 'email',
  'encoding' => 'Hex',
  'digestrealm-password-enc-algorithm' => 'SHA-256',
  'digest-algorithm' => 'SHA-256'
}

 glassfish_auth_realm "#{realmname}" do 
   realm_name "#{realmname}"
   jaas_context "jdbcRealm"
   properties props
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
   classname "com.sun.enterprise.security.auth.realm.jdbc.JDBCRealm"
 end


glassfish_asadmin "set server-config.security-service.default-realm=#{realmname}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


# Jobs in Hopsworks use the Timer service
glassfish_asadmin "set server-config.ejb-container.ejb-timer-service.timer-datasource=#{timerDB}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


# Avoid empty property values - glassfish will crash otherwise
if node[:hopsworks][:gmail][:email].empty?
  node.default[:hopsworks][:gmail][:email]="none"
end

if node[:hopsworks][:gmail][:password].empty?
  node.default[:hopsworks][:gmail][:password]="empty"
end


gmailProps = {
  'mail-smtp-host' => 'smtp.gmail.com',
  'mail-smtp-user' => "#{node[:hopsworks][:gmail][:email]}",
  'mail-smtp-password' => "#{node[:hopsworks][:gmail][:password]}",
  'mail-smtp-auth' => 'true',
  'mail-smtp-port' => '587',
  'mail-smtp-socketFactory-port' => '465',
  'mail-smtp-socketFactory-class' => 'javax.net.ssl.SSLSocketFactory',
  'mail-smtp-starttls-enable' => 'true',
  'mail.smtp.ssl.enable' => 'false',
  'mail-smtp-socketFactory-fallback' => 'false'
}



 glassfish_javamail_resource "gmail" do 
   jndi_name "mail/BBCMail"
   mailuser node[:hopsworks][:gmail][:email]
   mailhost "smtp.gmail.com"
   fromaddress node[:hopsworks][:gmail][:email]
   properties gmailProps
   domain_name domain_name
   password_file admin_pwd
   username username
   admin_port admin_port
   secure false
   action :create
 end


glassfish_deployable "hopsworks" do
  component_name "hopsworks"
  url node[:hopsworks][:war_url]
  context_root "/hopsworks"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 2
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w 'hopsworks'"
end


# directory "/srv/users" do
#   owner node[:glassfish][:user]

#   group node[:glassfish][:group]
#   mode "0755"
#   action :create
#   recursive true
# end


# template "/srv/mkuser.sh" do
# case node['platform']
# when 'debian', 'ubuntu'
#     source "mkuser.sh.erb"
# when 'redhat', 'centos', 'fedora'
#     source "mkuser.redhat.sh.erb"
# end
#   owner node[:glassfish][:user]
#   mode 0750
#   action :create
# end 
