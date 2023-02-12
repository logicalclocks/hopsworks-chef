#rows_path = "#{domains_dir}/post.sql"

case node['platform']
when "rhel"
  package "openssh-clients"
end

package "openssh-server"
public_ip=my_public_ip()
payara_config = "hopsworks-config"
deployment_group = "hopsworks-dg"
master_instance = "master-instance"

domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
admin_port = 4848
username=node['hopsworks']['admin']['user']
password=node['hopsworks']['admin']['password']
glassfish_nodes=node['hopsworks']['nodes']

asadmin = "#{node['glassfish']['base_dir']}/versions/current/bin/asadmin"
admin_pwd = "#{domains_dir}/#{domain_name}_admin_passwd"
password_file = "#{domains_dir}/#{domain_name}_admin_passwd"

homedir = conda_helpers.get_user_home(node['hopsworks']['user'])
node.override['glassfish']['install_dir'] = "#{node['glassfish']['install_dir']}/glassfish/versions/current"

# Install load balancer
case node['platform_family']
when "debian"
  package "apache2" do
    retries 10
    retry_delay 30
  end
  template "/etc/apache2/sites-available/loadbalancer.conf"  do
    source 'loadbalancer.conf.erb'
    user 'root'
    action :create
    variables({
      :load_balancer_log_dir => "/var/log/apache2",
      :public_ip => public_ip,
      :glassfish_nodes => glassfish_nodes
    })
  end

  bash "configure load balancer" do
    user 'root'
    code <<-EOF
      sed -i 's/Listen 80$/Listen 1080/' /etc/apache2/ports.conf 
      a2ensite loadbalancer.conf
      a2dissite 000-default.conf
      systemctl restart apache2
    EOF
  end
when "rhel"
  package ["httpd", "mod_ssl"] do
    retries 10
    retry_delay 30
  end
  directory "/etc/httpd/sites-available" do
    user 'root'
    action :create
    not_if { ::File.directory?('/etc/httpd/sites-available') }
  end
  directory "/etc/httpd/sites-enabled" do
    user 'root'
    action :create
    not_if { ::File.directory?('/etc/httpd/sites-enabled') }
  end

  template "/etc/httpd/sites-available/loadbalancer.conf"  do
    source 'loadbalancer.conf.erb'
    user 'root'
    action :create
    variables({
      :load_balancer_log_dir => "/var/log/httpd",
      :public_ip => public_ip,
      :glassfish_nodes => glassfish_nodes
    })
  end

  bash "configure load balancer" do
    user 'root'
    code <<-EOF
      sed -i 's/Listen 80$/Listen 1080/' /etc/httpd/conf/httpd.conf
      echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf
      ln -s /etc/httpd/sites-available/loadbalancer.conf /etc/httpd/sites-enabled/loadbalancer.conf
      systemctl restart httpd
    EOF
    not_if { ::File.exist?('/etc/httpd/sites-enabled/loadbalancer.conf') }
  end
end

# Create a configuration b/c server-config can not be used for HA
glassfish_asadmin "copy-config default-config #{payara_config}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-configs | grep #{payara_config}"
end

hopsworks_configure_server "configure_realm" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  action :configure_realm
end

hopsworks_configure_server "glassfish_configure_network" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  action :glassfish_configure_network
end

hopsworks_configure_server "glassfish_configure" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  action :glassfish_configure
end

hopsworks_configure_server "glassfish_configure_monitoring" do
  domain_name domain_name
  domains_dir domains_dir
  password_file password_file
  username username
  admin_port admin_port
  target "#{payara_config}"
  asadmin asadmin
  admin_pwd admin_pwd
  action :glassfish_configure_monitoring
end

glassfish_asadmin "set-hazelcast-configuration --publicaddress #{public_ip}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "set-hazelcast-configuration --daspublicaddress #{public_ip}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

# --nodedir #{domains_dir}/nodes will fail to start and need restarting from the node
# start-local-instance --node localhost-domain1 --nodedir #{domains_dir}/nodes --sync normal --timeout 120 master-instance
glassfish_asadmin "create-local-instance --config #{payara_config} #{master_instance}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-instances | grep #{master_instance}"
end

#
# mod_ajp http://www.devwithimagination.com/2015/08/13/apache-as-a-reverse-proxy-to-glassfish/
#
# https://dzone.com/articles/configure-a-glassfish-cluster-with-automatic-load
# docker
# https://github.com/jelastic-jps/glassfish/
# --nodedir #{domains_dir}/nodes will fail to start and need restarting from the node
glassfish_nodes.each_with_index do |val, index|
  glassfish_asadmin "create-node-ssh --nodehost #{val} --installdir #{node['glassfish']['base_dir']}/versions/current worker#{index}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-nodes | grep worker#{index}"
  end
  glassfish_asadmin "create-instance --config #{payara_config} --node worker#{index} instance#{index}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-instances | grep instance#{index}"
  end
end

glassfish_asadmin "create-deployment-group #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-deployment-groups | grep #{deployment_group}"
end

glassfish_asadmin "add-instance-to-deployment-group --instance #{master_instance} --deploymentgroup #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_nodes.each_with_index do |val, index|
  glassfish_asadmin "add-instance-to-deployment-group --instance instance#{index} --deploymentgroup #{deployment_group}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
  end
end

# Resources created in default, create a reference to the resources in the new config
# Also target in create does not work
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
  'mail/BBCMail']

glassfish_resources.each do |val|
  glassfish_asadmin "create-resource-ref --target #{deployment_group} #{val}" do
    domain_name domain_name
    password_file password_file
    username username
    admin_port admin_port
    secure false
    not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-resource-refs #{deployment_group} | grep #{val}"
  end
end

# delete deployed application referance
glassfish_asadmin "delete-application-ref --target server hopsworks-ca:#{node['hopsworks']['version']}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-application-refs server | grep hopsworks-ca:#{node['hopsworks']['version']}"
end

glassfish_asadmin "delete-application-ref --target server hopsworks-web:#{node['hopsworks']['version']}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-application-refs server | grep hopsworks-web:#{node['hopsworks']['version']}"
end

glassfish_asadmin "delete-application-ref --target server hopsworks-ear:#{node['hopsworks']['version']}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  only_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-application-refs server | grep hopsworks-ear:#{node['hopsworks']['version']}"
end

# create deployed application referance for the deployment group
# only checking if the master instance has a referance to the application, b/c list-application-refs does not work for deployment_group
# this will not work if a new node is added with upgrade
glassfish_asadmin "create-application-ref --target #{deployment_group} hopsworks-ca:#{node['hopsworks']['version']}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-application-refs #{master_instance} | grep hopsworks-ca:#{node['hopsworks']['version']}"
end

glassfish_asadmin "create-application-ref --target #{deployment_group} hopsworks-web:#{node['hopsworks']['version']}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-application-refs #{master_instance} | grep hopsworks-web:#{node['hopsworks']['version']}"
end

glassfish_asadmin "create-application-ref --target #{deployment_group} hopsworks-ear:#{node['hopsworks']['version']}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
  not_if "#{asadmin} --user #{username} --passwordfile #{admin_pwd} list-application-refs #{master_instance} | grep hopsworks-ear:#{node['hopsworks']['version']}"
end

# Check the version of the deployed and redeploy if different
# Check if <nodes-dir>/nodes/localhost-domain1/master-instance/docroot/ exists before creating local-instance and node-ssh
# and redeploy frontend if it exists.

glassfish_asadmin "restart-domain" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "start-deployment-group --instancetimeout 120 #{deployment_group}" do
  domain_name domain_name
  password_file password_file
  username username
  admin_port admin_port
  secure false
end
