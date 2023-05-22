#rows_path = "#{domains_dir}/post.sql"

case node['platform']
when "rhel"
  package "openssh-clients"
end

package "openssh-server"
public_ip=my_public_ip()
payara_config = "hopsworks-config"
deployment_group = "hopsworks-dg"
local_instance = "instance0"
service_name="glassfish-instance"

domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
admin_port = node['hopsworks']['admin']['port']
username=node['hopsworks']['admin']['user']
password=node['hopsworks']['admin']['password']

ssh_nodes= node['hopsworks'].attribute?('ssh_node')? private_recipe_ips('hopsworks', 'ssh_node') : []
config_nodes= node['hopsworks'].attribute?('config_node')? private_recipe_ips('hopsworks', 'config_node') : []

current_version = node['hopsworks']['current_version']

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

nodedir=node['glassfish']['nodes_dir']
#need the -t to get only result no success message
asadmin_cmd="#{asadmin} -I false -t --user #{username} --passwordfile #{password_file}"

log_dir="#{nodedir}/#{node['hopsworks']['node_name']}/#{local_instance}/logs"

homedir = conda_helpers.get_user_home(node['hopsworks']['user'])
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"
glassfish_user_home = conda_helpers.get_user_home(node['glassfish']['user'])

package "expect" do
  retries 10
  retry_delay 30
end

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
  action :glassfish_configure_network
end

if node['hopsworks']['ha']['loadbalancer'].to_s == "true"
  # http internal for load balancer
  hopsworks_configure_server "glassfish_configure_network" do
    domain_name domain_name
    domains_dir domains_dir
    password_file password_file
    username username
    admin_port admin_port
    target payara_config
    asadmin asadmin
    internal_port 28182
    network_name "http-internal"
    securityenabled false
    action :glassfish_configure_network
  end
end

glassfish_asadmin "set #{payara_config}.http-service.virtual-server.server.property.send-error_1='code=404 path=${com.sun.aas.instanceRoot}/docroot/index.html reason=Resource_not_found'" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

# disable monitoring and http-listeners on server-config
glassfish_network_listener_conf = {
  "configs.config.server-config.network-config.network-listeners.network-listener.http-listener-2.enabled" => false,
  "configs.config.server-config.network-config.network-listeners.network-listener.https-internal-list.enabled" => false,
  "configs.config.server-config.rest-monitoring-configuration.enabled" => false,
  "configs.config.server-config.monitoring-service.mbean-enabled" => false,
  "configs.config.server-config.monitoring-service.monitoring-enabled" => false,
  "configs.config.server-config.microprofile-metrics-configuration.enabled" => false
}

hopsworks_configure_server "glassfish_configure" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target payara_config
  asadmin asadmin
  override_props glassfish_network_listener_conf
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

node_ips=[public_ip]+ssh_nodes+config_nodes
interfaces=node_ips.join(",")
glassfish_asadmin "set-hazelcast-configuration --publicaddress #{public_ip} --daspublicaddress #{public_ip} --autoincrementport true --interfaces #{interfaces} --membergroup #{payara_config} --target #{payara_config}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "create-local-instance --config #{payara_config} --nodedir #{nodedir} #{local_instance}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-instances | grep #{local_instance}"
end

directory node['hopsworks']['data_volume']['localhost-domain1'] do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
end

directory node['hopsworks']['data_volume']['node_logs'] do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
end

bash 'Move glassfish logs to data volume' do
  user 'root'
  code <<-EOH
    set -e
    mv -f #{log_dir}/* #{node['hopsworks']['data_volume']['node_logs']}
    mv -f #{log_dir} #{node['hopsworks']['data_volume']['node_logs']}_deprecated
  EOH
  only_if { conda_helpers.is_upgrade }
  only_if { File.directory?(log_dir)}
  not_if { File.symlink?(log_dir)}
end

link "#{log_dir}" do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
  to node['hopsworks']['data_volume']['node_logs']
end

glassfish_asadmin "create-system-properties --target #{local_instance} hazelcast.local.publicAddress=#{public_ip}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-system-properties #{local_instance} | grep hazelcast.local.publicAddress=#{public_ip}"
end

#
# mod_ajp http://www.devwithimagination.com/2015/08/13/apache-as-a-reverse-proxy-to-glassfish/
#
# https://dzone.com/articles/configure-a-glassfish-cluster-with-automatic-load
# docker
# https://github.com/jelastic-jps/glassfish/
hopsworks_create_nodes "create_ssh_nodes" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  asadmin_cmd asadmin_cmd
  payara_config payara_config
  nodedir nodedir
  nodes ssh_nodes
  glassfish_user_home glassfish_user_home
  action :create_ssh_nodes
end

# This is done here to reserve the name of the worker
# when config node runs on a worker it just need to get its name by ip
hopsworks_create_nodes "create_config_nodes" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  asadmin_cmd asadmin_cmd
  payara_config payara_config
  nodedir nodedir
  nodes config_nodes
  action :create_config_nodes
end

glassfish_asadmin "create-deployment-group #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-deployment-groups | grep #{deployment_group}"
end

glassfish_asadmin "add-instance-to-deployment-group --instance #{local_instance} --deploymentgroup #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

ssh_nodes.each do |val|
  instance_name_cmd="#{asadmin_cmd} list-instances -l | grep #{val} | head -n 1 | awk '{print $1}'"
  glassfish_asadmin "add-instance-to-deployment-group --instance $(#{instance_name_cmd}) --deploymentgroup #{deployment_group}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end
end

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear:#{node['hopsworks']['version']}"
  target "server"
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  action :undeploy
  only_if "#{asadmin_cmd} list-applications --type ejb server | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks" do
  component_name "hopsworks-web:#{node['hopsworks']['version']}"
  target "server"
  version current_version
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  action :undeploy
  only_if "#{asadmin_cmd} list-applications --type web server | grep -w \"hopsworks-web:#{node['hopsworks']['version']}\"" 
end

glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca:#{node['hopsworks']['version']}"
  target "server"
  version current_version
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  action :undeploy
  only_if "#{asadmin_cmd} list-applications --type ejb server | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
end

hopsworks_configure_server "change_node_master_password" do
  username username
  asadmin asadmin
  nodedir nodedir
  node_name node['hopsworks']['node_name']
  current_master_password "changeit"
  action :change_node_master_password
end

# Resources created in default server, so create a reference to the resources in the new config
glassfish_resources = [
  'concurrent/hopsThreadFactory',
  'concurrent/condaExecutorService',
  'concurrent/hopsExecutorService',
  'concurrent/jupyterExecutorService',
  'concurrent/condaScheduledExecutorService',
  'concurrent/hopsScheduledExecutorService',
  'concurrent/kagentExecutorService',
  'jdbc/airflow', 
  'jdbc/featurestore', 
  'jdbc/hopsworks', 
  'jdbc/hopsworksTimers',
  'ldap/LdapResource',
  'mail/BBCMail']

glassfish_resources.each do |val|
  glassfish_asadmin "create-resource-ref --target #{deployment_group} #{val}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    only_if "#{asadmin_cmd} list-resource-refs server | grep #{val}"
    not_if "#{asadmin_cmd} list-resource-refs #{deployment_group} | grep #{val}"
  end
end

#restart only if new (no deployed apps)
glassfish_asadmin "restart-domain" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-applications #{deployment_group} | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
  only_if "#{asadmin_cmd} list-instances #{deployment_group} | grep -w \"not running\""
end

hopsworks_worker "add_to_services" do
  asadmin asadmin
  admin_port admin_port
  username username
  password_file password_file
  nodedir nodedir
  node_name node['hopsworks']['node_name']
  instance_name local_instance
  service_name service_name
  action :add_to_services
  not_if "systemctl is-active --quiet #{service_name}"
end

if current_version.eql?("") == false
  #
  # undeploy previous version
  #
  glassfish_deployable "hopsworks-ear" do
    component_name "hopsworks-ear:#{node['hopsworks']['current_version']}"
    target deployment_group
    version current_version
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    action :undeploy
    retries 1
    keep_state true
    enabled true
    secure true
    ignore_failure true
  end

  glassfish_deployable "hopsworks" do
    component_name "hopsworks-web:#{node['hopsworks']['current_version']}"
    target deployment_group
    version current_version
    context_root "/hopsworks"
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure true
    action :undeploy
    async_replication false
    retries 1
    keep_state true
    enabled true
    ignore_failure true  
  end

  glassfish_deployable "hopsworks-ca" do
    component_name "hopsworks-ca:#{node['hopsworks']['current_version']}"
    target deployment_group
    version current_version
    context_root "/hopsworks-ca"
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure true
    action :undeploy
    async_replication false
    retries 1
    keep_state true
    enabled true
    ignore_failure true
  end
end    

# change reference of the deployed apps will require restarting instances
glassfish_deployable "hopsworks-ca" do
  component_name "hopsworks-ca:#{node['hopsworks']['version']}"
  target deployment_group
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
  not_if "#{asadmin_cmd} list-applications --type ejb #{deployment_group} | grep -w \"hopsworks-ca:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks-ear" do
  component_name "hopsworks-ear:#{node['hopsworks']['version']}"
  target deployment_group
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
  not_if "#{asadmin_cmd} list-applications --type ejb #{deployment_group} | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
end

glassfish_deployable "hopsworks" do
  component_name "hopsworks-web:#{node['hopsworks']['version']}"
  target deployment_group
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
  not_if "#{asadmin_cmd} list-applications --type web #{deployment_group} | grep -w \"hopsworks-web:#{node['hopsworks']['version']}\""
end
