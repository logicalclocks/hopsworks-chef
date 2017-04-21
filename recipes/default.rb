case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.hopsworks.systemd = "false"
 end
end

if node.hopsworks.systemd === "true" 
  systemd = true
else
  systemd = false
end


##
## default.rb
##

# If the install.rb recipe was in a different run, the location of the install dir may
# not be correct. install_dir is updated by install.rb, but not persisted, so we need to
# reset it
if node.glassfish.install_dir.include?("versions") == false
  node.override.glassfish.install_dir = "#{node.glassfish.install_dir}/glassfish/versions/current"
end

domains_dir = node.glassfish.domains_dir
private_ip=my_private_ip()
public_ip=my_public_ip()
hopsworks_db = "hopsworks"
realmname="kthfsrealm"

begin
  elastic_ip = private_recipe_ip("elastic","default")
rescue 
  elastic_ip = ""
  Chef::Log.warn "could not find the elastic server ip for HopsWorks!"
end

begin
  spark_history_server_ip = private_recipe_ip("hadoop_spark","historyserver")
rescue 
  spark_history_server_ip = node.hostname
  Chef::Log.warn "could not find the spark history server ip for HopsWorks!"
end

begin
  oozie_ip = private_recipe_ip("oozie","default")
rescue 
  oozie_ip = node.hostname
  Chef::Log.warn "could not find oozie ip for HopsWorks!"
end

begin
  jhs_ip = private_recipe_ip("hops","jhs")
rescue 
  jhs_ip = node.hostname
  Chef::Log.warn "could not find the MR job history server ip!"
end

begin
  livy_ip = private_recipe_ip("livy","default")
rescue 
  livy_ip = node.hostname
  Chef::Log.warn "could not find livy server ip!"
end

begin
  epipe_ip = private_recipe_ip("epipe","default")
rescue 
  epipe_ip = node.hostname
  Chef::Log.warn "could not find th epipe server ip!"
end

begin
  zk_ip = private_recipe_ip("kzookeeper","default")
rescue 
  zk_ip = node.hostname
  Chef::Log.warn "could not find th zk server ip!"
end

begin
  kafka_ip = private_recipe_ip("kkafka","default")
rescue 
  kafka_ip = node.hostname
  Chef::Log.warn "could not find th kafka server ip!"
end

begin
  drelephant_ip = private_recipe_ip("drelephant","default")
rescue 
  drelephant_ip = node.hostname
  Chef::Log.warn "could not find the dr elephant server ip!"
end

begin
  dela_ip = private_recipe_ip("dela","default")
rescue 
  dela_ip = node.hostname
  Chef::Log.warn "could not find the dela server ip!"
end

begin
  logstash_ip = private_recipe_ip("hopslog","default")
  kibana_ip = private_recipe_ip("hopslog","default")
rescue 
  logstash_ip = node.hostname
  kibana_ip = node.hostname
  Chef::Log.warn "could not find the logstash server ip!"
end

begin
  grafana_ip = private_recipe_ip("hopsmonitor","default")
  influxdb_ip = private_recipe_ip("hopsmonitor","default")
rescue 
  grafana_ip = node.hostname
  influxdb_ip = node.hostname
  Chef::Log.warn "could not find the hopsmonitor server ip!"
end


tables_path = "#{domains_dir}/tables.sql"
views_path = "#{domains_dir}/views.sql"
rows_path = "#{domains_dir}/rows.sql"

hopsworks_grants "hopsworks_tables" do
  tables_path  "#{tables_path}"
  views_path  "#{views_path}"
  rows_path  "#{rows_path}"
  action :nothing
end 

template views_path do
  source File.basename("#{views_path}") + ".erb"
  owner node.glassfish.user
  mode 0750
  action :create
  variables({
               :private_ip => private_ip
              })
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
    notifies :create_tables, 'hopsworks_grants[hopsworks_tables]', :immediately
end 

timerTable = "ejbtimer_mysql.sql"
timerTablePath = "#{Chef::Config.file_cache_path}/#{timerTable}"

hopsworks_grants "timers_tables" do
  tables_path  "#{timerTablePath}"
  rows_path  ""
  action :nothing
end 


template timerTablePath do
  source File.basename("#{timerTablePath}") + ".erb"
  owner node.glassfish.user
  mode 0750
  action :create
  notifies :create_timers, 'hopsworks_grants[timers_tables]', :immediately
end 



hosts = ""

for h in node.kagent[:default][:private_ips]
  hosts += "('" + h + "','" + h + "')" + ","
end
if h.length > 0 
  hosts = hosts.chop!
end

template "#{rows_path}" do
   source File.basename("#{rows_path}") + ".erb"
   owner node.glassfish.user
   mode 0755
   action :create
    variables({
                :hosts => hosts,
                :epipe_ip => epipe_ip,
                :livy_ip => livy_ip,
                :jhs_ip => jhs_ip,
                :oozie_ip => oozie_ip,
                :spark_history_server_ip => spark_history_server_ip,
                :elastic_ip => elastic_ip,
                :spark_dir => node.hadoop_spark.dir + "/spark",                
                :spark_user => node.hadoop_spark.user,
                :hadoop_dir => node.hops.dir + "/hadoop",                                
                :yarn_user => node.hops.yarn.user,
                :yarn_ui_ip => public_recipe_ip("hops","rm"),
                :yarn_ui_port => node.default.yarn.rm.web.port,
                :hdfs_user => node.hops.hdfs.user,
                :mr_user => node.hops.mr.user,
                :flink_dir => node.flink.dir + "/flink",
                :flink_user => node.flink.user,
                :zeppelin_dir => node.zeppelin.dir + "/zeppelin",
                :zeppelin_user => node.zeppelin.user,
                :ndb_dir => node.ndb.dir + "/mysql-cluster",
                :mysql_dir => node.mysql.dir + "/mysql",
                :elastic_dir => node.elastic.dir + "/elastic",
                :hopsworks_dir => domains_dir,
                :twofactor_auth => node.hopsworks.twofactor_auth,
                :twofactor_exclude_groups => node.hopsworks.twofactor_exclude_groups,
                :elastic_user => node.elastic.user,
                :yarn_default_quota => node.hopsworks.yarn_default_quota_mins.to_i * 60,
                :hdfs_default_quota => node.hopsworks.hdfs_default_quota_mbs.to_i,
                :max_num_proj_per_user => node.hopsworks.max_num_proj_per_user,
		:file_preview_image_size => node.hopsworks.file_preview_image_size,
		:file_preview_txt_size => node.hopsworks.file_preview_txt_size,
                :zk_ip => zk_ip,
                :dela_ip => dela_ip,
                :dela_port => node.dela.http_port,
                :kafka_ip => kafka_ip,                
                :kafka_num_replicas => node.hopsworks.kafka_num_replicas,
                :kafka_num_partitions => node.hopsworks.kafka_num_partitions,
                :drelephant_port => node.drelephant.port,
                :drelephant_db => node.drelephant.db,                
                :drelephant_ip => drelephant_ip,
                :kafka_user => node.kkafka.user,
                :kibana_ip => kibana_ip,
                :logstash_ip => logstash_ip,
                :grafana_ip => grafana_ip,
                :influxdb_ip => influxdb_ip,
                :influxdb_port => node.influxdb.http.port,
                :influxdb_user => node.influxdb.db_user,
                :influxdb_password => node.influxdb.db_password,
                :graphite_port => node.influxdb.graphite.port,
                :anaconda_dir => node.conda.base_dir,
                :public_ip => public_ip
              })
   notifies :insert_rows, 'hopsworks_grants[hopsworks_tables]', :immediately
end



###############################################################################
# config glassfish
###############################################################################

username=node.hopsworks.admin.user
password=node.hopsworks.admin.password
domain_name="domain1"
admin_port = 4848
mysql_host = private_recipe_ip("ndb","mysqld")


jndiDB = "jdbc/hopsworks"
timerDB = "jdbc/hopsworksTimers"

asadmin = "#{node.glassfish.base_dir}/versions/current/bin/asadmin"
admin_pwd="#{domains_dir}/#{domain_name}_admin_passwd"

password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

login_cnf="#{domains_dir}/#{domain_name}/config/login.conf"
log4j_cnf="#{domains_dir}/#{domain_name}/config/log4j.properties"

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

file "#{log4j_cnf}" do
   action :delete
end

template "#{log4j_cnf}" do
  cookbook 'hopsworks'
  source "log4j.properties.erb"
  owner node.glassfish.user
  group node.glassfish.group
end


hopsworks_grants "reload_sysv" do
 tables_path  ""
 rows_path  ""
 action :reload_sysv
end 


glassfish_secure_admin domain_name do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :enable
end


#end



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
     'two-factor-column' => 'two_factor',
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


glassfish_asadmin "set server.network-config.protocols.protocol.http-listener-2.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_asadmin "set server.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Disable SSLv3 on iiop-listener.ssl
glassfish_asadmin "set server.iiop-service.iiop-listener.SSL.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Disable SSLv3 on iiop-muth_listener.ssl
glassfish_asadmin "set server.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Restrict ciphersuite
glassfish_asadmin "set configs.config.server-config.network-config.protocols.protocol.http-listener-2.ssl.ssl3-tls-ciphers=#{node.glassfish.ciphersuite}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Restrict ciphersuite
glassfish_asadmin "set configs.config.server-config.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-tls-ciphers=#{node.glassfish.ciphersuite}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Restrict ciphersuite
glassfish_asadmin "set configs.config.server-config.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-tls-ciphers=#{node.glassfish.ciphersuite}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


# Needed by Shibboleth
glassfish_asadmin "create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-http-listeners | grep 'jk-connect'"
end

# Needed by Shibboleth
glassfish_asadmin "set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


#
# Enable Single Sign on
#

glassfish_asadmin "set server-config.http-service.virtual-server.server.property.sso-enabled='true'" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# glassfish_asadmin "set default-config.http-service.virtual-server.server.property.sso-enabled='true'" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


# glassfish_asadmin "set cluster.availability-service.web-container-availability.sso-failover-enabled=true" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


glassfish_asadmin "set server-config.http-service.virtual-server.server.property.sso-max-inactive-seconds=300" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_asadmin "set server-config.http-service.virtual-server.server.property.sso-reap-interval-seconds=60" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_asadmin "set server-config.http-service.virtual-server.server.property.ssoCookieSecure=no" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_asadmin "set default-config.http-service.virtual-server.server.property.ssoCookieSecure=no" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


glassfish_asadmin "create-managed-executor-service --enabled=true --longrunningtasks=true --corepoolsize=10 --maximumpoolsize=50 --keepaliveseconds=60 --taskqueuecapacity=10000 concurrent/kagentExecutorService" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-managed-executor-services | grep 'kagent'"
end



# Needed by AJP and Shibboleth - https://github.com/payara/Payara/issues/350


# cluster="hopsworks"

# glassfish_asadmin "create-cluster #{cluster}" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end

# glassfish_asadmin "#asadmin --host das_host --port das_port create-local-instance --node #{hostname} instance_#{hostname}" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


# glassfish_asadmin "create-local-instance --cluster #{cluster} instance1" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


# TODO - set ejb timer source as a cluster called 'hopsworks'
# https://docs.oracle.com/cd/E18930_01/html/821-2418/beahw.html#gktqo
# glassfish_asadmin "set configs.config.hopsworks-config.ejb-container.ejb-timer-service.timer-datasource=#{timerDB}" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


if node.hopsworks.email_password .eql? "password"

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



node.override['glassfish']['asadmin']['timeout'] = 400

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear"
  target "server"
  url node.hopsworks.ear_url
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w 'hopsworks-ear'"
end




glassfish_deployable "hopsworks" do
  component_name "hopsworks-web"
  target "server"  
  url node.hopsworks.war_url
  context_root "/hopsworks"
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -v hopsworks-ear | grep hopsworks"
end


glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca"
  target "server"
  url node.hopsworks.ca_url
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-applications --type ejb | grep -w hopsworks-ca"
end

template "/bin/hopsworks-2fa" do
    source "hopsworks-2fa.erb"
    owner "root"
    mode 0700
    action :create
 end 

 hopsworks_certs "generate-certs" do
   action :generate
 end





template "#{domains_dir}/#{domain_name}/bin/condasearch.sh" do
  source "condasearch.sh.erb"
  owner node.glassfish.user
  group node.glassfish.group
  mode 0750
  action :create
end

template "#{domains_dir}/#{domain_name}/bin/condalist.sh" do
  source "condalist.sh.erb"
  owner node.glassfish.user
  group node.glassfish.group
  mode 0750
  action :create
end


#
# Disable glassfish service, if node.services.enabled is not set to true
#
if node.services.enabled != "true"

  case node.platform
  when "ubuntu"
    if node.platform_version.to_f <= 14.04
      node.override.hopsworks.systemd = "false"
    end
  end

  if node.hopsworks.systemd == "true"

    service "glassfish-domain1" do
      provider Chef::Provider::Service::Systemd
      supports :restart => true, :stop => true, :start => true, :status => true
      action :disable
    end

  else #sysv

    service "glassfish-domain1" do
      provider Chef::Provider::Service::Init::Debian
      supports :restart => true, :stop => true, :start => true, :status => true
      action :disable
    end
  end

end

homedir = "/home/#{node.hopsworks.user}"

kagent_keys "#{homedir}" do
  cb_user node.hopsworks.user
  cb_group node.hopsworks.group
  action :generate  
end  

kagent_keys "#{homedir}" do
  cb_user node.hopsworks.user
  cb_group node.hopsworks.group
  cb_name "hopsworks"
  cb_recipe "default"  
  action :return_publickey
end  

hopsworks_grants "restart_glassfish" do
  action :reload_systemd
end


case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.hopsworks.systemd = "false"
 end
end

if node.hopsworks.systemd === "true" 
  systemd = true
else
  systemd = false
end


##
## default.rb
##

# If the install.rb recipe was in a different run, the location of the install dir may
# not be correct. install_dir is updated by install.rb, but not persisted, so we need to
# reset it
if node.glassfish.install_dir.include?("versions") == false
  node.override.glassfish.install_dir = "#{node.glassfish.install_dir}/glassfish/versions/current"
end

domains_dir = node.glassfish.domains_dir
private_ip=my_private_ip()
public_ip=my_public_ip()
hopsworks_db = "hopsworks"
realmname="kthfsrealm"

begin
  elastic_ip = private_recipe_ip("elastic","default")
rescue 
  elastic_ip = ""
  Chef::Log.warn "could not find the elastic server ip for HopsWorks!"
end

begin
  spark_history_server_ip = private_recipe_ip("hadoop_spark","historyserver")
rescue 
  spark_history_server_ip = node.hostname
  Chef::Log.warn "could not find the spark history server ip for HopsWorks!"
end

begin
  oozie_ip = private_recipe_ip("oozie","default")
rescue 
  oozie_ip = node.hostname
  Chef::Log.warn "could not find oozie ip for HopsWorks!"
end

begin
  jhs_ip = private_recipe_ip("hops","jhs")
rescue 
  jhs_ip = node.hostname
  Chef::Log.warn "could not find the MR job history server ip!"
end

begin
  livy_ip = private_recipe_ip("livy","default")
rescue 
  livy_ip = node.hostname
  Chef::Log.warn "could not find livy server ip!"
end

begin
  epipe_ip = private_recipe_ip("epipe","default")
rescue 
  epipe_ip = node.hostname
  Chef::Log.warn "could not find th epipe server ip!"
end

begin
  zk_ip = private_recipe_ip("kzookeeper","default")
rescue 
  zk_ip = node.hostname
  Chef::Log.warn "could not find th zk server ip!"
end

begin
  kafka_ip = private_recipe_ip("kkafka","default")
rescue 
  kafka_ip = node.hostname
  Chef::Log.warn "could not find th kafka server ip!"
end

begin
  drelephant_ip = private_recipe_ip("drelephant","default")
rescue 
  drelephant_ip = node.hostname
  Chef::Log.warn "could not find the dr elephant server ip!"
end

begin
  dela_ip = private_recipe_ip("dela","default")
rescue 
  dela_ip = node.hostname
  Chef::Log.warn "could not find the dela server ip!"
end

begin
  logstash_ip = private_recipe_ip("hopslog","default")
  kibana_ip = private_recipe_ip("hopslog","default")
rescue 
  logstash_ip = node.hostname
  kibana_ip = node.hostname
  Chef::Log.warn "could not find the logstash server ip!"
end

begin
  grafana_ip = private_recipe_ip("hopsmonitor","default")
  influxdb_ip = private_recipe_ip("hopsmonitor","default")
rescue 
  grafana_ip = node.hostname
  influxdb_ip = node.hostname
  Chef::Log.warn "could not find the hopsmonitor server ip!"
end


tables_path = "#{domains_dir}/tables.sql"
views_path = "#{domains_dir}/views.sql"
rows_path = "#{domains_dir}/rows.sql"

hopsworks_grants "hopsworks_tables" do
  tables_path  "#{tables_path}"
  views_path  "#{views_path}"
  rows_path  "#{rows_path}"
  action :nothing
end 

template views_path do
  source File.basename("#{views_path}") + ".erb"
  owner node.glassfish.user
  mode 0750
  action :create
  variables({
               :private_ip => private_ip
              })
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
    notifies :create_tables, 'hopsworks_grants[hopsworks_tables]', :immediately
end 

timerTable = "ejbtimer_mysql.sql"
timerTablePath = "#{Chef::Config.file_cache_path}/#{timerTable}"

hopsworks_grants "timers_tables" do
  tables_path  "#{timerTablePath}"
  rows_path  ""
  action :nothing
end 


template timerTablePath do
  source File.basename("#{timerTablePath}") + ".erb"
  owner node.glassfish.user
  mode 0750
  action :create
  notifies :create_timers, 'hopsworks_grants[timers_tables]', :immediately
end 



hosts = ""

for h in node.kagent[:default][:private_ips]
  hosts += "('" + h + "','" + h + "')" + ","
end
if h.length > 0 
  hosts = hosts.chop!
end

template "#{rows_path}" do
   source File.basename("#{rows_path}") + ".erb"
   owner node.glassfish.user
   mode 0755
   action :create
    variables({
                :hosts => hosts,
                :epipe_ip => epipe_ip,
                :livy_ip => livy_ip,
                :jhs_ip => jhs_ip,
                :oozie_ip => oozie_ip,
                :spark_history_server_ip => spark_history_server_ip,
                :elastic_ip => elastic_ip,
                :spark_dir => node.hadoop_spark.dir + "/spark",                
                :spark_user => node.hadoop_spark.user,
                :hadoop_dir => node.hops.dir + "/hadoop",                                
                :yarn_user => node.hops.yarn.user,
                :yarn_ui_ip => public_recipe_ip("hops","rm"),
                :yarn_ui_port => node.default.yarn.rm.web.port,
                :hdfs_user => node.hops.hdfs.user,
                :mr_user => node.hops.mr.user,
                :flink_dir => node.flink.dir + "/flink",
                :flink_user => node.flink.user,
                :zeppelin_dir => node.zeppelin.dir + "/zeppelin",
                :zeppelin_user => node.zeppelin.user,
                :ndb_dir => node.ndb.dir + "/mysql-cluster",
                :mysql_dir => node.mysql.dir + "/mysql",
                :elastic_dir => node.elastic.dir + "/elastic",
                :hopsworks_dir => domains_dir,
                :hopsworks_user => node.hopsworks.user,                
                :twofactor_auth => node.hopsworks.twofactor_auth,
                :twofactor_exclude_groups => node.hopsworks.twofactor_exclude_groups,
                :elastic_user => node.elastic.user,
                :yarn_default_quota => node.hopsworks.yarn_default_quota_mins.to_i * 60,
                :hdfs_default_quota => node.hopsworks.hdfs_default_quota_mbs.to_i,
                :max_num_proj_per_user => node.hopsworks.max_num_proj_per_user,
		:file_preview_image_size => node.hopsworks.file_preview_image_size,
		:file_preview_txt_size => node.hopsworks.file_preview_txt_size,
                :zk_ip => zk_ip,
                :dela_ip => dela_ip,
                :dela_port => node.dela.http_port,
                :kafka_ip => kafka_ip,                
                :kafka_num_replicas => node.hopsworks.kafka_num_replicas,
                :kafka_num_partitions => node.hopsworks.kafka_num_partitions,
                :drelephant_port => node.drelephant.port,
                :drelephant_db => node.drelephant.db,                
                :drelephant_ip => drelephant_ip,
                :kafka_user => node.kkafka.user,
                :kibana_ip => kibana_ip,
                :logstash_ip => logstash_ip,
                :grafana_ip => grafana_ip,
                :influxdb_ip => influxdb_ip,
                :influxdb_port => node.influxdb.http.port,
                :influxdb_user => node.influxdb.db_user,
                :influxdb_password => node.influxdb.db_password,
                :graphite_port => node.influxdb.graphite.port,
                :anaconda_dir => node.conda.base_dir,
                :public_ip => public_ip,
                :hopsworks_ip => private_ip
              })
   notifies :insert_rows, 'hopsworks_grants[hopsworks_tables]', :immediately
end



###############################################################################
# config glassfish
###############################################################################

username=node.hopsworks.admin.user
password=node.hopsworks.admin.password
domain_name="domain1"
admin_port = 4848
mysql_host = private_recipe_ip("ndb","mysqld")


jndiDB = "jdbc/hopsworks"
timerDB = "jdbc/hopsworksTimers"

asadmin = "#{node.glassfish.base_dir}/versions/current/bin/asadmin"
admin_pwd="#{domains_dir}/#{domain_name}_admin_passwd"

password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

login_cnf="#{domains_dir}/#{domain_name}/config/login.conf"
log4j_cnf="#{domains_dir}/#{domain_name}/config/log4j.properties"

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

file "#{log4j_cnf}" do
   action :delete
end

template "#{log4j_cnf}" do
  cookbook 'hopsworks'
  source "log4j.properties.erb"
  owner node.glassfish.user
  group node.glassfish.group
end


hopsworks_grants "reload_sysv" do
 tables_path  ""
 rows_path  ""
 action :reload_sysv
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
     'two-factor-column' => 'two_factor',
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

# Disable SSLv3 on http-listener-2
glassfish_asadmin "set server.network-config.protocols.protocol.http-listener-2.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Disable SSLv3 on http-adminListener
glassfish_asadmin "set server.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Disable SSLv3 on iiop-listener.ssl
glassfish_asadmin "set server.iiop-service.iiop-listener.SSL.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Disable SSLv3 on iiop-muth_listener.ssl
glassfish_asadmin "set server.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-enabled=false" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Restrict ciphersuite
glassfish_asadmin "set configs.config.server-config.network-config.protocols.protocol.http-listener-2.ssl.ssl3-tls-ciphers=#{node.glassfish.ciphersuite}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Restrict ciphersuite
glassfish_asadmin "set configs.config.server-config.network-config.protocols.protocol.sec-admin-listener.ssl.ssl3-tls-ciphers=#{node.glassfish.ciphersuite}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# Restrict ciphersuite
glassfish_asadmin "set configs.config.server-config.iiop-service.iiop-listener.SSL_MUTUALAUTH.ssl.ssl3-tls-ciphers=#{node.glassfish.ciphersuite}" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


# Needed by Shibboleth
glassfish_asadmin "create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-http-listeners | grep 'jk-connect'"
end

# Needed by Shibboleth
glassfish_asadmin "set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


#
# Enable Single Sign on
#

glassfish_asadmin "set server-config.http-service.virtual-server.server.property.sso-enabled='true'" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

# glassfish_asadmin "set cluster.availability-service.web-container-availability.sso-failover-enabled=true" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


glassfish_asadmin "set server-config.http-service.virtual-server.server.property.sso-max-inactive-seconds=300" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_asadmin "set server-config.http-service.virtual-server.server.property.sso-reap-interval-seconds=60" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_asadmin "set server-config.http-service.virtual-server.server.property.ssoCookieSecure=no" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end

glassfish_asadmin "set server-config.http-service.virtual-server.server.property.ssoCookieSecure=yes" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
end


glassfish_asadmin "create-managed-executor-service --enabled=true --longrunningtasks=true --corepoolsize=10 --maximumpoolsize=50 --keepaliveseconds=60 --taskqueuecapacity=10000 concurrent/kagentExecutorService" do
   domain_name domain_name
   password_file "#{domains_dir}/#{domain_name}_admin_passwd"
   username username
   admin_port admin_port
   secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd}  list-managed-executor-services | grep 'kagent'"
end



# Needed by AJP and Shibboleth - https://github.com/payara/Payara/issues/350


# cluster="hopsworks"



# glassfish_asadmin "create-cluster #{cluster}" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end

# glassfish_asadmin "#asadmin --host das_host --port das_port create-local-instance --node #{hostname} instance_#{hostname}" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


# glassfish_asadmin "create-local-instance --cluster #{cluster} instance1" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


# TODO - set ejb timer source as a cluster called 'hopsworks'
# https://docs.oracle.com/cd/E18930_01/html/821-2418/beahw.html#gktqo
# glassfish_asadmin "set configs.config.hopsworks-config.ejb-container.ejb-timer-service.timer-datasource=#{timerDB}" do
#    domain_name domain_name
#    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
#    username username
#    admin_port admin_port
#    secure false
# end


  bash 'enable_sso' do
    user "root"
    code <<-EOF
      sleep 10
      curl --data "email=admin@kth.se&password=admin&otp=" http://localhost:8080/hopsworks-api/api/auth/login/
      curl --insecure --user #{username}:#{password} -s https://localhost:4848/asadmin
    EOF
  end



#
# https://github.com/jupyter-incubator/sparkmagic
#
bash "jupyter-sparkmagic" do
    user "root"
    code <<-EOF
    set -e
    pip install jupyter
    pip install sparkmagic
    jupyter nbextension enable --py --sys-prefix widgetsnbextension 
EOF
end

pythondir=""
case node['platform']
 when 'debian', 'ubuntu'
# "/usr/lib/python2.7/dist-packages"
  pythondir="/usr/local/lib/python2.7/dist-packages"
 when 'redhat', 'centos', 'fedora'
  pythondir="/usr/lib/python2.7/site-packages"
end

bash "jupyter-sparkmagic-kernels" do
  user "root"
  code <<-EOF
    set -e
    cd #{pythondir}
    jupyter-kernelspec install sparkmagic/kernels/sparkkernel
    jupyter-kernelspec install sparkmagic/kernels/pysparkkernel
    jupyter-kernelspec install sparkmagic/kernels/pyspark3kernel
    jupyter-kernelspec install sparkmagic/kernels/sparkrkernel
    
    jupyter serverextension enable --py sparkmagic
    mkdir -p #{node.hopsworks.domains_dir}/.sparkmagic
    chown #{node.glassfish.user}:#{node.glassfish.group} #{node.hopsworks.domains_dir}/.sparkmagic
   EOF
end




template "#{node.hopsworks.domains_dir}/.sparkmagic/config.json" do
  source "config.json.erb"
  owner node.glassfish.user
  mode 0750
  action :create
  variables({
               :livy_ip => livy_ip
  })
end


python_package "hdfscontents" do
  action :install
  version '0.3'
end
