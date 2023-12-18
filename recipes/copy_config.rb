payara_config = "hopsworks-config"
local_instance = "instance0"

domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
admin_port = node['hopsworks']['admin']['port']
username=node['hopsworks']['admin']['user']

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

nodedir=node['glassfish']['nodes_dir']
#need the -t to get only result no success message
asadmin_cmd="#{asadmin} -I false -t --user #{username} --passwordfile #{password_file}"

log_dir="#{nodedir}/#{node['hopsworks']['node_name']}/#{local_instance}/logs"

node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"

directory "#{nodedir}"  do
  owner node['hopsworks']['user']
  group node['hopsworks']['group']
  mode "750"
  action :create
  not_if "test -d #{nodedir}"
end

# Create a configuration b/c server-config can not be used for HA
glassfish_asadmin "copy-config default-config #{payara_config}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-configs | grep #{payara_config}"
end

# glassfish_jvm_options not removing -Xmx
glassfish_asadmin "delete-jvm-options --target #{payara_config} -Xmx512m" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin_cmd} list-jvm-options --target #{payara_config} | grep Xmx512m"
end

jvm_options = [
  "-XX:MaxPermSize=#{node['glassfish']['max_perm_size']}m", 
  "-Xss#{node['glassfish']['max_stack_size']}k", 
  "-Xms#{node['glassfish']['min_mem']}m", 
  "-Xmx#{node['glassfish']['max_mem']}m", 
  "-DHADOOP_HOME=#{node['hops']['dir']}/hadoop", 
  "-DHADOOP_CONF_DIR=#{node['hops']['dir']}/hadoop/etc/hadoop",
  "-DjvmRoute=${com.sun.aas.instanceName}"]

glassfish_jvm_options "JvmOptions #{payara_config}" do
  domain_name domain_name
  admin_port admin_port
  username username
  password_file password_file
  target payara_config
  secure false
  options jvm_options
  not_if "#{asadmin_cmd} list-jvm-options --target #{payara_config} | grep DjvmRoute"
end

hopsworks_configure_server "glassfish_configure_realm" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  target payara_config
  asadmin asadmin
  action :glassfish_configure_realm
end

hopsworks_configure_server "glassfish_configure_network" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target payara_config
  asadmin asadmin
  internal_port node['hopsworks']['internal']['port']
  network_name "https-internal"
  network_listener_name "https-int-list"
  action :glassfish_configure_network
end

# replace send-error_1 for instance after glassfish_configure above sets it to {domains_dir}/#{domain_name}/docroot/index.html
override = {
  "#{payara_config}.http-service.virtual-server.server.property.send-error_1" => "'code=404 path=${com.sun.aas.instanceRoot}/docroot/index.html reason=Resource_not_found'",
  "configs.config.#{payara_config}.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size" => node['glassfish']['http']['thread-pool']['maxthreadpoolsize'],
  "configs.config.#{payara_config}.thread-pools.thread-pool.http-thread-pool.min-thread-pool-size" => node['glassfish']['http']['thread-pool']['minthreadpoolsize'],
  "configs.config.#{payara_config}.thread-pools.thread-pool.http-thread-pool.idle-thread-timeout-seconds" => node['glassfish']['http']['thread-pool']['idletimeout'],
  "configs.config.#{payara_config}.thread-pools.thread-pool.http-thread-pool.max-queue-size" => node['glassfish']['http']['thread-pool']['maxqueuesize'],
}

hopsworks_configure_server "glassfish_configure" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target payara_config
  asadmin asadmin
  override_props override
  ignore_failure true
  action :glassfish_configure
end

hopsworks_configure_server "glassfish_configure_monitoring" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target payara_config
  asadmin asadmin
  action :glassfish_configure_monitoring
end

if node['hopsworks']['http_logs']['enabled'].eql? "true"
  hopsworks_configure_server "glassfish_configure_http_logging" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    target payara_config
    action :glassfish_configure_http_logging
  end
end