
include_recipe "hops::wrap"

##
## default.rb
##

# If the install.rb recipe was in a different run, the location of the install dir may
# not be correct. install_dir is updated by install.rb, but not persisted, so we need to
# reset it
if node.glassfish.install_dir.include?("versions") == false
  node.override.glassfish.install_dir = node.glassfish.install_dir + "/glassfish/versions/current"
end

private_ip=my_private_ip()
hopsworks_db = "hopsworks"
realmname="kthfsrealm"
#mysql_user=node.mysql.user
#mysql_pwd=node.mysql.password


tables_path = "#{Chef::Config.file_cache_path}/tables.sql"
rows_path = "#{Chef::Config.file_cache_path}/rows.sql"


hopsworks_grants "creds" do
  tables_path  "#{tables_path}"
  rows_path  "#{rows_path}"
  action :nothing
end 

 Chef::Log.info("Could not find previously defined #{tables_path} resource")
 template tables_path do
    source File.basename("#{tables_path}") + ".erb"
    owner node.glassfish.user
    mode 0750
    action :create
    variables({
                :private_ip => private_ip
              })
    notifies :create_tables, 'hopsworks_grants[creds]', :immediately
  end 


begin
  elastic_ip = private_recipe_ip("elastic","default")
rescue 
  elastic_ip = ""
  Chef::Log.warn "could not find elastic server for HopsWorks!"
end


template "#{rows_path}" do
   source File.basename("#{rows_path}") + ".erb"
   owner node.glassfish.user
   mode 0755
   action :create
    variables({
                :elastic_ip => elastic_ip,
                :spark_dir => node.hadoop_spark.dir + "/spark",                
                :spark_user => node.hadoop_spark.user,
                :hadoop_dir => node.apache_hadoop.dir + "/hadoop",                                
                :yarn_user => node.apache_hadoop.yarn.user,
                :hdfs_user => node.apache_hadoop.hdfs.user,
                :mr_user => node.apache_hadoop.mr.user,
                :flink_dir => node.flink.dir + "/flink",
                :flink_user => node.flink.user,
                :zeppelin_dir => node.zeppelin.dir + "/zeppelin",
                :zeppelin_user => node.zeppelin.user,
                :ndb_dir => node.ndb.dir + "/mysql-cluster",
                :mysql_dir => node.mysql.dir + "/mysql",
                :elastic_dir => node.elastic.dir + "/elastic",
                :twofactor_auth => node.hopsworks.twofactor_auth,
                :elastic_user => node.elastic.user,
                :yarn_default_quota => node.hopsworks.yarn_default_quota_mins.to_i * 60,
                :hdfs_default_quota => node.hopsworks.hdfs_default_quota_gbs.to_i * 1024 * 1024 * 1024,
                :max_num_proj_per_user => node.hopsworks.max_num_proj_per_user
              })
   notifies :insert_rows, 'hopsworks_grants[creds]', :immediately
end



###############################################################################
# config glassfish
###############################################################################

username=node.hopsworks.admin.user
password=node.hopsworks.admin.password
domain_name="domain1"
domains_dir = node.glassfish.domains_dir
admin_port = 4848
mysql_host = private_recipe_ip("ndb","mysqld")


jndiDB = "jdbc/hopsworks"
timerDB = "jdbc/hopsworksTimers"

asadmin = "#{node.glassfish.base_dir}/versions/current/bin/asadmin"
admin_pwd="#{domains_dir}/#{domain_name}_admin_passwd"



login_cnf="#{domains_dir}/#{domain_name}/config/login.conf"
file "#{login_cnf}" do
   action :delete
end

template "#{login_cnf}" do
  cookbook 'hopsworks'
  source "login.conf.erb"
  owner node.glassfish.user
  group node.glassfish.group
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

 
 cProps = {
     'datasource-jndi' => jndiDB,
     'password-column' => 'password',
     'encoding' => 'Hex',
     'group-table' => 'hopsworks.users_groups',
     'user-table' => 'hopsworks.users',
     'group-name-column' => 'group_name',
     'user-name-column' => 'email',
     'group-table-user-name-column' => 'email',
     'otp-secret-column' => 'secret',
     'user-status-column' => 'status',
     'yubikey-table' => 'hopsworks.yubikey',
     'variables-table' => 'hopsworks.variables'
 }
 
 glassfish_auth_realm "cauthRealm" do 
   realm_name "cauthRealm"
   jaas_context "cauthRealm"
   properties cProps
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
   classname "se.kth.bbc.crealm.CustomAuthRealm"
 end

 

glassfish_asadmin "set server-config.security-service.default-realm=cauthRealm" do
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

glassfish_asadmin "set server.http-service.virtual-server.server.property.send-error_1=\"code=404 path=#{domains_dir}/#{domain_name}/docroot/404.html reason=Resource_not_found\"" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

if node.hopsworks.gmail.password .eql? "password"

  bash 'gmail' do
    user "root"
    code <<-EOF
      cd /tmp
      rm -f /tmp/hopsworks.email 
      wget #{node.hopsworks.gmail.placeholder} 
      cat /tmp/hopsworks.email | base64 -d > /tmp/hopsworks.encoded
      chmod 775 /tmp/hopsworks.encoded
    EOF
  end

end



hopsworks_mail "gmail" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   action :jndi
end 




glassfish_deployable "hopsworks" do
  component_name "hopsworks"
  url node.hopsworks.war_url
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
#   owner node.glassfish.user

#   group node.glassfish.group
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
#   owner node.glassfish.user
#   mode 0750
#   action :create
# end 
 template "/bin/hopsworks-2fa" do
    source "hopsworks-2fa.erb"
    owner "root"
    mode 0700
    action :create
 end 



 # Directory for RS erasure coded data
for d in %w{ /raidrs /parity }
  # apache_hadoop_hdfs_directory "#{d}" do
  #   action :create_as_superuser
  #   owner node.apache_hadoop.hdfs.user
  #   group node.apache_hadoop.group
  #   mode "1777"
  #   not_if ". #{node.hadoop.home}/sbin/set-env.sh && #{node.apache_hadoop.home}/bin/hdfs dfs -test -d #{d}"
  # end
end
