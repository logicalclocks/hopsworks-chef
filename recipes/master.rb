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

homedir = conda_helpers.get_user_home(node['hopsworks']['user'])

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  action :generate  
end  

kagent_keys "#{homedir}" do
  cb_user node['hopsworks']['user']
  cb_group node['hopsworks']['group']
  cb_name "hopsworks"
  cb_recipe "master"  
  action :return_publickey
end  

domain_name= node['hopsworks']['domain_name']
domains_dir = node['glassfish']['domains_dir']
admin_port = 4848
username=node['hopsworks']['admin']['user']
password=node['hopsworks']['admin']['password']
glassfish_nodes=node['hopsworks']['nodes']

# Install load balancer
case node['platform_family']
when "debian"
  package "apache2" do
    retries 10
    retry_delay 30
  end
  template "/etc/apache2/sites-available/loadbalancer.conf"  do
    source 'loadbalancer.conf.erb'
    owner node['hopsworks']['user']
    group node['hopsworks']['group']
    mode "700"
    action :create
    variables({
      :load_balancer_log_dir => "/var/log/apache2",
      :glassfish_nodes => glassfish_nodes
    })
  end

  bash "configure load balancer" do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd client_dir
    code <<-EOF
      a2ensite loadbalancer.conf
      a2dissite 000-default.conf
      systemctl restart apache2
    EOF
  end
when "rhel"
  package "httpd" do
    retries 10
    retry_delay 30
  end
  directory "/etc/httpd/sites-available /etc/httpd/sites-enabled" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode '0700'
    action :create
    not_if { ::File.directory?('/etc/httpd/sites-available') }
  end
  directory "/etc/httpd/sites-enabled" do
    owner node['glassfish']['user']
    group node['glassfish']['group']
    mode '0700'
    action :create
    not_if { ::File.directory?('/etc/httpd/sites-enabled') }
  end

  template "/etc/httpd/sites-available/loadbalancer.conf"  do
    source 'loadbalancer.conf.erb'
    owner node['hopsworks']['user']
    group node['hopsworks']['group']
    mode "700"
    action :create
    variables({
      :load_balancer_log_dir => "/var/log/httpd",
      :glassfish_nodes => glassfish_nodes
    })
  end

  bash "configure load balancer" do
    user node['hopsworks']['user']
    group node['hopsworks']['group']
    cwd client_dir
    code <<-EOF
      echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf 
      ln -s /etc/httpd/sites-available/loadbalancer.conf /etc/httpd/sites-enabled/loadbalancer.conf
      systemctl restart httpd
    EOF
  end
end


glassfish_asadmin "set-hazelcast-configuration --publicaddress #{public_ip}" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end
glassfish_asadmin "set-hazelcast-configuration --daspublicaddress #{public_ip}" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end
glassfish_asadmin "create-local-instance --config #{payara_config} #{master_instance}" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

#
# mod_ajp http://www.devwithimagination.com/2015/08/13/apache-as-a-reverse-proxy-to-glassfish/
#
# https://dzone.com/articles/configure-a-glassfish-cluster-with-automatic-load
# docker
# https://github.com/jelastic-jps/glassfish/

glassfish_nodes.each_with_index do |val, index|
  glassfish_asadmin "create-node-ssh --nodehost #{val} --installdir #{node['glassfish']['base_dir']}/versions/current worker#{index}" do
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure false
  end
  glassfish_asadmin "create-instance --config #{payara_config} --node worker#{index} instance#{index}" do
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure false
  end
end

glassfish_asadmin "create-deployment-group #{deployment_group}" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "add-instance-to-deployment-group --instance #{master_instance} --deploymentgroup #{deployment_group}" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

glassfish_nodes.each_with_index do |val, index|
  glassfish_asadmin "add-instance-to-deployment-group --instance instance#{index} --deploymentgroup #{deployment_group}" do
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure false
  end
end

glassfish_asadmin "restart-domain" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

glassfish_asadmin "start-deployment-group --instancetimeout 120 #{deployment_group}" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end

#target in create not working so create a ref to the resource
jdbc_resources = ['jdbc/airflow', 'jdbc/featurestore', 'jdbc/hopsworks', 'jdbc/hopsworksTimers']

glassfish_nodes.each do |val|
  glassfish_asadmin "create-resource-ref --target #{deployment_group} #{val}" do
    domain_name domain_name
    password_file "#{domains_dir}/#{domain_name}_admin_passwd"
    username username
    admin_port admin_port
    secure false
  end
end

glassfish_asadmin "restart-domain" do
  domain_name domain_name
  password_file "#{domains_dir}/#{domain_name}_admin_passwd"
  username username
  admin_port admin_port
  secure false
end
