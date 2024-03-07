require 'digest'
require 'securerandom'

include_recipe "java"
include_recipe "hops::default"
include_recipe "hadoop_spark::install"
include_recipe "hadoop_spark::config"
include_recipe "flink::install"

Chef::Recipe.send(:include, Hops::Helpers)
Chef::Resource.send(:include, Hops::Helpers)

domain_name= node['hopsworks']['domain_name']
domains_dir = node['hopsworks']['domains_dir']

# This is set correctly in hopsworks::install by the chef-glassfish recipe. As each recipe has it's own
# instance of chef we need to re-set it here.
# If you set it in the attributes it will break glassfish installation.
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"
theDomain="#{domains_dir}/#{domain_name}"

public_ip=my_public_ip()
deployment_group = "hopsworks-dg"

exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

bash 'create_hopsworks_db' do
  user "root"
  code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS #{node['hopsworks']['db']} CHARACTER SET latin1\"
      #{exec} -e \"CREATE USER IF NOT EXISTS \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\' IDENTIFIED BY \'#{node['hopsworks']['mysql']['password']}\';\"
    EOF
end

timerTable = "ejbtimer_mysql.sql"
timerTablePath = "#{Chef::Config['file_cache_path']}/#{timerTable}"

# Need to delete the sql file so that the create_timers action is triggered
file timerTablePath do
  action :delete
  ignore_failure true
end

hopsworks_grants "timers_tables" do
  tables_path  "#{timerTablePath}"
  action :nothing
end

template timerTablePath do
  source File.basename("#{timerTablePath}") + ".erb"
  owner node['glassfish']['user']
  mode 0750
  action :create
  notifies :create_timers, 'hopsworks_grants[timers_tables]', :immediately
end

hops_rpc_tls_val = "false"
if node['hops']['tls']['enabled'].eql? "true"
  hops_rpc_tls_val = "true"
end

condaRepo = 'defaults'
if node['conda']['channels']['default_mirrors'].empty? == false
   repos = node['conda']['channels']['default_mirrors'].split(/\s*,\s*/)
   condaRepo = repos[0]
end

# hops-util-py only works for localhost installations if you disable TLS hostname validations
if node['install']['localhost'].eql? "true"
  node.override['hopsworks']['requests_verify'] = "false"
end

versions = node['hopsworks']['versions'].split(/\s*,\s*/)
target_version = node['hopsworks']['version'].sub("-SNAPSHOT", "")
# Ignore patch versions starting from version 3.0.0
if Gem::Version.new(target_version) >= Gem::Version.new('3.0.0')
  target_version_ignore_patch_arr = target_version.split(".")
  target_version_ignore_patch_arr[2] = "0"
  target_version = target_version_ignore_patch_arr.join(".")
end
versions.push(target_version)
current_version = node['hopsworks']['current_version']

if current_version.eql?("")
  # Make sure the database is actually empty. Otherwise raise an error
  ruby_block "check_db_empty" do
    block do
      raise "You are trying to initialize the database, but the database is not empty. Either there is a failed migration, or you forgot to set the current_version attribute"
    end
    only_if "#{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks -e \"SHOW TABLES\" | grep project"
  end

  # New installation -> template the current version schema file
  cookbook_file "#{theDomain}/flyway/sql/V#{target_version}__initial_tables.sql" do
    source "sql/ddl/#{target_version}__initial_tables.sql"
    owner node['glassfish']['user']
    mode 0750
    action :create
  end
else
  # Current version can contain the patch version. However we don't have schemas for patch versions
  # Which means that the `version.index` operation below will fail. To avoid this we parse the version
  # and we replace the patch version to 0 before searching the version list.
  version_segments = Gem::Version.new(current_version).canonical_segments()
  version_segments[2] = 0
  minor_version = version_segments.join('.')

  minor_version_idx = versions.index(minor_version).to_i
  versions_length = versions.length.to_i - 1

  for i in (minor_version_idx + 1)..versions_length
    # Update, template all the dml files from the current version to the target version
    cookbook_file "#{theDomain}/flyway/sql/V#{versions[i]}__hopsworks.sql" do
      source "sql/ddl/updates/#{versions[i]}.sql"
      owner node['glassfish']['user']
      mode 0750
      action :create
    end
  end
end

unless node['install']['cloud'].strip.empty?
  node.override['hopsworks']['reserved_project_names'] = "#{node['hopsworks']['reserved_project_names']},cloud"
end

# Hopsworks CA configuration
caConf = {}
rootConf = {}
if !node['hopsworks']['pki']['root']['name'].empty?
  rootConf[:x509Name] = node['hopsworks']['pki']['root']['name']
  rootConf[:validityDuration] = node['hopsworks']['pki']['root']['duration']
end

intermediateConf = {}
if !node['hopsworks']['pki']['intermediate']['name'].empty?
  intermediateConf[:x509Name] = node['hopsworks']['pki']['intermediate']['name']
  intermediateConf[:validityDuration] = node['hopsworks']['pki']['intermediate']['duration']
end

if !node['hopsworks']['pki']['intermediate']['extra_san_for_username'].empty?
  intermediateConf[:extraUsernameSAN] = JSON.parse(node['hopsworks']['pki']['intermediate']['extra_san_for_username'])
end

kubernetesConf = {}
if !node['hopsworks']['pki']['kubernetes']['name'].empty?
  kubernetesConf[:x509Name] = node['hopsworks']['pki']['kubernetes']['name']
  kubernetesConf[:validityDuration] = node['hopsworks']['pki']['kubernetes']['duration']
end

if node['install']['kubernetes'].casecmp?('true') && node['install']['managed_kubernetes'].casecmp?('false')
  kubernetesConf[:subjectAlternativeName] = {
    :dns => [node['fqdn'], node['kube-hops']['cluster_name'],
              "#{node['kube-hops']['cluster_name']}.default",
              "#{node['kube-hops']['cluster_name']}.default.svc",
              "#{node['kube-hops']['cluster_name']}.default.svc.cluster",
              "#{node['kube-hops']['cluster_name']}.default.svc.cluster.local",
              "*.hops-system.svc"
            ],
    :ip => [node['kube-hops']['cidr'].split('/')[0].reverse.sub('0', '1').reverse,
              private_recipe_ip('kube-hops', 'master'),
              "127.0.0.1",
              node['kube-hops']['dns_ip'],
              "10.96.0.1"]
  }
end

caConf[:rootCA] = rootConf
caConf[:intermediateCA] = intermediateConf
caConf[:kubernetesCA] = kubernetesConf


# Usernames configuration
usernamesConfiguration = {}
usernamesConfiguration[:glassfish] = node['hopsworks']['user']
usernamesConfiguration[:hdfs] = node['hops']['hdfs']['user']
usernamesConfiguration[:rmyarn] = node['hops']['rm']['user']
usernamesConfiguration[:yarn] = node['hops']['yarn']['user']
usernamesConfiguration[:hive] = node['hive2']['user']
usernamesConfiguration[:livy] = node['livy']['user']
usernamesConfiguration[:flink] = node['flink']['user']
usernamesConfiguration[:consul] = node['consul']['user']
usernamesConfiguration[:hopsmon] = node['hopsmonitor']['user']
usernamesConfiguration[:zookeeper] = node['kzookeeper']['user']
usernamesConfiguration[:onlinefs] = node['onlinefs']['user']
usernamesConfiguration[:elastic] = node['elastic']['user']
usernamesConfiguration[:kagent] = node['kagent']['user']
usernamesConfiguration[:mysql] = node['ndb']['user']
usernamesConfiguration[:airflow] = node['airflow']['user']
if node.attribute?('flyingduck') && node['flyingduck'].attribute?('user')
  usernamesConfiguration[:flyingduck] = node['flyingduck']['user']
end

# encrypt onlinefs user password
onlinefs_salt = SecureRandom.base64(64)
encrypted_onlinefs_password = Digest::SHA256.hexdigest node['onlinefs']['hopsworks']['password'] + onlinefs_salt

# encrypt airflow user poassword
airflow_salt = SecureRandom.base64(64)
encrypted_airflow_password = Digest::SHA256.hexdigest node['airflow']['hopsworks']['password'] + airflow_salt

# Check if Kafka is to be installed 
kafka_installed = true
begin
  valid_recipe("kkafka", "default")
  Chef::Log.info "Found kafka cookbooks, will proceed to create db user for Kafka"
  kafka_installed = true
rescue
  Chef::Log.info "Kafka will not be installed, skipped creating DB user."
  kafka_installed = false
end

apparmor_enabled = is_apparmor_enabled() && node['hops']['docker']['load-hopsfsmount-apparmor-profile'].casecmp?("true")

for version in versions do
  # Template DML files
  template "#{theDomain}/flyway/dml/V#{version}__hopsworks.sql" do
    source "sql/dml/#{version}.sql.erb"
    owner node['glassfish']['user']
    mode 0750
    variables({
         :user_cert_valid_days => node['hopsworks']['cert']['user_cert_valid_days'],
         :conda_repo => condaRepo,
         :hopsworks_dir => theDomain,
         :hops_rpc_tls => hops_rpc_tls_val,
         :yarn_default_quota => node['hopsworks']['yarn_default_quota_mins'].to_i * 60,
         :java_home => node['java']['java_home'],
         :public_ip => public_ip,
         :krb_ldap_auth => node['ldap']['enabled'].to_s == "true" || node['kerberos']['enabled'].to_s == "true",
         :hops_version => node['hops']['version'],
         :onlinefs_password => encrypted_onlinefs_password,
         :onlinefs_salt => onlinefs_salt,
         :pki_ca_configuration => caConf.to_json(),
         :usernames_configuration => usernamesConfiguration.to_json(),
         :kafka_installed => kafka_installed,
         :apparmor_enabled => apparmor_enabled,
         :ha_enabled => node['hopsworks'].attribute?('das_node'),
         :airflow_salt => airflow_salt,
         :airflow_password => encrypted_airflow_password
    })
    action :create
  end

   # template all the ddl files from all versions
   cookbook_file "#{theDomain}/flyway/all/sql/V#{version}__hopsworks.sql" do
    source "sql/ddl/updates/#{version}.sql"
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode 0750
    action :create
  end


  if Gem::Version.new(version) >= Gem::Version.new('2.0.0')
    cookbook_file "#{theDomain}/flyway/all/sql/V#{version}__initial_tables.sql" do
      source "sql/ddl/#{version}__initial_tables.sql"
      owner node['glassfish']['user']
      group node['glassfish']['group']
      mode 0750
      action :create
    end
  end 
  
end

bash "flyway_migrate" do
  user "root"
  cwd "#{theDomain}/flyway"
  code <<-EOF
    # Validation during migrate is very strict for our needs. If we found a bug
    # on a released branch and we fix it, next time someone upgrades to released branch+1
    # they will get a validation error because the files checksum do not match
    #{theDomain}/flyway/flyway -validateOnMigrate=false migrate
  EOF
end

# Run the DML sql script to insert the variables
for version in versions do
  bash "run_inserts_#{version}" do
    user "root"
    code <<-EOH
      #{node['ndb']['scripts_dir']}/mysql-client.sh hopsworks < #{theDomain}/flyway/dml/V#{version}__hopsworks.sql
    EOH
  end
end


###############################################################################
# config glassfish
###############################################################################

username = node['hopsworks']['admin']['user']
password = node['hopsworks']['admin']['password']
admin_port = node['hopsworks']['admin']['port']

jndiDB = "jdbc/hopsworks"

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"
asadmin_cmd = "#{asadmin} --user #{username} --passwordfile #{password_file}"

node.override['glassfish']['asadmin']['timeout'] = 600

# if there are running or not running instances then un/deploy should have target deployment_group
target = nil
command_output = `#{asadmin_cmd} list-instances | grep running`
# Check the exit code of the `#{asadmin_cmd} list-instances | grep running` command
if !command_output.empty?
  Chef::Log.info("There are running instances")
  target = deployment_group
end

if current_version.eql?("") == false
#
# undeploy previous version
#

  glassfish_deployable "hopsworks-ear" do
    component_name "hopsworks-ear:#{node['hopsworks']['current_version']}"
    target "domain"
    version current_version
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    action :undeploy
    retries 1
    keep_state true
    enabled true
    secure true
    only_if "#{asadmin_cmd} list-applications --type ejb domain | grep -w \"hopsworks-ear:#{node['hopsworks']['current_version']}\""
  end

  glassfish_deployable "hopsworks" do
    component_name "hopsworks-web:#{node['hopsworks']['current_version']}"
    target "domain"
    version current_version
    context_root "/hopsworks"
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure true
    action :undeploy
    async_replication false
    retries 1
    keep_state true
    enabled true
    only_if "#{asadmin_cmd} list-applications --type web domain | grep -w \"hopsworks-web:#{node['hopsworks']['current_version']}\""
  end

  glassfish_deployable "hopsworks-ca" do
    component_name "hopsworks-ca:#{node['hopsworks']['current_version']}"
    target "domain"
    version current_version
    context_root "/hopsworks-ca"
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure true
    action :undeploy
    async_replication false
    retries 1
    keep_state true
    enabled true
    only_if "#{asadmin_cmd} list-applications --type ejb domain | grep -w \"hopsworks-ca:#{node['hopsworks']['current_version']}\""
  end
end  

# Add Hadoop glob classpath and HADOOP_CONF_DIR to Glassfish
# systemd unit environment variables file
hadoop_glob_command = "#{node['hops']['bin_dir']}/hadoop classpath --glob"
ruby_block "export_hadoop_classpath" do
  block do
    Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
    exec_stdout = shell_out(hadoop_glob_command).stdout
    variable = "HADOOP_GLOB=#{exec_stdout}"
    file = Chef::Util::FileEdit.new(node['hopsworks']['env_var_file'])
    file.insert_line_if_no_match(/#{variable}/, variable)
    hadoop_conf_dir_var = "HADOOP_CONF_DIR=#{node['hops']['conf_dir']}"
    file.insert_line_if_no_match(/#{variable}/, hadoop_conf_dir_var)
    file.write_file
  end
  action :create
end

ruby_block "export_hadoop_classpath" do
  block do
    file = Chef::Util::FileEdit.new("/lib/systemd/system/glassfish-domain1.service")
    new_line = "ExecStartPre=/bin/bash -c 'sleep 5 && if systemctl list-units --full -all | grep -Fq 'mysqld.service'; then systemctl is-active --quiet mysqld; fi'"
    file.insert_line_if_no_match(/#{new_line}/, new_line)
    file.write_file
  end
  action :create
end

kagent_config "glassfish-domain1" do 
  action :systemd_reload
end

glassfish_secure_admin domain_name do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  action :enable
end

hopsworks_configure_server "glassfish_configure_realm" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  asadmin asadmin
  action :glassfish_configure_realm
end

# add new network listener for Hopsworks to listen on an internal port
hopsworks_configure_server "glassfish_configure_network" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  asadmin asadmin
  internal_port node['hopsworks']['internal']['port']
  network_name "https-internal"
  network_listener_name "https-int-list"
  action :glassfish_configure_network
  not_if "#{asadmin_cmd} list-instances | grep running"
end

hopsworks_configure_server "glassfish_configure" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  asadmin asadmin
  action :glassfish_configure
  not_if "#{asadmin_cmd} list-instances | grep running"
end

glassfish_asadmin "create-managed-executor-service --enabled=true --longrunningtasks=true --corepoolsize=50 --maximumpoolsize=400 --keepaliveseconds=60 --taskqueuecapacity=20000 concurrent/condaExecutorService" do
   domain_name domain_name
   password_file password_file
   username username
   admin_port admin_port
   secure false
  not_if "#{asadmin_cmd} list-managed-executor-services | grep 'conda'"
end

glassfish_asadmin "create-managed-executor-service --enabled=true --longrunningtasks=true --corepoolsize=10 --maximumpoolsize=200 --keepaliveseconds=60 --taskqueuecapacity=10000 concurrent/kagentExecutorService" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
 not_if "#{asadmin_cmd} list-managed-executor-services | grep 'kagent'"
end

if exists_local("hops_airflow", "default")
  # In case of an upgrade, attribute-driven-domain will not run but we still need to configure
  # connection pool for Airflow

  # Drop Existing airflowPool connection pool and recreate it
  glassfish_asadmin "delete-jdbc-connection-pool --cascade airflowPool" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    only_if "#{asadmin_cmd} list-jdbc-connection-pools | grep 'airflowPool$'"
  end
end

# Drop Existing featureStore connection pool and recreate it
glassfish_asadmin "delete-jdbc-connection-pool --cascade featureStorePool" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin_cmd} list-jdbc-connection-pools | grep 'featureStorePool$'"
end

# Drop Existing hopsworksPool connection pool and recreate it
glassfish_asadmin "delete-jdbc-connection-pool --cascade hopsworksPool" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin_cmd} list-jdbc-connection-pools | grep 'hopsworksPool$'"
end

glassfish_asadmin "create-jdbc-connection-pool --restype javax.sql.DataSource --datasourceclassname com.mysql.cj.jdbc.MysqlDataSource --ping=true --isconnectvalidatereq=true --validationmethod=auto-commit --description=\"Hopsworks Connection Pool\" --property user=#{node['hopsworks']['mysql']['user']}:password=#{node['hopsworks']['mysql']['password']}:url=\"jdbc\\:mysql\\://127.0.0.1\\:3306/\":useSSL=false:allowPublicKeyRetrieval=true hopsworksPool" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "create-jdbc-resource --connectionpoolid hopsworksPool --description \"Resource for Hopsworks Pool\" jdbc/hopsworks" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-jdbc-resources | grep 'jdbc/hopsworks$'"
end

# Drop Existing ejbTimerPool connection pool and recreate it
glassfish_asadmin "delete-jdbc-connection-pool --cascade ejbTimerPool" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin_cmd} list-jdbc-connection-pools | grep 'ejbTimerPool$'"
end

# Timers can have nore than one database connections to different databases, so we need XADataSource (distributed) transaction manager b/c more than 1 non-XA Resource is not allowed. 
glassfish_asadmin "create-jdbc-connection-pool --restype javax.sql.XADataSource --datasourceclassname com.mysql.cj.jdbc.MysqlXADataSource --ping=true --isconnectvalidatereq=true --validationmethod=auto-commit --description=\"Hopsworks EJB Connection Pool\" --property user=#{node['hopsworks']['mysql']['user']}:password=#{node['hopsworks']['mysql']['password']}:url=\"jdbc\\:mysql\\://127.0.0.1\\:3306/glassfish_timers\":useSSL=false:allowPublicKeyRetrieval=true ejbTimerPool" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "create-jdbc-resource --connectionpoolid ejbTimerPool --description \"Resource for Hopsworks EJB Timers Pool\" jdbc/hopsworksTimers" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-jdbc-resources | grep 'jdbc/hopsworksTimers$'"
end

glassfish_asadmin "create-managed-executor-service --enabled=true --threadpriority #{node['hopsworks']['managed_executor_pools']['jupyter']['threadpriority']} --longrunningtasks=true --corepoolsize #{node['hopsworks']['managed_executor_pools']['jupyter']['corepoolsize']} --maximumpoolsize #{node['hopsworks']['managed_executor_pools']['jupyter']['maximumpoolsize']} --taskqueuecapacity #{node['hopsworks']['managed_executor_pools']['jupyter']['taskqueuecapacity']} --description \"Hopsworks Jupyter Executor Service\" concurrent/jupyterExecutorService" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-managed-executor-services | grep 'concurrent/jupyterExecutorService$'"
end

logging_conf = {
  "com.sun.enterprise.server.logging.GFFileHandler.logtoFile" => true,
  "com.sun.enterprise.server.logging.GFFileHandler.rotationLimitInBytes" => node['hopsworks']['logsize'],
  # the main logger doesn't work either.
  # These are just some random number, we are not enabling this logger. However if they are not set
  "fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.rotationLimitInBytes" => 2000000,
  "fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.rotationTimelimitInMinutes" => 0,
  "fish.payara.enterprise.server.logging.PayaraNotificationFileHandler.maxHistoryFiles" => 3
}

logging_conf.each do |property, value|
  glassfish_asadmin "set-log-attributes #{property}=#{value}" do
   domain_name domain_name
   password_file password_file
   username username
   admin_port admin_port
   secure false
  end
end

loglevels_conf = {
  'fish.payara.nucleus.notification.log.LogNotifierService' => 'SEVERE'
}

loglevels_conf.each do |property, value|
  glassfish_asadmin "set-log-levels #{property}=#{value}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end
end

hopsworks_configure_server "glassfish_configure_monitoring" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  asadmin asadmin
  action :glassfish_configure_monitoring
  not_if "#{asadmin_cmd} list-instances | grep running"
end

if node['ldap']['enabled'].to_s == "true" || node['kerberos']['enabled'].to_s == "true"
  ldap_jndilookupname= node['ldap']['jndilookupname']
  ldap_jndilookupname=ldap_jndilookupname.gsub('=', '\\\\=').gsub(',', '\\\\,')
  ldap_provider_url=node['ldap']['provider_url']
  ldap_provider_url=ldap_provider_url.gsub(':', '\\\\\:').gsub('.', '\\\\.')
  ldap_attr_binary=node['ldap']['attr_binary_val']
  ldap_sec_auth=node['ldap']['security_auth']
  ldap_security_auth=ldap_sec_auth.to_s.empty? ? "" : ":java.naming.security.authentication=#{ldap_sec_auth}"
  ldap_sec_principal=node['ldap']['security_principal']
  ldap_sec_principal=ldap_sec_principal.gsub('=', '\\\\\=')
  ldap_security_principal=ldap_sec_principal.to_s.empty? ? "" : ":java.naming.security.principal=#{ldap_sec_principal}"
  ldap_sec_credentials=node['ldap']['security_credentials']
  ldap_security_credentials=ldap_sec_credentials.to_s.empty? ? "" : ":java.naming.security.credentials=#{ldap_sec_credentials}"
  ldap_ref=node['ldap']['referral']
  ldap_referral=ldap_ref.to_s.empty? ? "" : ":java.naming.referral=#{ldap_ref}"
  # This is needed because while ldap_jdilookupname is used as an argument to create-jndi-resource command
  # the ldap_basedn is used as Java property (key=value) so we need to escape \ again :)
  ldap_basedn = ldap_jndilookupname.gsub('=', '\=')
  ldap_properties=":hopsworks.ldap.basedn=#{ldap_basedn}"
  unless node['ldap']['additional_props'].empty?
    ldap_properties="#{ldap_properties}:#{node['ldap']['additional_props']}"
  end

  glassfish_asadmin "create-jndi-resource --restype javax.naming.ldap.LdapContext --factoryclass com.sun.jndi.ldap.LdapCtxFactory --jndilookupname #{ldap_jndilookupname} --property java.naming.provider.url=#{ldap_provider_url}:java.naming.ldap.attributes.binary=#{ldap_attr_binary}#{ldap_security_auth}#{ldap_security_principal}#{ldap_security_credentials}#{ldap_referral}#{ldap_properties} ldap/LdapResource" do
     domain_name domain_name
     password_file password_file
     username username
     admin_port admin_port
     secure false
     not_if "#{asadmin_cmd} list-jndi-resources | grep 'ldap/LdapResource'"
  end
end

if node['hopsworks']['http_logs']['enabled'].eql? "true"
  hopsworks_configure_server "glassfish_configure_http_logging" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    action :glassfish_configure_http_logging
  end
end

hopsworks_mail "gmail" do
   domain_name domain_name
   password_file password_file
   username username
   admin_port admin_port
   action :jndi
   not_if "#{asadmin_cmd} list-instances | grep running"
end

# Recreate resource references because they are recreated 
hopsworks_configure_server "glassfish_create_resource_ref" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  asadmin asadmin
  target deployment_group
  recreate true
  action :glassfish_create_resource_ref
  only_if "#{asadmin_cmd} list-instances | grep running"
end

# Reload glassfish with new configuration 
kagent_config "glassfish-domain1" do
  action :systemd_reload
end

# Reload glassfish instance with new configuration if HA
glassfish_asadmin "restart-deployment-group --rolling=true --delay 5000 #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin_cmd} list-deployment-groups | grep #{deployment_group}"
  only_if "#{asadmin_cmd} list-instances | grep running"
end

list_target = target.nil? ? "" : target

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear:#{node['hopsworks']['version']}"
  target target
  url node['hopsworks']['ear_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin_cmd} list-applications --type ejb #{list_target} | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks" do
  component_name "hopsworks-web:#{node['hopsworks']['version']}"
  target target
  url node['hopsworks']['war_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  context_root "/hopsworks"
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin_cmd} list-applications --type web #{list_target} | grep -w \"hopsworks-web:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca:#{node['hopsworks']['version']}"
  target target
  url node['hopsworks']['ca_url']
  auth_username node['install']['enterprise']['username']
  auth_password node['install']['enterprise']['password']
  version node['hopsworks']['version']
  context_root "/hopsworks-ca"
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  action :deploy
  async_replication false
  retries 1
  keep_state true
  enabled true
  not_if "#{asadmin_cmd} list-applications --type ejb #{list_target} | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
end


# Deploy the new react frontend - clean the directory from the previous version
directory "#{theDomain}/docroot" do
  recursive true
  action :delete
end

directory "#{theDomain}/docroot" do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "770"
  action :create
end

remote_file "#{Chef::Config['file_cache_path']}/frontend.tgz" do
  source node['hopsworks']['frontend_url']
  user node['glassfish']['user']
  group node['glassfish']['group']
  mode 0755
  action :create
end

bash "extract_frontend" do
  user node['hopsworks']['user']
  group node['hopsworks']['group']
  code <<-EOH
    tar xf #{Chef::Config['file_cache_path']}/frontend.tgz -C #{theDomain}/docroot
  EOH
end

hopsworks_user_home = conda_helpers.get_user_home(node['hopsworks']['user'])

#
# Disable glassfish service, if node['services']['enabled'] is not set to true
#
if node['services']['enabled'] != "true"
  service "glassfish-domain1" do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :disable
  end
end

#  Template metrics.xml to expose metrics
template "#{theDomain}/config/metrics.xml"  do
  source 'metrics.xml.erb'
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "700"
  action :create
end

kagent_keys "#{hopsworks_user_home}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  action :generate
end

kagent_keys "#{hopsworks_user_home}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  cb_name "hopsworks"
  cb_recipe "default"
  action :return_publickey
end

if node['kagent']['enabled'].casecmp? "true"
  kagent_config "glassfish-domain1" do
    service "glassfish_#{node['hopsworks']['domain_name']}"
    log_file "#{node['hopsworks']['domains_dir']}/#{node['hopsworks']['domain_name']}/logs/server.log"
    restart_agent false
  end
end

# We can't use the internal port yet as the certificate has not been generated yet
hopsworks_certs "generate-int-certs" do
  subject     "/CN=#{node['fqdn']}/L=glassfishinternal/OU=0"
  action      :generate_int_certs
end

hopsworks_certs "import-user-certs" do
  action :import_certs
  not_if { node['hopsworks']['https']['key_url'].eql?("") }
end

hopsworks_certs "download_azure_ca_cert" do
  action      :download_azure_ca_cert
end

# Force reload of the certificate
kagent_config "glassfish-domain1" do
  action :systemd_reload
end

# Generate service API key
ruby_block "generate_api_key" do
  block do
    begin
      execute_shell_command "#{node['ndb']['scripts_dir']}/mysql-client.sh -e \"SELECT id FROM hopsworks.variables WHERE id='int_service_api_key' AND value != '';\" | grep 'int_service_api_key'"
      Chef::Log.warn "Internal service API key already exists"
    rescue
      api_key_params = {
        :name => "hw_int_#{my_private_ip()}_#{SecureRandom.hex(6)}",
        :scope => "AUTH"
      }
      api_key = create_api_key(node['kagent']['dashboard']['user'], node['kagent']['dashboard']['password'], api_key_params, hopsworks_ip="127.0.0.1")
      execute_shell_command "#{node['ndb']['scripts_dir']}/mysql-client.sh -e \"REPLACE INTO hopsworks.variables(id, value, visibility, hide) VALUE ('int_service_api_key', '#{api_key}', 0, 1);\""
    end
  end
end

# Force variables reload
kagent_config "glassfish-domain1" do 
  action :systemd_reload
end

# Register Glassfish with Consul
consul_service "Registering Glassfish with Consul" do
  service_definition "consul/glassfish-consul.hcl.erb"
  reload_consul false
  action :register
end

template "#{domains_dir}/#{domain_name}/bin/letsencrypt.sh" do
  source "letsencrypt.sh.erb"
  owner node['glassfish']['user']
  mode 0770
  action :create
end

#
# Rstudio
#

if node['rstudio']['enabled'].eql? "true"

  case node['platform']
  when 'debian', 'ubuntu'
    package "r-base" do
      retries 10
      retry_delay 30
    end

    remote_file "#{Chef::Config['file_cache_path']}/#{node['rstudio']['deb']}" do
      user node['glassfish']['user']
      group node['glassfish']['group']
      source node['download_url'] + "/#{node['rstudio']['deb']}"
      mode 0755
      action :create
    end

    bash 'install_rstudio_debian' do
      user "root"
      code <<-EOF
      set -e
      cd #{Chef::Config['file_cache_path']}
      apt-get install gdebi-core -y
      gdebi #{node['rstudio']['deb']}
    EOF
    end

  when 'redhat', 'centos', 'fedora'

    remote_file "#{Chef::Config['file_cache_path']}/#{node['rstudio']['rpm']}" do
      user node['glassfish']['user']
      group node['glassfish']['group']
      source node['download_url'] + "/#{node['rstudio']['rpm']}"
      mode 0755
      action :create
    end

    bash 'install_rstudio_rhel' do
      user "root"
      code <<-EOF
      set -e
      cd #{Chef::Config['file_cache_path']}
      yum install --nogpgcheck #{node['rstudio']['rpm']} -y
    EOF
    end

  end

  bash 'disable_rstudio_systemd_daemons' do
    user "root"
    ignore_failure true
    code <<-EOF
      systemctl stop rstudio-server
      systemctl disable rstudio-server
    EOF
  end
end

# Alter table flyway_schema_history to use ndb instead of innodb
bash 'alter_flyway_schema_history_engine' do
  user "root"
  code <<-EOF
    set -e
    #{exec} -e \"ALTER TABLE #{node['hopsworks']['db']}.flyway_schema_history engine = 'ndb';\"
  EOF
end
