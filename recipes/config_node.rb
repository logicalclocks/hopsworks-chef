include_recipe "hadoop_spark::install"
include_recipe "hadoop_spark::config"
include_recipe "flink::install"

domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"
username=node['hopsworks']['admin']['user']
nodedir=node['glassfish']['nodes_dir']
payara_config = "hopsworks-config"
deployment_group = "hopsworks-dg"

admin_port = node['hopsworks']['admin']['port']
das_ip=private_recipe_ip('hopsworks', 'das_node')
private_ip=my_private_ip()

asadmin_cmd="#{asadmin} -I false --host #{das_ip} --port #{admin_port} --user #{username} --passwordfile #{password_file}"
service_name="glassfish-instance"
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"
requires_authbind = admin_port.to_i < 1024 || node['hopsworks']['https']['port'].to_i < 1024

node_name=get_node_name(asadmin_cmd, private_ip)
# instance and node name should have the same suffix workerX/instanceX.
instance_name="instance#{node_name.scan(/\d+/)[0]}"

directory "#{nodedir}" do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode '0750'
  not_if { ::File.directory?("#{nodedir}")}
end

glassfish_asadmin "--host #{das_ip} create-local-instance --config #{payara_config} --node #{node_name} --nodedir #{nodedir}  #{instance_name}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-instances | grep #{instance_name}"
end

glassfish_asadmin "--host #{das_ip} create-system-properties --target #{instance_name} hazelcast.local.publicAddress=#{private_ip}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin_cmd} list-system-properties #{instance_name} | grep hazelcast.local.publicAddress=#{private_ip}"
end

glassfish_asadmin "--host #{das_ip} add-instance-to-deployment-group --instance #{instance_name} --deploymentgroup #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

hopsworks_worker "configure_node" do
  asadmin asadmin
  admin_port admin_port
  username username
  password_file password_file
  nodedir nodedir
  service_name service_name
  node_name node_name
  instance_name instance_name
end

hopsworks_worker "add_to_services" do
  asadmin asadmin
  admin_port admin_port
  username username
  password_file password_file
  nodedir nodedir
  node_name node_name
  instance_name instance_name
  service_name service_name
  requires_authbind requires_authbind
  action :add_to_services
  not_if "systemctl is-active --quiet #{service_name}"
end