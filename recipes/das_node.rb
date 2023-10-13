private_ip=my_private_ip()
payara_config = "hopsworks-config"
deployment_group = "hopsworks-dg"
local_instance = "instance0"
service_name="glassfish-instance"

domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
admin_port = node['hopsworks']['admin']['port']
username=node['hopsworks']['admin']['user']
requires_authbind = admin_port.to_i < 1024 || node['hopsworks']['https']['port'].to_i < 1024

config_nodes= node['hopsworks'].attribute?('config_node')? private_recipe_ips('hopsworks', 'config_node') : []

current_version = node['hopsworks']['current_version']

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

nodedir=node['glassfish']['nodes_dir']
#need the -t to get only result no success message
asadmin_cmd="#{asadmin} -I false -t --user #{username} --passwordfile #{password_file}"

log_dir="#{nodedir}/#{node['hopsworks']['node_name']}/#{local_instance}/logs"

#so we can configure hopsworks-config for cloud
include_recipe 'hopsworks::copy_config'

# disable monitoring and http-listeners on server-config
glassfish_network_listener_conf = {
  "configs.config.server-config.network-config.network-listeners.network-listener.http-listener-2.enabled" => false,
  "configs.config.server-config.network-config.network-listeners.network-listener.https-int-list.enabled" => false,
  "configs.config.server-config.rest-monitoring-configuration.enabled" => false,
  "configs.config.server-config.monitoring-service.mbean-enabled" => false,
  "configs.config.server-config.monitoring-service.monitoring-enabled" => false,
  "configs.config.server-config.microprofile-metrics-configuration.enabled" => false
}

glassfish_network_listener_conf.each do |property, value|
  glassfish_asadmin "set #{property}=#{value}" do
   domain_name domain_name
   password_file password_file
   username username
   admin_port admin_port
   secure false
  end
end

node_ips=[private_ip]+config_nodes
interfaces=node_ips.join(",")
glassfish_asadmin "set-hazelcast-configuration --enabled true --publicaddress #{private_ip} --daspublicaddress #{private_ip} --autoincrementport true --interfaces #{interfaces} --membergroup #{payara_config} --target #{payara_config}" do
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

link "#{log_dir}" do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
  to node['hopsworks']['data_volume']['node_logs']
end

glassfish_asadmin "create-system-properties --target #{local_instance} hazelcast.local.publicAddress=#{private_ip}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-system-properties #{local_instance} | grep hazelcast.local.publicAddress=#{private_ip}"
end

#
# mod_ajp http://www.devwithimagination.com/2015/08/13/apache-as-a-reverse-proxy-to-glassfish/
#
# https://dzone.com/articles/configure-a-glassfish-cluster-with-automatic-load
# docker
# https://github.com/jelastic-jps/glassfish/

# This is done here to reserve the name of the worker
# when config node runs on a worker it just need to get its name by ip
count_nodes_cmd="#{asadmin_cmd} list-nodes | wc -l"
config_nodes.each do |val| 
  glassfish_asadmin "create-node-config --nodehost #{val} --installdir #{node['glassfish']['base_dir']}/versions/current --nodedir #{nodedir} worker$(#{count_nodes_cmd})" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin_cmd} list-nodes -l | grep #{val}"
  end
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

hopsworks_configure_server "glassfish_create_resource_ref" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  asadmin asadmin
  target deployment_group
  action :glassfish_create_resource_ref
end

#restart only if new (no deployed apps)
glassfish_asadmin "restart-domain" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
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
  requires_authbind requires_authbind
  action :add_to_services
  not_if "systemctl is-active --quiet #{service_name}"
end

# If not going to redeploy ear restart so the configs are applied
glassfish_asadmin "restart-deployment-group --rolling=true --delay 5000 #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin_cmd} list-applications --type ejb #{deployment_group} | grep -w \"hopsworks-ear:#{node['hopsworks']['version']}\""
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
