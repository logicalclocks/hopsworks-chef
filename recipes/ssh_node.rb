
domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"
username=node['hopsworks']['admin']['user']
nodedir=node['glassfish']['nodes_dir']

admin_port = node['hopsworks']['admin']['port']
das_ip=private_recipe_ip('hopsworks', 'das_node')
public_ip=my_public_ip()

asadmin_cmd="#{asadmin} --host #{das_ip} --port #{admin_port} --user #{username} --passwordfile #{password_file}"
service_name="glassfish-instance"

#we do not want glassfish DAS on worker 
service "glassfish-#{domain_name}" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true, :disable => true
  action :stop
end
service "glassfish-#{domain_name}" do
  provider Chef::Provider::Service::Systemd
  supports :restart => true, :stop => true, :start => true, :status => true, :disable => true
  action :disable
end

node_name=get_node_name(asadmin_cmd, public_ip)
instance_name=get_instance_name(asadmin_cmd, node_name)

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
  action :add_to_services
  not_if "systemctl is-active --quiet #{service_name}"
end
